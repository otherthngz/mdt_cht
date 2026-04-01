import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/services/summary_calculator.dart';

void main() {
  late SummaryCalculator calculator;

  setUp(() {
    calculator = SummaryCalculator();
  });

  /// Helper to create a minimal ShiftSession.
  ShiftSession makeSession({
    double hmStart = 1000.0,
    double? hmEnd,
    String status = 'ended',
  }) {
    return ShiftSession(
      shiftSessionId: 'test-shift-001',
      unitId: 'HD-001',
      operatorId: 'OP-001',
      shiftDate: '2026-03-31',
      hmStart: hmStart,
      hmEnd: hmEnd,
      startedAt: '2026-03-31T06:00:00.000',
      endedAt: hmEnd != null ? '2026-03-31T14:00:00.000' : null,
      status: status,
    );
  }

  /// Helper to create an event.
  ActivityEvent makeEvent({
    required String eventName,
    required String occurredAt,
    String? activityCategory,
    String? activitySubtype,
    String? loaderCode,
    String? haulingCode,
    double? hmEnd,
  }) {
    return ActivityEvent(
      eventId: 'evt-${occurredAt.hashCode}',
      eventName: eventName,
      shiftSessionId: 'test-shift-001',
      unitId: 'HD-001',
      operatorId: 'OP-001',
      occurredAt: occurredAt,
      activityCategory: activityCategory,
      activitySubtype: activitySubtype,
      loaderCode: loaderCode,
      haulingCode: haulingCode,
      hmEnd: hmEnd,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // BASIC CALCULATIONS
  // ═════════════════════════════════════════════════════════════════════

  group('basic summary calculation', () {
    test('calculates category durations correctly', () {
      final session = makeSession(hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'SHIFT_STARTED',
            occurredAt: '2026-03-31T06:00:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T06:30:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'LDR-001'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T08:30:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);

      expect(summary.totalStandbySeconds, 1800); // 30 min
      expect(summary.totalOperationSeconds, 7200); // 2 hours
      expect(summary.totalDelaySeconds, 0);
      expect(summary.totalBreakdownSeconds, 0);
      expect(summary.totalShiftSeconds, 9000); // 2.5 hours
    });

    test('shiftSessionId matches', () {
      final session = makeSession(hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T07:00:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.shiftSessionId, 'test-shift-001');
    });

    test('empty event list produces zero totals', () {
      final session = makeSession(hmEnd: 1050.0);
      final summary = calculator.calculate([], session);

      expect(summary.totalShiftSeconds, 0);
      expect(summary.totalOperationSeconds, 0);
      expect(summary.totalStandbySeconds, 0);
      expect(summary.totalDelaySeconds, 0);
      expect(summary.totalBreakdownSeconds, 0);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // ALL FOUR CATEGORIES
  // ═════════════════════════════════════════════════════════════════════

  group('all four categories', () {
    test('sums four categories independently', () {
      final session = makeSession(hmEnd: 1100.0);
      final events = [
        // standby 1 hour
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T07:00:00.000'),
        // operation 2 hours
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'L1'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        // delay 30 min
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'delay',
            activitySubtype: 'rain'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:30:00.000'),
        // breakdown 1 hour
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:30:00.000',
            activityCategory: 'breakdown',
            activitySubtype: 'engine'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T10:30:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T10:30:00.000',
            hmEnd: 1100.0),
      ];

      final summary = calculator.calculate(events, session);

      expect(summary.totalStandbySeconds, 3600); // 1h
      expect(summary.totalOperationSeconds, 7200); // 2h
      expect(summary.totalDelaySeconds, 1800); // 30m
      expect(summary.totalBreakdownSeconds, 3600); // 1h
      expect(summary.totalShiftSeconds, 16200); // 4.5h
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // PA / UA
  // ═════════════════════════════════════════════════════════════════════

  group('PA and UA', () {
    test('PA = (total - breakdown) / total * 100', () {
      final session = makeSession(hmEnd: 1100.0);
      final events = [
        // operation 3h
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'dumping'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        // breakdown 1h
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'breakdown',
            activitySubtype: 'engine'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T10:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T10:00:00.000',
            hmEnd: 1100.0),
      ];

      final summary = calculator.calculate(events, session);

      // PA = (14400 - 3600) / 14400 * 100 = 75%
      expect(summary.pa, closeTo(75.0, 0.1));
    });

    test('UA = operation / (total - breakdown) * 100', () {
      final session = makeSession(hmEnd: 1100.0);
      final events = [
        // operation 3h
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'dumping'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        // breakdown 1h
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'breakdown',
            activitySubtype: 'engine'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T10:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T10:00:00.000',
            hmEnd: 1100.0),
      ];

      final summary = calculator.calculate(events, session);

      // UA = 10800 / (14400 - 3600) * 100 = 10800/10800 = 100%
      expect(summary.ua, closeTo(100.0, 0.1));
    });

    test('PA = 100% when no breakdown', () {
      final session = makeSession(hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'L1'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T08:00:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.pa, closeTo(100.0, 0.1));
    });

    test('UA = 0% when all standby', () {
      final session = makeSession(hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T08:00:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.ua, closeTo(0.0, 0.1));
    });

    test('PA and UA are null when totalShiftSeconds is 0', () {
      final session = makeSession(hmEnd: 1050.0);
      final summary = calculator.calculate([], session);

      expect(summary.pa, isNull);
      expect(summary.ua, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // HM VALUES
  // ═════════════════════════════════════════════════════════════════════

  group('HM values', () {
    test('totalDeltaHm = hmEnd - hmStart', () {
      final session = makeSession(hmStart: 1000.0, hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T08:00:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.hmStart, 1000.0);
      expect(summary.hmEnd, 1050.0);
      expect(summary.totalDeltaHm, 50.0);
    });

    test('totalDeltaHm is null when hmEnd is null', () {
      final session = makeSession(hmStart: 1000.0, hmEnd: null);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.totalDeltaHm, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // COUNTS
  // ═════════════════════════════════════════════════════════════════════

  group('loading and hauling counts', () {
    test('counts loading and hauling ACTIVITY_STARTED events', () {
      final session = makeSession(hmEnd: 1100.0);
      final events = [
        // loading
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'L1'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T07:00:00.000'),
        // hauling
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'hauling',
            haulingCode: 'H1'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
        // dumping (no count)
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T08:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'dumping'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        // loading again
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'L2'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T10:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T10:00:00.000',
            hmEnd: 1100.0),
      ];

      final summary = calculator.calculate(events, session);

      expect(summary.loadingCountTotal, 2);
      expect(summary.haulingCountTotal, 1);
    });

    test('zero counts for non-loading/hauling shift', () {
      final session = makeSession(hmEnd: 1050.0);
      final events = [
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:00:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T08:00:00.000',
            hmEnd: 1050.0),
      ];

      final summary = calculator.calculate(events, session);
      expect(summary.loadingCountTotal, 0);
      expect(summary.haulingCountTotal, 0);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // FULL FLOW (matches event flow examples)
  // ═════════════════════════════════════════════════════════════════════

  group('full flow scenarios', () {
    test('Flow A - standard productive flow', () {
      // Matches 09_EVENT_FLOW.md §3 Flow A
      final session = makeSession(hmEnd: 1080.0);
      final events = [
        makeEvent(
            eventName: 'SHIFT_STARTED',
            occurredAt: '2026-03-31T06:00:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T06:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'LDR-201'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T07:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T07:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'hauling',
            haulingCode: 'HL-088'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T08:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T08:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'dumping'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'waiting'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'loading',
            loaderCode: 'EX202'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T10:30:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T10:30:00.000',
            hmEnd: 1080.0),
      ];

      final summary = calculator.calculate(events, session);

      // standby: 30m + 30m = 3600s
      expect(summary.totalStandbySeconds, 3600);
      // operation: 1h + 1h + 30m + 1h = 12600s
      expect(summary.totalOperationSeconds, 12600);
      expect(summary.totalDelaySeconds, 0);
      expect(summary.totalBreakdownSeconds, 0);
      // total: 4.5h = 16200s
      expect(summary.totalShiftSeconds, 16200);

      // PA = 100% (no breakdown)
      expect(summary.pa, closeTo(100.0, 0.1));
      // UA = 12600 / 16200 * 100 ≈ 77.8%
      expect(summary.ua, closeTo(77.8, 0.1));

      // Counts
      expect(summary.loadingCountTotal, 2);
      expect(summary.haulingCountTotal, 1);

      // HM
      expect(summary.totalDeltaHm, 80.0);
    });

    test('Flow B - breakdown during shift', () {
      // Matches 09_EVENT_FLOW.md §4 Flow B
      final session = makeSession(hmEnd: 1040.0);
      final events = [
        makeEvent(
            eventName: 'SHIFT_STARTED',
            occurredAt: '2026-03-31T06:00:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'changeShift'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T06:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T06:30:00.000',
            activityCategory: 'operation',
            activitySubtype: 'hauling',
            haulingCode: 'TRIP12'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T07:30:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T07:30:00.000',
            activityCategory: 'breakdown',
            activitySubtype: 'engine'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:00:00.000'),
        makeEvent(
            eventName: 'ACTIVITY_STARTED',
            occurredAt: '2026-03-31T09:00:00.000',
            activityCategory: 'standby',
            activitySubtype: 'refueling'),
        makeEvent(
            eventName: 'ACTIVITY_ENDED',
            occurredAt: '2026-03-31T09:30:00.000'),
        makeEvent(
            eventName: 'SHIFT_ENDED',
            occurredAt: '2026-03-31T09:30:00.000',
            hmEnd: 1040.0),
      ];

      final summary = calculator.calculate(events, session);

      // standby: 30m + 30m = 3600s
      expect(summary.totalStandbySeconds, 3600);
      // operation: 1h = 3600s
      expect(summary.totalOperationSeconds, 3600);
      // delay: 0
      expect(summary.totalDelaySeconds, 0);
      // breakdown: 1.5h = 5400s
      expect(summary.totalBreakdownSeconds, 5400);
      // total: 3.5h = 12600s
      expect(summary.totalShiftSeconds, 12600);

      // PA = (12600 - 5400) / 12600 * 100 ≈ 57.1%
      expect(summary.pa, closeTo(57.14, 0.1));
      // UA = 3600 / (12600 - 5400) * 100 = 3600/7200 = 50%
      expect(summary.ua, closeTo(50.0, 0.1));

      // Counts
      expect(summary.loadingCountTotal, 0);
      expect(summary.haulingCountTotal, 1);
    });
  });
}
