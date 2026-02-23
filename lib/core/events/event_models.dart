import 'dart:convert';

enum SyncStatus { pending, sent, failed }

enum EventType {
  loginRecorded,
  logoutRecorded,
  unitSelected,
  hmStartRecorded,
  hmEndRecorded,
  p2hItemUpdated,
  p2hDraftSaved,
  p2hSubmitted,
  endShiftRequested,
  endShiftConfirmed,
  activitySelected,
  activityStateSelected,
  activityStarted,
  activityStopped,
  activityCorrected,
  assignmentReceivedSystem,
  assignmentCreatedRadio,
  assignmentDecisionSubmitted,
  assignmentDecisionCorrection,
  shiftEnded,
}

enum ActivityCategory { production, nonProduction }

enum ActivityState { running, standbyDelay, breakdown }

enum AssignmentSource { system, radio }

enum AssignmentDecision { accept, reject }

enum P2HOutcome { pass, passWithNotes, fail }

extension SyncStatusCodec on SyncStatus {
  String get wireValue => switch (this) {
        SyncStatus.pending => 'PENDING',
        SyncStatus.sent => 'SENT',
        SyncStatus.failed => 'FAILED',
      };

  static SyncStatus fromWire(String value) {
    return switch (value) {
      'PENDING' => SyncStatus.pending,
      'SENT' => SyncStatus.sent,
      'FAILED' => SyncStatus.failed,
      _ => throw ArgumentError('Unknown sync status: $value'),
    };
  }
}

extension EventTypeCodec on EventType {
  String get wireValue => switch (this) {
        EventType.loginRecorded => 'LOGIN_RECORDED',
        EventType.logoutRecorded => 'LOGOUT_RECORDED',
        EventType.unitSelected => 'UNIT_SELECTED',
        EventType.hmStartRecorded => 'HM_START_RECORDED',
        EventType.hmEndRecorded => 'HM_END_RECORDED',
        EventType.p2hItemUpdated => 'P2H_ITEM_UPDATED',
        EventType.p2hDraftSaved => 'P2H_DRAFT_SAVED',
        EventType.p2hSubmitted => 'P2H_SUBMITTED',
        EventType.endShiftRequested => 'END_SHIFT_REQUESTED',
        EventType.endShiftConfirmed => 'END_SHIFT_CONFIRMED',
        EventType.activitySelected => 'ACTIVITY_SELECTED',
        EventType.activityStateSelected => 'ACTIVITY_STATE_SELECTED',
        EventType.activityStarted => 'ACTIVITY_STARTED',
        EventType.activityStopped => 'ACTIVITY_STOPPED',
        EventType.activityCorrected => 'ACTIVITY_CORRECTED',
        EventType.assignmentReceivedSystem => 'ASSIGNMENT_RECEIVED_SYSTEM',
        EventType.assignmentCreatedRadio => 'ASSIGNMENT_CREATED_RADIO',
        EventType.assignmentDecisionSubmitted => 'ASSIGNMENT_DECISION_SUBMITTED',
        EventType.assignmentDecisionCorrection => 'ASSIGNMENT_DECISION_CORRECTION',
        EventType.shiftEnded => 'SHIFT_ENDED',
      };

  static EventType fromWire(String value) {
    return switch (value) {
      'LOGIN_RECORDED' => EventType.loginRecorded,
      'LOGOUT_RECORDED' => EventType.logoutRecorded,
      'UNIT_SELECTED' => EventType.unitSelected,
      'HM_START_RECORDED' => EventType.hmStartRecorded,
      'HM_END_RECORDED' => EventType.hmEndRecorded,
      'P2H_ITEM_UPDATED' => EventType.p2hItemUpdated,
      'P2H_DRAFT_SAVED' => EventType.p2hDraftSaved,
      'P2H_SUBMITTED' => EventType.p2hSubmitted,
      'END_SHIFT_REQUESTED' => EventType.endShiftRequested,
      'END_SHIFT_CONFIRMED' => EventType.endShiftConfirmed,
      'ACTIVITY_SELECTED' => EventType.activitySelected,
      'ACTIVITY_STATE_SELECTED' => EventType.activityStateSelected,
      'ACTIVITY_STARTED' => EventType.activityStarted,
      'ACTIVITY_STOPPED' => EventType.activityStopped,
      'ACTIVITY_CORRECTED' => EventType.activityCorrected,
      'ASSIGNMENT_RECEIVED_SYSTEM' => EventType.assignmentReceivedSystem,
      'ASSIGNMENT_CREATED_RADIO' => EventType.assignmentCreatedRadio,
      'ASSIGNMENT_DECISION_SUBMITTED' => EventType.assignmentDecisionSubmitted,
      'ASSIGNMENT_DECISION_CORRECTION' => EventType.assignmentDecisionCorrection,
      'SHIFT_ENDED' => EventType.shiftEnded,
      _ => throw ArgumentError('Unknown event type: $value'),
    };
  }
}

class EventEnvelope {
  EventEnvelope({
    required this.eventId,
    required this.idempotencyKey,
    required this.eventType,
    required this.occurredAtUtc,
    required this.deviceId,
    required this.operatorId,
    required this.unitId,
    required this.payloadJson,
    required this.status,
    required this.retryCount,
    required this.createdAtUtc,
    this.nextRetryAtUtc,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.correctionOfEventId,
  });

  final String eventId;
  final String idempotencyKey;
  final EventType eventType;
  final DateTime occurredAtUtc;
  final String deviceId;
  final String operatorId;
  final String? unitId;
  final String payloadJson;
  final SyncStatus status;
  final int retryCount;
  final DateTime? nextRetryAtUtc;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final String? correctionOfEventId;
  final DateTime createdAtUtc;

  Map<String, dynamic> get payloadMap =>
      jsonDecode(payloadJson) as Map<String, dynamic>;

  EventEnvelope copyWith({
    SyncStatus? status,
    int? retryCount,
    DateTime? nextRetryAtUtc,
    String? lastErrorCode,
    String? lastErrorMessage,
  }) {
    return EventEnvelope(
      eventId: eventId,
      idempotencyKey: idempotencyKey,
      eventType: eventType,
      occurredAtUtc: occurredAtUtc,
      deviceId: deviceId,
      operatorId: operatorId,
      unitId: unitId,
      payloadJson: payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAtUtc: nextRetryAtUtc,
      lastErrorCode: lastErrorCode,
      lastErrorMessage: lastErrorMessage,
      correctionOfEventId: correctionOfEventId,
      createdAtUtc: createdAtUtc,
    );
  }
}

class P2HIssue {
  P2HIssue({
    required this.title,
    required this.severity,
    this.note,
    this.reasonCode,
    this.otherReasonNote,
  });

  final String title;
  final IssueSeverity severity;
  final String? note;
  final String? reasonCode;
  final String? otherReasonNote;

  Map<String, dynamic> toJson() => {
        'title': title,
        'severity': severity.name,
        'note': note,
        'reasonCode': reasonCode,
        'otherReasonNote': otherReasonNote,
      };
}

enum IssueSeverity { normal, critical }

class Assignment {
  Assignment({
    required this.assignmentId,
    required this.source,
    required this.serverState,
    required this.title,
    required this.version,
    required this.receivedAtUtc,
    this.details,
    this.isActive = true,
  });

  final String assignmentId;
  final AssignmentSource source;
  final String serverState;
  final String title;
  final String? details;
  final int version;
  final DateTime receivedAtUtc;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'assignmentId': assignmentId,
        'source': source.name,
        'serverState': serverState,
        'title': title,
        'details': details,
        'version': version,
        'receivedAtUtc': receivedAtUtc.toIso8601String(),
        'isActive': isActive,
      };
}

class ReasonCode {
  ReasonCode({
    required this.code,
    required this.groupName,
    required this.label,
    required this.active,
  });

  final String code;
  final String groupName;
  final String label;
  final bool active;
}
