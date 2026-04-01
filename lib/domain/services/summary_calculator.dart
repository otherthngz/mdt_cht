import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/shift_summary.dart';

/// SummaryCalculator — per 06_ARCHITECTURE.md §8.
///
/// Derives [ShiftSummary] from raw [ActivityEvent] list and [ShiftSession].
///
/// Algorithm:
///   1. Pair ACTIVITY_STARTED → ACTIVITY_ENDED
///   2. Sum durations by category
///   3. Calculate total shift seconds
///   4. Derive PA and UA
///   5. Count loading and hauling occurrences
///   6. Derive total delta HM
class SummaryCalculator {
  /// Build a summary from [events] belonging to [session].
  ///
  /// Events should already be sorted by occurredAt (ascending).
  ShiftSummary calculate(
    List<ActivityEvent> events,
    ShiftSession session,
  ) {
    int operationSeconds = 0;
    int standbySeconds = 0;
    int delaySeconds = 0;
    int breakdownSeconds = 0;
    int loadingCount = 0;
    int haulingCount = 0;

    // Walk events: pair start → end, accumulate by category
    String? openCategory;
    String? openSubtype;
    DateTime? openStartedAt;

    for (final event in events) {
      if (event.eventName == 'ACTIVITY_STARTED') {
        openCategory = event.activityCategory;
        openSubtype = event.activitySubtype;
        openStartedAt = DateTime.parse(event.occurredAt);

        // Count loading/hauling
        if (openSubtype == 'loading') loadingCount++;
        if (openSubtype == 'hauling') haulingCount++;
      } else if (event.eventName == 'ACTIVITY_ENDED') {
        if (openStartedAt != null && openCategory != null) {
          final endedAt = DateTime.parse(event.occurredAt);
          final duration = endedAt.difference(openStartedAt).inSeconds;
          final safeDuration = duration < 0 ? 0 : duration;

          switch (openCategory) {
            case 'operation':
              operationSeconds += safeDuration;
              break;
            case 'standby':
              standbySeconds += safeDuration;
              break;
            case 'delay':
              delaySeconds += safeDuration;
              break;
            case 'breakdown':
              breakdownSeconds += safeDuration;
              break;
          }
        }

        // Reset tracking
        openCategory = null;
        openSubtype = null;
        openStartedAt = null;
      }
      // Skip SHIFT_STARTED, SHIFT_ENDED
    }

    // Handle still-active activity (shift not yet ended)
    if (openStartedAt != null && openCategory != null) {
      final now = DateTime.now();
      final duration = now.difference(openStartedAt).inSeconds;
      final safeDuration = duration < 0 ? 0 : duration;

      switch (openCategory) {
        case 'operation':
          operationSeconds += safeDuration;
          break;
        case 'standby':
          standbySeconds += safeDuration;
          break;
        case 'delay':
          delaySeconds += safeDuration;
          break;
        case 'breakdown':
          breakdownSeconds += safeDuration;
          break;
      }
    }

    final totalShiftSeconds =
        operationSeconds + standbySeconds + delaySeconds + breakdownSeconds;

    // HM derivation
    final double? totalDeltaHm =
        session.hmEnd != null ? session.hmEnd! - session.hmStart : null;

    // PA = (total - breakdown) / total * 100
    double? pa;
    if (totalShiftSeconds > 0) {
      pa = (totalShiftSeconds - breakdownSeconds) / totalShiftSeconds * 100;
    }

    // UA = operation / (total - breakdown) * 100
    double? ua;
    final availableSeconds = totalShiftSeconds - breakdownSeconds;
    if (availableSeconds > 0) {
      ua = operationSeconds / availableSeconds * 100;
    }

    return ShiftSummary(
      shiftSessionId: session.shiftSessionId,
      totalShiftSeconds: totalShiftSeconds,
      totalOperationSeconds: operationSeconds,
      totalStandbySeconds: standbySeconds,
      totalDelaySeconds: delaySeconds,
      totalBreakdownSeconds: breakdownSeconds,
      hmStart: session.hmStart,
      hmEnd: session.hmEnd,
      totalDeltaHm: totalDeltaHm,
      pa: pa,
      ua: ua,
      loadingCountTotal: loadingCount,
      haulingCountTotal: haulingCount,
    );
  }
}
