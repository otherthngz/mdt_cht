import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../core/db/assignment_repository.dart';
import '../core/db/event_repository.dart';
import '../core/db/reason_code_repository.dart';
import '../core/db/shift_session_repository.dart';
import '../core/events/activity_timer_logic.dart';
import '../core/events/event_factory.dart';
import '../core/events/event_models.dart';
import '../core/events/p2h_rule_engine.dart';
import '../core/network/event_api_client.dart';
import '../core/sync/sync_service.dart';

class RingkasanPekerjaan {
  RingkasanPekerjaan({
    required this.operatorId,
    required this.unitId,
    required this.hmMulai,
    required this.hmAkhir,
    required this.durasiShift,
    required this.jumlahAktivitas,
  });

  final String operatorId;
  final String unitId;
  final double hmMulai;
  final double hmAkhir;
  final Duration durasiShift;
  final int jumlahAktivitas;
}

class MdtService {
  MdtService({
    required EventRepository eventRepository,
    required AssignmentRepository assignmentRepository,
    required ReasonCodeRepository reasonCodeRepository,
    required ShiftSessionRepository shiftSessionRepository,
    required EventFactory eventFactory,
    required EventApiClient eventApiClient,
    required SyncService syncService,
  })  : _eventRepository = eventRepository,
        _assignmentRepository = assignmentRepository,
        _reasonCodeRepository = reasonCodeRepository,
        _shiftSessionRepository = shiftSessionRepository,
        _eventFactory = eventFactory,
        _eventApiClient = eventApiClient,
        _syncService = syncService;

  final EventRepository _eventRepository;
  final AssignmentRepository _assignmentRepository;
  final ReasonCodeRepository _reasonCodeRepository;
  final ShiftSessionRepository _shiftSessionRepository;
  final EventFactory _eventFactory;
  final EventApiClient _eventApiClient;
  final SyncService _syncService;
  final ActivityTimerLogic _activityTimerLogic = ActivityTimerLogic();
  final Uuid _uuid = const Uuid();

  Future<void> recordLogin({
    required String operatorId,
    String? pin,
  }) async {
    if (operatorId.trim().isEmpty) {
      throw ArgumentError('ID wajib diisi.');
    }

    final event = _eventFactory.create(
      eventType: EventType.loginRecorded,
      operatorId: operatorId.trim(),
      unitId: null,
      payload: {
        'operatorId': operatorId.trim(),
        'pinLength': pin?.length ?? 0,
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<void> recordLogout({
    required String operatorId,
    String? unitId,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.logoutRecorded,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'logoutAtUtc': DateTime.now().toUtc().toIso8601String(),
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<String> submitPreShiftHourmeter({
    required String operatorId,
    required String unitId,
    required double hmMulai,
  }) async {
    if (hmMulai < 0) {
      throw ArgumentError('Hourmeter tidak boleh negatif.');
    }

    await selectUnit(operatorId: operatorId, unitId: unitId);
    return startHm(operatorId: operatorId, unitId: unitId, hmStart: hmMulai);
  }

  Future<void> emitP2HItemUpdated({
    required String operatorId,
    required String unitId,
    required String item,
    required String status,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.p2hItemUpdated,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'item': item,
        'status': status,
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<P2HOutcome> submitP2HChecklist({
    required String operatorId,
    required String unitId,
    required Map<String, String> itemStatuses,
  }) async {
    final issues = <P2HIssue>[];
    itemStatuses.forEach((item, status) {
      if (status == 'problem') {
        issues.add(P2HIssue(title: item, severity: IssueSeverity.normal));
      }
    });

    final draftEvent = _eventFactory.create(
      eventType: EventType.p2hDraftSaved,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'itemStatuses': itemStatuses,
      },
    );
    await _eventRepository.appendEvent(draftEvent);

    return submitP2H(
      operatorId: operatorId,
      unitId: unitId,
      issues: issues,
      notes: null,
    );
  }

  Future<void> requestEndShift({
    required String operatorId,
    required String unitId,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.endShiftRequested,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'requestedAtUtc': DateTime.now().toUtc().toIso8601String(),
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<void> confirmEndShift({
    required String operatorId,
    required String unitId,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.endShiftConfirmed,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'confirmedAtUtc': DateTime.now().toUtc().toIso8601String(),
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<void> selectActivityOption({
    required String operatorId,
    required String unitId,
    required ActivityState state,
    required String activityName,
  }) async {
    final stateEvent = _eventFactory.create(
      eventType: EventType.activityStateSelected,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'state': state.name,
      },
    );
    await _eventRepository.appendEvent(stateEvent);

    final activityEvent = _eventFactory.create(
      eventType: EventType.activitySelected,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'activityName': activityName,
        'state': state.name,
      },
    );
    await _eventRepository.appendEvent(activityEvent);
  }

  Future<DateTime> startSelectedActivity({
    required String operatorId,
    required String unitId,
    required ActivityState state,
    required String activityName,
  }) async {
    final category = state == ActivityState.running
        ? ActivityCategory.production
        : ActivityCategory.nonProduction;

    final startedAt = DateTime.now().toUtc();
    _activityTimerLogic.start(
      startedAtUtc: startedAt,
      category: category,
      state: state,
      notes: activityName,
    );

    final event = _eventFactory.create(
      eventType: EventType.activityStarted,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'startedAtUtc': startedAt.toIso8601String(),
        'category': category.name,
        'state': state.name,
        'activityName': activityName,
      },
    );
    await _eventRepository.appendEvent(event);
    return startedAt;
  }

  Future<void> submitPostShiftHourmeter({
    required String operatorId,
    required String unitId,
    required String shiftSessionId,
    required double hmMulai,
    required double hmAkhir,
  }) async {
    if (hmAkhir < 0) {
      throw ArgumentError('Hourmeter tidak boleh negatif.');
    }
    if (hmAkhir < hmMulai) {
      throw ArgumentError('HM Akhir harus lebih besar atau sama dengan HM Mulai.');
    }

    await endShift(
      operatorId: operatorId,
      unitId: unitId,
      shiftSessionId: shiftSessionId,
      hmEnd: hmAkhir,
    );
  }

  Future<RingkasanPekerjaan> buildRingkasanPekerjaan({
    required String operatorId,
    required String unitId,
    required double hmMulai,
    required double hmAkhir,
  }) async {
    final events = await _eventRepository.listAll();
    var totalSeconds = 0;
    var count = 0;

    for (final event in events) {
      if (event.eventType != EventType.activityStopped) {
        continue;
      }
      final payload = jsonDecode(event.payloadJson) as Map<String, dynamic>;
      totalSeconds += (payload['elapsedSeconds'] as num?)?.toInt() ?? 0;
      count += 1;
    }

    return RingkasanPekerjaan(
      operatorId: operatorId,
      unitId: unitId,
      hmMulai: hmMulai,
      hmAkhir: hmAkhir,
      durasiShift: Duration(seconds: totalSeconds),
      jumlahAktivitas: count,
    );
  }

  Future<void> selectUnit({
    required String operatorId,
    required String unitId,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.unitSelected,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'unitId': unitId,
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<String> startHm({
    required String operatorId,
    required String unitId,
    required double hmStart,
  }) async {
    final session = await _shiftSessionRepository.startShift(
      operatorId: operatorId,
      unitId: unitId,
      hmStart: hmStart,
    );

    final hmEvent = _eventFactory.create(
      eventType: EventType.hmStartRecorded,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'sessionId': session.sessionId,
        'hmStart': hmStart,
      },
    );
    await _eventRepository.appendEvent(hmEvent);
    return session.sessionId;
  }

  Future<P2HOutcome> submitP2H({
    required String operatorId,
    required String unitId,
    required List<P2HIssue> issues,
    String? notes,
  }) async {
    final outcome = P2HRuleEngine.evaluate(issues);
    final event = _eventFactory.create(
      eventType: EventType.p2hSubmitted,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'issues': issues.map((item) => item.toJson()).toList(),
        'notes': notes,
        'outcome': outcome.name,
      },
    );
    await _eventRepository.appendEvent(event);
    return outcome;
  }

  Future<void> startActivity({
    required String operatorId,
    required String unitId,
    required ActivityCategory category,
    required ActivityState state,
    String? reasonCode,
    String? notes,
  }) async {
    final startedAt = DateTime.now().toUtc();
    _activityTimerLogic.start(
      startedAtUtc: startedAt,
      category: category,
      state: state,
      reasonCode: reasonCode,
      notes: notes,
    );

    final event = _eventFactory.create(
      eventType: EventType.activityStarted,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'startedAtUtc': startedAt.toIso8601String(),
        'category': category.name,
        'state': state.name,
        'reasonCode': reasonCode,
        'notes': notes,
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<Duration> stopActivity({
    required String operatorId,
    required String unitId,
  }) async {
    final stoppedAt = DateTime.now().toUtc();
    final stop = _activityTimerLogic.stop(stoppedAtUtc: stoppedAt);

    final event = _eventFactory.create(
      eventType: EventType.activityStopped,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'startedAtUtc': stop.startedAtUtc.toIso8601String(),
        'stoppedAtUtc': stop.stoppedAtUtc.toIso8601String(),
        'elapsedSeconds': stop.elapsed.inSeconds,
        'category': stop.category.name,
        'state': stop.state.name,
        'reasonCode': stop.reasonCode,
        'notes': stop.notes,
      },
    );
    await _eventRepository.appendEvent(event);
    return stop.elapsed;
  }

  Future<void> refreshSystemAssignments({
    required String operatorId,
    required String unitId,
  }) async {
    final assignments = await _eventApiClient.getAssignments(unitId: unitId);
    for (final assignment in assignments) {
      await _assignmentRepository.upsertAssignment(assignment);
      final event = _eventFactory.create(
        eventType: EventType.assignmentReceivedSystem,
        operatorId: operatorId,
        unitId: unitId,
        payload: assignment.toJson(),
      );
      await _eventRepository.appendEvent(event);
    }
  }

  Future<void> createRadioAssignment({
    required String operatorId,
    required String unitId,
    required String title,
    String? details,
  }) async {
    final assignment = Assignment(
      assignmentId: 'RADIO-${_uuid.v4()}',
      source: AssignmentSource.radio,
      serverState: 'OPEN',
      title: title,
      details: details,
      version: 1,
      receivedAtUtc: DateTime.now().toUtc(),
      isActive: true,
    );

    await _assignmentRepository.upsertAssignment(assignment);
    final event = _eventFactory.create(
      eventType: EventType.assignmentCreatedRadio,
      operatorId: operatorId,
      unitId: unitId,
      payload: assignment.toJson(),
    );
    await _eventRepository.appendEvent(event);
  }

  Future<void> decideAssignment({
    required String operatorId,
    required String unitId,
    required Assignment assignment,
    required AssignmentDecision decision,
    required String reason,
  }) async {
    final event = _eventFactory.create(
      eventType: EventType.assignmentDecisionSubmitted,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'assignmentId': assignment.assignmentId,
        'expectedVersion': assignment.version,
        'decision': decision.name,
        'reason': reason,
      },
    );
    await _eventRepository.appendEvent(event);
  }

  Future<void> endShift({
    required String operatorId,
    required String unitId,
    required String shiftSessionId,
    required double hmEnd,
  }) async {
    await _shiftSessionRepository.endShift(
      sessionId: shiftSessionId,
      hmEnd: hmEnd,
    );

    final hmEndEvent = _eventFactory.create(
      eventType: EventType.hmEndRecorded,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'sessionId': shiftSessionId,
        'hmEnd': hmEnd,
      },
    );
    await _eventRepository.appendEvent(hmEndEvent);

    final shiftEndEvent = _eventFactory.create(
      eventType: EventType.shiftEnded,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'sessionId': shiftSessionId,
      },
    );
    await _eventRepository.appendEvent(shiftEndEvent);
  }

  Future<void> createCorrectionEvent({
    required String operatorId,
    required String unitId,
    required EventEnvelope failedEvent,
    required Map<String, dynamic> correctionPayload,
  }) async {
    final eventType = failedEvent.eventType == EventType.assignmentDecisionSubmitted
        ? EventType.assignmentDecisionCorrection
        : EventType.activityCorrected;

    final event = _eventFactory.create(
      eventType: eventType,
      operatorId: operatorId,
      unitId: unitId,
      payload: {
        'originalEventId': failedEvent.eventId,
        'originalEventType': failedEvent.eventType.wireValue,
        'originalPayload': failedEvent.payloadMap,
        'correction': correctionPayload,
      },
      correctionOfEventId: failedEvent.eventId,
    );
    await _eventRepository.appendEvent(event);
  }

  Future<SyncRunResult> syncNow() => _syncService.syncNow();

  Future<List<Assignment>> listAssignments() => _assignmentRepository.listAssignments();

  Future<List<ReasonCode>> listReasonCodes() => _reasonCodeRepository.listActive();

  Future<Map<SyncStatus, int>> getSyncCounts() => _eventRepository.getStatusCounts();

  Future<List<EventEnvelope>> listFailedConflicts() =>
      _eventRepository.listFailedConflicts();
}
