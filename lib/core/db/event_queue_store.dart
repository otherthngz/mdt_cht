import '../events/event_models.dart';

abstract class EventQueueStore {
  Future<void> appendEvent(EventEnvelope event);

  Future<List<EventEnvelope>> getSyncCandidates(DateTime nowUtc);

  Future<void> markSent(String eventId);

  Future<void> markFailed({
    required String eventId,
    required String errorCode,
    required String errorMessage,
    required DateTime? nextRetryAtUtc,
    required int retryCount,
  });
}
