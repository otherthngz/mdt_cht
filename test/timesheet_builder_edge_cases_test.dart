import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/services/timesheet_builder.dart';

/// Edge-case tests for TimesheetBuilder — covers data integrity scenarios
/// that go beyond the happy-path tests in timesheet_builder_test.dart.
void main() {
  late TimesheetBuilder builder;

  setUp(() {
    builder = TimesheetBuilder();
  });

  ShiftSession makeSession({double? hmEnd}) => ShiftSession(
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        shiftDate: '2026-03-31',
        hmStart: 1000.0,
        hmEnd: hmEnd,
        startedAt: '2026-03-31T07:00:00.000',
        status: 'active',
      );

  ActivityEvent makeEvent({
    required String eventName,
    required String occurredAt,
    String? activityCategory,
    String? activitySubtype,
    String? loaderCode,
    String? haulingCode,
  }) =>
      ActivityEvent(
        eventId: 'evt-${occurredAt.hashCode}-$eventName',
        eventName: eventName,
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        occurredAt: occurredAt,
        activityCategory: activityCategory,
        activitySubtype: activitySubtype,
        loaderCode: loaderCode,
        haulingCode: haulingCode,
      );

  group('TimesheetBuilder edge cases', () {
    test('orphan ACTIVITY_ENDED (no matching STARTED) is ignored gracefully', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:10:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows, isEmpty, reason: 'No STARTED → no rows');
    });

    test('extra ACTIVITY_ENDED after all rows are closed is ignored', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:10:00.000'),
        // Shouldn't match anything:
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:15:00.000'),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 1);
      expect(rows[0].endTime, '2026-03-31T07:10:00.000');
      expect(rows[0].durationSeconds, 600);
    });

    test('timestamp collision (same start and end) produces 0 duration', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:00:00.000'),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 1);
      expect(rows[0].durationSeconds, 0);
      expect(rows[0].isActive, isFalse);
    });

    test('multiple rapid switches with same timestamps pair correctly', () {
      // Simulates very rapid switching where timestamps could collide
      final ts = '2026-03-31T07:00:00.000';
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: ts,
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: ts),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: ts,
            activityCategory: 'operation', activitySubtype: 'loading',
            loaderCode: 'L1'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: ts),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: ts,
            activityCategory: 'operation', activitySubtype: 'dumping'),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 3);
      expect(rows[0].category, 'standby');
      expect(rows[0].durationSeconds, 0);
      expect(rows[0].isActive, isFalse);
      expect(rows[1].category, 'operation');
      expect(rows[1].activity, 'loading');
      expect(rows[1].durationSeconds, 0);
      expect(rows[1].isActive, isFalse);
      expect(rows[2].activity, 'dumping');
      expect(rows[2].isActive, isTrue);
    });

    test('null hmEnd means all HM fields are null', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:30:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:30:00.000',
            activityCategory: 'operation', activitySubtype: 'loading',
            loaderCode: 'L1'),
      ];

      final rows = builder.build(events, makeSession(hmEnd: null));
      for (final row in rows) {
        expect(row.hmStartDerived, isNull);
        expect(row.hmEndDerived, isNull);
        expect(row.deltaHmDerived, isNull);
      }
    });

    test('single row with hmEnd derives HM covering full range', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T08:00:00.000'),
      ];

      final rows = builder.build(events, makeSession(hmEnd: 1010.0));
      expect(rows.length, 1);
      expect(rows[0].hmStartDerived, closeTo(1000.0, 0.01));
      expect(rows[0].hmEndDerived, closeTo(1010.0, 0.01));
      expect(rows[0].deltaHmDerived, closeTo(10.0, 0.01));
    });

    test('counts only increment on loading or hauling (not other subtypes)', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:05:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:05:00.000',
            activityCategory: 'operation', activitySubtype: 'dumping'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:10:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:10:00.000',
            activityCategory: 'delay', activitySubtype: 'rain'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:15:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:15:00.000',
            activityCategory: 'breakdown', activitySubtype: 'engine'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:20:00.000'),
      ];

      final rows = builder.build(events, makeSession());
      // None of these are loading or hauling, so counts stay 0
      for (final row in rows) {
        expect(row.loadingCount, 0);
        expect(row.haulingCount, 0);
      }
    });

    test('rowId format is shiftSessionId_index', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:05:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:05:00.000',
            activityCategory: 'operation', activitySubtype: 'loading',
            loaderCode: 'L1'),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows[0].rowId, 'shift-1_0');
      expect(rows[1].rowId, 'shift-1_1');
    });

    test('all rows share same shiftSessionId', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:05:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:05:00.000',
            activityCategory: 'operation', activitySubtype: 'loading',
            loaderCode: 'L1'),
      ];

      final rows = builder.build(events, makeSession());
      for (final row in rows) {
        expect(row.shiftSessionId, 'shift-1');
      }
    });

    test('mid-activity active row has correct startTime preserved', () {
      final events = [
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:10:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:10:00.000',
            activityCategory: 'operation', activitySubtype: 'loading',
            loaderCode: 'L1'),
        // No ACTIVITY_ENDED → simulates app restart mid-activity
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 2);
      expect(rows[1].isActive, isTrue);
      expect(rows[1].startTime, '2026-03-31T07:10:00.000');
      expect(rows[1].endTime, isNull);
      expect(rows[1].durationSeconds, isNull);
      // Timer can be derived from startTime in UI
    });
  });
}
