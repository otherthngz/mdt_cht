import 'dart:math';

import '../db/event_queue_store.dart';
import '../network/event_api_client.dart';

class SyncRunResult {
  SyncRunResult({
    required this.processed,
    required this.sent,
    required this.failed,
  });

  final int processed;
  final int sent;
  final int failed;
}

class BackoffPolicy {
  BackoffPolicy({Random? random}) : _random = random ?? Random();

  final Random _random;

  Duration nextDelay(int retryCount) {
    final base = (pow(2, retryCount).toInt() * 5);
    final jitter = _random.nextInt(4);
    final seconds = min(300, base + jitter);
    return Duration(seconds: seconds);
  }
}

class SyncService {
  SyncService({
    required EventQueueStore queueStore,
    required EventApiClient apiClient,
    required BackoffPolicy backoffPolicy,
    DateTime Function()? nowUtc,
  })  : _queueStore = queueStore,
        _apiClient = apiClient,
        _backoffPolicy = backoffPolicy,
        _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  final EventQueueStore _queueStore;
  final EventApiClient _apiClient;
  final BackoffPolicy _backoffPolicy;
  final DateTime Function() _nowUtc;

  Future<SyncRunResult> syncNow() async {
    final now = _nowUtc();
    final candidates = await _queueStore.getSyncCandidates(now);

    var sent = 0;
    var failed = 0;

    for (final event in candidates) {
      try {
        final response = await _apiClient.postEvent(event);
        switch (response.type) {
          case ApiEventResultType.applied:
          case ApiEventResultType.duplicate:
            await _queueStore.markSent(event.eventId);
            sent += 1;
            break;
          case ApiEventResultType.rejectedConflict:
            await _queueStore.markFailed(
              eventId: event.eventId,
              errorCode: response.code ?? 'ASSIGNMENT_STATE_MISMATCH',
              errorMessage: response.message ?? 'Conflict error',
              nextRetryAtUtc: null,
              retryCount: event.retryCount,
            );
            failed += 1;
            break;
          case ApiEventResultType.transientFailure:
            final nextRetryCount = event.retryCount + 1;
            final nextRetryAt = now.add(_backoffPolicy.nextDelay(nextRetryCount));
            await _queueStore.markFailed(
              eventId: event.eventId,
              errorCode: response.code ?? 'TRANSIENT_UPSTREAM',
              errorMessage: response.message ?? 'Transient error',
              nextRetryAtUtc: nextRetryAt,
              retryCount: nextRetryCount,
            );
            failed += 1;
            break;
        }
      } catch (_) {
        final nextRetryCount = event.retryCount + 1;
        final nextRetryAt = now.add(_backoffPolicy.nextDelay(nextRetryCount));
        await _queueStore.markFailed(
          eventId: event.eventId,
          errorCode: 'NETWORK_ERROR',
          errorMessage: 'Network error while sending event',
          nextRetryAtUtc: nextRetryAt,
          retryCount: nextRetryCount,
        );
        failed += 1;
      }
    }

    return SyncRunResult(
      processed: candidates.length,
      sent: sent,
      failed: failed,
    );
  }
}
