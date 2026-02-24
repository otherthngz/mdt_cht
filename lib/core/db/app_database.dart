import 'package:drift/drift.dart';

import '../reasons/reason_catalog.dart';
import 'platform_database.dart';

part 'app_database.g.dart';

class EventLog extends Table {
  TextColumn get eventId => text().named('event_id')();
  TextColumn get idempotencyKey => text().named('idempotency_key').unique()();
  TextColumn get eventType => text().named('event_type')();
  TextColumn get occurredAtUtc => text().named('occurred_at_utc')();
  TextColumn get deviceId => text().named('device_id')();
  TextColumn get operatorId => text().named('operator_id')();
  TextColumn get unitId => text().named('unit_id').nullable()();
  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get status => text().named('status')();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get nextRetryAtUtc =>
      text().named('next_retry_at_utc').nullable()();
  TextColumn get lastErrorCode => text().named('last_error_code').nullable()();
  TextColumn get lastErrorMessage =>
      text().named('last_error_message').nullable()();
  TextColumn get correctionOfEventId =>
      text().named('correction_of_event_id').nullable()();
  TextColumn get createdAtUtc => text().named('created_at_utc')();

  @override
  Set<Column> get primaryKey => {eventId};

  @override
  String get tableName => 'event_log';
}

class Assignments extends Table {
  TextColumn get assignmentId => text().named('assignment_id')();
  TextColumn get source => text()();
  TextColumn get serverState => text().named('server_state')();
  TextColumn get title => text()();
  TextColumn get details => text().nullable()();
  TextColumn get receivedAtUtc => text().named('received_at_utc')();
  IntColumn get version => integer()();
  BoolColumn get isActive => boolean().named('is_active')();

  @override
  Set<Column> get primaryKey => {assignmentId};

  @override
  String get tableName => 'assignments';
}

class ReasonCodes extends Table {
  TextColumn get code => text()();
  TextColumn get groupName => text().named('group_name')();
  TextColumn get label => text()();
  BoolColumn get active => boolean()();

  @override
  Set<Column> get primaryKey => {code};

  @override
  String get tableName => 'reason_codes';
}

class ShiftSession extends Table {
  TextColumn get sessionId => text().named('session_id')();
  TextColumn get operatorId => text().named('operator_id')();
  TextColumn get unitId => text().named('unit_id')();
  RealColumn get hmStart => real().named('hm_start').nullable()();
  RealColumn get hmEnd => real().named('hm_end').nullable()();
  TextColumn get startedAtUtc => text().named('started_at_utc')();
  TextColumn get endedAtUtc => text().named('ended_at_utc').nullable()();

  @override
  Set<Column> get primaryKey => {sessionId};

  @override
  String get tableName => 'shift_session';
}

@DriftDatabase(
  tables: [
    EventLog,
    Assignments,
    ReasonCodes,
    ShiftSession,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(QueryExecutor e) : super(e);

  static Future<AppDatabase> open({QueryExecutor? executor}) async {
    final resolvedExecutor = executor ?? await openPlatformExecutor();
    return AppDatabase._(resolvedExecutor);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
          await _seedReasonCodes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          await _createIndexes();
        },
        beforeOpen: (details) async {
          await _createIndexes();
          if (!details.wasCreated) {
            await _seedReasonCodes();
          }
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_event_log_status_next_retry ON event_log(status, next_retry_at_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_event_log_idempotency ON event_log(idempotency_key)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_assignments_active_received ON assignments(is_active, received_at_utc)',
    );
  }

  Future<void> _seedReasonCodes() async {
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
