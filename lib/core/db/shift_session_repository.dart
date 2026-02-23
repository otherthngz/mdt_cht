import 'package:uuid/uuid.dart';

import 'app_database.dart';

class ShiftSession {
  ShiftSession({
    required this.sessionId,
    required this.operatorId,
    required this.unitId,
    required this.startedAtUtc,
    this.hmStart,
    this.hmEnd,
    this.endedAtUtc,
  });

  final String sessionId;
  final String operatorId;
  final String unitId;
  final DateTime startedAtUtc;
  final double? hmStart;
  final double? hmEnd;
  final DateTime? endedAtUtc;
}

class ShiftSessionRepository {
  ShiftSessionRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<ShiftSession> startShift({
    required String operatorId,
    required String unitId,
    double? hmStart,
  }) async {
    final session = ShiftSession(
      sessionId: _uuid.v4(),
      operatorId: operatorId,
      unitId: unitId,
      startedAtUtc: DateTime.now().toUtc(),
      hmStart: hmStart,
    );

    await _db.customStatement(
      '''
        INSERT INTO shift_session(
          session_id,
          operator_id,
          unit_id,
          hm_start,
          hm_end,
          started_at_utc,
          ended_at_utc
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        session.sessionId,
        session.operatorId,
        session.unitId,
        session.hmStart,
        null,
        session.startedAtUtc.toIso8601String(),
        null,
      ],
    );
    return session;
  }

  Future<void> endShift({
    required String sessionId,
    required double hmEnd,
  }) async {
    await _db.customStatement(
      '''
        UPDATE shift_session
        SET hm_end = ?, ended_at_utc = ?
        WHERE session_id = ?
      ''',
      [hmEnd, DateTime.now().toUtc().toIso8601String(), sessionId],
    );
  }
}
