import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../reasons/reason_catalog.dart';

class AppDatabase extends DatabaseConnectionUser {
  AppDatabase._(QueryExecutor executor) : super(executor);

  static Future<AppDatabase> open({QueryExecutor? executor}) async {
    final resolvedExecutor = executor ?? await _defaultExecutor();
    final db = AppDatabase._(resolvedExecutor);
    await db._initialize();
    return db;
  }

  static Future<QueryExecutor> _defaultExecutor() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mdt_poc.sqlite'));
    return NativeDatabase.createInBackground(file);
  }

  Future<void> _initialize() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS event_log (
        event_id TEXT PRIMARY KEY,
        idempotency_key TEXT UNIQUE NOT NULL,
        event_type TEXT NOT NULL,
        occurred_at_utc TEXT NOT NULL,
        device_id TEXT NOT NULL,
        operator_id TEXT NOT NULL,
        unit_id TEXT,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        next_retry_at_utc TEXT,
        last_error_code TEXT,
        last_error_message TEXT,
        correction_of_event_id TEXT,
        created_at_utc TEXT NOT NULL
      )
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_event_log_status_next_retry ON event_log(status, next_retry_at_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_event_log_idempotency ON event_log(idempotency_key)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS assignments (
        assignment_id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        server_state TEXT NOT NULL,
        title TEXT NOT NULL,
        details TEXT,
        received_at_utc TEXT NOT NULL,
        version INTEGER NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_assignments_active_received ON assignments(is_active, received_at_utc)',
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS reason_codes (
        code TEXT PRIMARY KEY,
        group_name TEXT NOT NULL,
        label TEXT NOT NULL,
        active INTEGER NOT NULL
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS shift_session (
        session_id TEXT PRIMARY KEY,
        operator_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        hm_start REAL,
        hm_end REAL,
        started_at_utc TEXT NOT NULL,
        ended_at_utc TEXT
      )
    ''');

    for (final reason in seededReasonCodes) {
      await customStatement(
        '''
          INSERT OR REPLACE INTO reason_codes(code, group_name, label, active)
          VALUES (?, ?, ?, ?)
        ''',
        [
          reason.code,
          reason.groupName,
          reason.label,
          reason.active ? 1 : 0,
        ],
      );
    }
  }
}
