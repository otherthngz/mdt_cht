import 'dart:collection';

import '../events/event_models.dart';
import 'event_api_client.dart';

class MockEventApiClient implements EventApiClient {
  final Set<String> _seenIdempotencyKeys = <String>{};
  final Map<String, int> _transientFailuresByEvent = <String, int>{};
  final Map<String, _ServerAssignment> _serverAssignments = {
    'A-1001': _ServerAssignment(
      assignmentId: 'A-1001',
      title: 'Haul to Zone 3',
      details: 'Priority ore route',
      state: 'OPEN',
      version: 1,
    ),
    'A-1002': _ServerAssignment(
      assignmentId: 'A-1002',
      title: 'Fuel stop at Bay 2',
      details: 'After current cycle',
      state: 'OPEN',
      version: 1,
    ),
  };

  @override
  Future<ApiEventResult> postEvent(EventEnvelope event) async {
    if (_seenIdempotencyKeys.contains(event.idempotencyKey)) {
      return ApiEventResult(
        type: ApiEventResultType.duplicate,
        code: 'DUPLICATE_EVENT',
        message: 'Event already applied.',
      );
    }

    final payload = event.payloadMap;

    final shouldTransient = payload['simulateTransient'] == true;
    if (shouldTransient) {
      final attempts = _transientFailuresByEvent[event.eventId] ?? 0;
      if (attempts < 1) {
        _transientFailuresByEvent[event.eventId] = attempts + 1;
        return ApiEventResult(
          type: ApiEventResultType.transientFailure,
          code: 'TRANSIENT_UPSTREAM',
          message: 'Temporary server issue.',
        );
      }
    }

    if (event.eventType == EventType.assignmentDecisionSubmitted ||
        event.eventType == EventType.assignmentDecisionCorrection) {
      final assignmentId = payload['assignmentId'] as String?;
      final expectedVersion = payload['expectedVersion'] as int?;
      if (assignmentId == null || expectedVersion == null) {
        return ApiEventResult(
          type: ApiEventResultType.rejectedConflict,
          code: 'ASSIGNMENT_STATE_MISMATCH',
          message: 'Missing assignment metadata.',
        );
      }

      final assignment = _serverAssignments[assignmentId];
      if (assignment == null || assignment.version != expectedVersion) {
        return ApiEventResult(
          type: ApiEventResultType.rejectedConflict,
          code: 'ASSIGNMENT_STATE_MISMATCH',
          message: 'Assignment version mismatch.',
        );
      }

      final decision = payload['decision'] as String?;
      if (decision == AssignmentDecision.accept.name) {
        assignment.state = 'ACCEPTED';
      } else if (decision == AssignmentDecision.reject.name) {
        assignment.state = 'REJECTED';
      }
      assignment.version += 1;
      _seenIdempotencyKeys.add(event.idempotencyKey);
      return ApiEventResult(type: ApiEventResultType.applied);
    }

    if (payload['simulateConflict'] == true) {
      return ApiEventResult(
        type: ApiEventResultType.rejectedConflict,
        code: 'ASSIGNMENT_STATE_MISMATCH',
        message: 'Conflict requested by payload.',
      );
    }

    _seenIdempotencyKeys.add(event.idempotencyKey);
    return ApiEventResult(type: ApiEventResultType.applied);
  }

  @override
  Future<List<Assignment>> getAssignments({
    required String unitId,
    DateTime? sinceUtc,
  }) async {
    final now = DateTime.now().toUtc();
    return UnmodifiableListView(
      _serverAssignments.values
          .map(
            (item) => Assignment(
              assignmentId: item.assignmentId,
              source: AssignmentSource.system,
              serverState: item.state,
              title: item.title,
              details: item.details,
              version: item.version,
              receivedAtUtc: now,
              isActive: item.state == 'OPEN',
            ),
          )
          .toList(),
    );
  }
}

class _ServerAssignment {
  _ServerAssignment({
    required this.assignmentId,
    required this.title,
    required this.details,
    required this.state,
    required this.version,
  });

  final String assignmentId;
  final String title;
  final String details;
  String state;
  int version;
}
