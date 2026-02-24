import 'package:drift/drift.dart';

import '../events/event_models.dart';
import 'app_database.dart';
import 'event_queue_store.dart';

class EventRepository implements EventQueueStore {
  EventRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> appendEvent(EventEnvelope event) async {
    await _db.customInsert(
      '''
        INSERT INTO event_log(
          event_id,
          idempotency_key,
          event_type,
          occurred_at_utc,
          device_id,
          operator_id,
          unit_id,
          payload_json,
          status,
          retry_count,
          next_retry_at_utc,
          last_error_code,
          last_error_message,
          correction_of_event_id,
          created_at_utc
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(event.eventId),
        Variable<String>(event.idempotencyKey),
        Variable<String>(event.eventType.wireValue),
        Variable<String>(event.occurredAtUtc.toIso8601String()),
        Variable<String>(event.deviceId),
        Variable<String>(event.operatorId),
        // Nullable fields: pass null directly for SQL NULL
        if (event.unitId != null)
          Variable<String>(event.unitId!)
        else
          const Variable(null),
        Variable<String>(event.payloadJson),
        Variable<String>(event.status.wireValue),
        Variable<int>(event.retryCount),
        if (event.nextRetryAtUtc != null)
          Variable<String>(event.nextRetryAtUtc!.toIso8601String())
        else
          const Variable(null),
        if (event.lastErrorCode != null)
          Variable<String>(event.lastErrorCode!)
        else
          const Variable(null),
        if (event.lastErrorMessage != null)
          Variable<String>(event.lastErrorMessage!)
        else
          const Variable(null),
        if (event.correctionOfEventId != null)
          Variable<String>(event.correctionOfEventId!)
        else
          const Variable(null),
        Variable<String>(event.createdAtUtc.toIso8601String()),
      ],
    );
  }

  @override
  Future<List<EventEnvelope>> getSyncCandidates(DateTime nowUtc) async {
    final rows = await _db.customSelect(
      '''
        SELECT * FROM event_log
        WHERE status = 'PENDING'
           OR (status = 'FAILED' AND next_retry_at_utc IS NOT NULL AND next_retry_at_utc <= ?)
        ORDER BY created_at_utc ASC
      ''',
      variables: [Variable<String>(nowUtc.toIso8601String())],
    ).get();

    return rows.map(_mapEvent).toList();
  }

  Future<List<EventEnvelope>> listAll() async {
    final rows = await _db.customSelect(
      'SELECT * FROM event_log ORDER BY created_at_utc DESC',
    ).get();
    return rows.map(_mapEvent).toList();
  }

  Future<List<EventEnvelope>> listFailedConflicts() async {
    final rows = await _db.customSelect(
      '''
        SELECT * FROM event_log
        WHERE status = 'FAILED' AND last_error_code = 'ASSIGNMENT_STATE_MISMATCH'
        ORDER BY created_at_utc DESC
      ''',
    ).get();
    return rows.map(_mapEvent).toList();
  }

  Future<Map<SyncStatus, int>> getStatusCounts() async {
    final rows = await _db.customSelect(
      'SELECT status, COUNT(*) as total FROM event_log GROUP BY status',
    ).get();

    final result = {
      SyncStatus.pending: 0,
      SyncStatus.sent: 0,
      SyncStatus.failed: 0,
    };
    for (final row in rows) {
      final status = SyncStatusCodec.fromWire(row.read<String>('status'));
      result[status] = row.read<int>('total');
    }
    return result;
  }

  @override
  Future<void> markSent(String eventId) async {
    await _db.customStatement(
      '''
        UPDATE event_log
        SET status = 'SENT',
            last_error_code = NULL,
            last_error_message = NULL,
            next_retry_at_utc = NULL
        WHERE event_id = ?
      ''',
      [eventId],
    );
  }

  @override
  Future<void> markFailed({
    required String eventId,
    required String errorCode,
    required String errorMessage,
    required DateTime? nextRetryAtUtc,
    required int retryCount,
  }) async {
    await _db.customStatement(
      '''
        UPDATE event_log
        SET status = 'FAILED',
            retry_count = ?,
            next_retry_at_utc = ?,
            last_error_code = ?,
            last_error_message = ?
        WHERE event_id = ?
      ''',
      [
        retryCount,
        nextRetryAtUtc?.toIso8601String(),
        errorCode,
        errorMessage,
        eventId,
      ],
    );
  }

  EventEnvelope _mapEvent(QueryRow row) {
    // Helper: treat empty string as null for nullable fields
    String? maybeStr(String col) {
      final v = row.readNullable<String>(col);
      return (v == null || v.isEmpty) ? null : v;
    }

    DateTime? maybeDate(String col) {
      final s = maybeStr(col);
      return s == null ? null : DateTime.parse(s);
    }

    return EventEnvelope(
      eventId: row.read<String>('event_id'),
      idempotencyKey: row.read<String>('idempotency_key'),
      eventType: EventTypeCodec.fromWire(row.read<String>('event_type')),
      occurredAtUtc: DateTime.parse(row.read<String>('occurred_at_utc')),
      deviceId: row.read<String>('device_id'),
      operatorId: row.read<String>('operator_id'),
      unitId: maybeStr('unit_id'),
      payloadJson: row.read<String>('payload_json'),
      status: SyncStatusCodec.fromWire(row.read<String>('status')),
      retryCount: row.read<int>('retry_count'),
      nextRetryAtUtc: maybeDate('next_retry_at_utc'),
      lastErrorCode: maybeStr('last_error_code'),
      lastErrorMessage: maybeStr('last_error_message'),
      correctionOfEventId: maybeStr('correction_of_event_id'),
      createdAtUtc: DateTime.parse(row.read<String>('created_at_utc')),
    );
  }
}
