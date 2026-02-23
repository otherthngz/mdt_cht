import 'package:drift/drift.dart';

import '../events/event_models.dart';
import 'app_database.dart';

class AssignmentRepository {
  AssignmentRepository(this._db);

  final AppDatabase _db;

  Future<void> upsertAssignment(Assignment assignment) async {
    await _db.customStatement(
      '''
        INSERT INTO assignments(
          assignment_id,
          source,
          server_state,
          title,
          details,
          received_at_utc,
          version,
          is_active
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(assignment_id) DO UPDATE SET
          source = excluded.source,
          server_state = excluded.server_state,
          title = excluded.title,
          details = excluded.details,
          received_at_utc = excluded.received_at_utc,
          version = excluded.version,
          is_active = excluded.is_active
      ''',
      [
        assignment.assignmentId,
        assignment.source.name,
        assignment.serverState,
        assignment.title,
        assignment.details,
        assignment.receivedAtUtc.toIso8601String(),
        assignment.version,
        assignment.isActive ? 1 : 0,
      ],
    );
  }

  Future<List<Assignment>> listAssignments() async {
    final rows = await _db.customSelect(
      'SELECT * FROM assignments ORDER BY received_at_utc DESC',
    ).get();

    return rows
        .map(
          (row) => Assignment(
            assignmentId: row.read<String>('assignment_id'),
            source: AssignmentSource.values.firstWhere(
              (value) => value.name == row.read<String>('source'),
            ),
            serverState: row.read<String>('server_state'),
            title: row.read<String>('title'),
            details: row.readNullable<String>('details'),
            version: row.read<int>('version'),
            receivedAtUtc: DateTime.parse(row.read<String>('received_at_utc')),
            isActive: row.read<int>('is_active') == 1,
          ),
        )
        .toList();
  }
}
