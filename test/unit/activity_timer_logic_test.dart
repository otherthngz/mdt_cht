import 'package:flutter_test/flutter_test.dart';
import 'package:mdt_fms_ptba/core/events/activity_timer_logic.dart';
import 'package:mdt_fms_ptba/core/events/event_models.dart';

void main() {
  group('ActivityTimerLogic', () {
    test('enforces single active activity', () {
      final logic = ActivityTimerLogic();
      final now = DateTime.utc(2026, 1, 1, 0, 0, 0);

      logic.start(
        startedAtUtc: now,
        category: ActivityCategory.production,
        state: ActivityState.running,
      );

      expect(
        () => logic.start(
          startedAtUtc: now,
          category: ActivityCategory.nonProduction,
          state: ActivityState.standbyDelay,
        ),
        throwsStateError,
      );
    });

    test('calculates elapsed duration accurately', () {
      final logic = ActivityTimerLogic();
      final start = DateTime.utc(2026, 1, 1, 0, 0, 0);
      final stop = DateTime.utc(2026, 1, 1, 0, 10, 5);

      logic.start(
        startedAtUtc: start,
        category: ActivityCategory.production,
        state: ActivityState.running,
      );

      final result = logic.stop(stoppedAtUtc: stop);
      expect(result.elapsed, const Duration(minutes: 10, seconds: 5));
    });

    test('throws when stopping without start', () {
      final logic = ActivityTimerLogic();
      expect(
        () => logic.stop(stoppedAtUtc: DateTime.utc(2026, 1, 1)),
        throwsStateError,
      );
    });
  });
}
