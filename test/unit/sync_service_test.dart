import 'package:flutter_test/flutter_test.dart';
import 'package:mdt_fms_ptba/core/db/event_queue_store.dart';
import 'package:mdt_fms_ptba/core/events/event_models.dart';
import 'package:mdt_fms_ptba/core/network/event_api_client.dart';
import 'package:mdt_fms_ptba/core/sync/sync_service.dart';

void main() {
  group('SyncService', () {
    test('duplicate response marks event as SENT', () async {
      final event = _event(idempotencyKey: 'D1:E1');
      final store = _FakeQueueStore([event]);
      final client = _FakeApiClient(
        onPost: (_) async => ApiEventResult(
          type: ApiEventResultType.duplicate,
          code: 'DUPLICATE_EVENT',
        ),
      );

      final service = SyncService(
        queueStore: store,
        apiClient: client,
        backoffPolicy: BackoffPolicy(),
        nowUtc: () => DateTime.utc(2026, 1, 1),
      );

      await service.syncNow();
      expect(store.sentIds, contains(event.eventId));
    });

    test('transient failures increase retry and preserve idempotency key', () async {
      final event = _event(idempotencyKey: 'D1:E1');
      final store = _FakeQueueStore([event]);
      final capturedKeys = <String>[];
      var call = 0;

      final client = _FakeApiClient(
        onPost: (evt) async {
          capturedKeys.add(evt.idempotencyKey);
          call += 1;
          if (call == 1) {
            return ApiEventResult(
              type: ApiEventResultType.transientFailure,
              code: 'TRANSIENT_UPSTREAM',
            );
          }
          return ApiEventResult(type: ApiEventResultType.applied);
        },
      );

      final service = SyncService(
        queueStore: store,
        apiClient: client,
        backoffPolicy: BackoffPolicy(),
        nowUtc: () => DateTime.utc(2026, 1, 1),
      );

      await service.syncNow();
      expect(store.failedUpdates.single.retryCount, 1);

      store.events = [
        event.copyWith(
          status: SyncStatus.failed,
          retryCount: 1,
          nextRetryAtUtc: DateTime.utc(2025, 12, 31),
        ),
      ];
      await service.syncNow();

      expect(capturedKeys, everyElement(equals('D1:E1')));
      expect(store.sentIds, contains(event.eventId));
    });

    test('assignment state mismatch stays FAILED and available for correction flow', () async {
      final event = _event(idempotencyKey: 'D1:E1');
      final store = _FakeQueueStore([event]);
      final client = _FakeApiClient(
        onPost: (_) async => ApiEventResult(
          type: ApiEventResultType.rejectedConflict,
          code: 'ASSIGNMENT_STATE_MISMATCH',
          message: 'Version conflict',
        ),
      );

      final service = SyncService(
        queueStore: store,
        apiClient: client,
        backoffPolicy: BackoffPolicy(),
        nowUtc: () => DateTime.utc(2026, 1, 1),
      );

      await service.syncNow();

      expect(store.failedUpdates.single.errorCode, 'ASSIGNMENT_STATE_MISMATCH');
      expect(store.failedUpdates.single.nextRetryAtUtc, isNull);
    });
  });
}

EventEnvelope _event({required String idempotencyKey}) {
  return EventEnvelope(
    eventId: 'E1',
    idempotencyKey: idempotencyKey,
    eventType: EventType.assignmentDecisionSubmitted,
    occurredAtUtc: DateTime.utc(2026, 1, 1),
    deviceId: 'D1',
    operatorId: 'OP1',
    unitId: 'DT-101',
    payloadJson: '{"assignmentId":"A-1"}',
    status: SyncStatus.pending,
    retryCount: 0,
    createdAtUtc: DateTime.utc(2026, 1, 1),
  );
}

class _FakeQueueStore implements EventQueueStore {
  _FakeQueueStore(this.events);

  List<EventEnvelope> events;
  final List<String> sentIds = [];
  final List<_FailedUpdate> failedUpdates = [];

  @override
  Future<void> appendEvent(EventEnvelope event) async {
    events.add(event);
  }

  @override
  Future<List<EventEnvelope>> getSyncCandidates(DateTime nowUtc) async {
    return events
        .where((event) {
          if (event.status == SyncStatus.pending) {
            return true;
          }
          return event.status == SyncStatus.failed &&
              event.nextRetryAtUtc != null &&
              !event.nextRetryAtUtc!.isAfter(nowUtc);
        })
        .toList();
  }

  @override
  Future<void> markFailed({
    required String eventId,
    required String errorCode,
    required String errorMessage,
    required DateTime? nextRetryAtUtc,
    required int retryCount,
  }) async {
    failedUpdates.add(
      _FailedUpdate(
        eventId: eventId,
        errorCode: errorCode,
        errorMessage: errorMessage,
        nextRetryAtUtc: nextRetryAtUtc,
        retryCount: retryCount,
      ),
    );
  }

  @override
  Future<void> markSent(String eventId) async {
    sentIds.add(eventId);
  }
}

class _FailedUpdate {
  _FailedUpdate({
    required this.eventId,
    required this.errorCode,
    required this.errorMessage,
    required this.nextRetryAtUtc,
    required this.retryCount,
  });

  final String eventId;
  final String errorCode;
  final String errorMessage;
  final DateTime? nextRetryAtUtc;
  final int retryCount;
}

class _FakeApiClient implements EventApiClient {
  _FakeApiClient({required this.onPost});

  final Future<ApiEventResult> Function(EventEnvelope event) onPost;

  @override
  Future<List<Assignment>> getAssignments({
    required String unitId,
    DateTime? sinceUtc,
  }) async {
    return [];
  }

  @override
  Future<ApiEventResult> postEvent(EventEnvelope event) => onPost(event);
}
