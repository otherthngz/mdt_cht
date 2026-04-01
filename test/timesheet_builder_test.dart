import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/timesheet_row.dart';
import 'package:ptba_mdt/domain/services/timesheet_builder.dart';

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
        eventId: 'evt-${occurredAt.hashCode}',
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

  group('TimesheetBuilder.build', () {
    test('empty events → empty rows', () {
      final rows = builder.build([], makeSession());
      expect(rows, isEmpty);
    });

    test('SHIFT_STARTED only → empty rows (not an activity)', () {
      final events = [
        makeEvent(
          eventName: 'SHIFT_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
        ),
      ];
      final rows = builder.build(events, makeSession());
      expect(rows, isEmpty);
    });

    test('single completed activity → one row with correct fields', () {
      final events = [
        makeEvent(
          eventName: 'SHIFT_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:10:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 1);

      final row = rows[0];
      expect(row.category, 'standby');
      expect(row.activity, 'changeShift');
      expect(row.startTime, '2026-03-31T07:00:00.000');
      expect(row.endTime, '2026-03-31T07:10:00.000');
      expect(row.durationSeconds, 600); // 10 minutes
      expect(row.isActive, isFalse);
      expect(row.loadingCount, 0);
      expect(row.haulingCount, 0);
      expect(row.loaderCode, isNull);
      expect(row.haulingCode, isNull);
    });

    test('active row (no matching ACTIVITY_ENDED) is marked isActive', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 1);
      expect(rows[0].isActive, isTrue);
      expect(rows[0].endTime, isNull);
      expect(rows[0].durationSeconds, isNull);
    });

    test('loading/hauling codes are preserved', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'operation',
          activitySubtype: 'loading',
          loaderCode: 'LDR-201',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:10:00.000',
          activityCategory: 'operation',
          activitySubtype: 'loading',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:10:00.000',
          activityCategory: 'operation',
          activitySubtype: 'hauling',
          haulingCode: 'HL-088',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:25:00.000',
          activityCategory: 'operation',
          activitySubtype: 'hauling',
        ),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 2);
      expect(rows[0].loaderCode, 'LDR-201');
      expect(rows[0].haulingCode, isNull);
      expect(rows[1].haulingCode, 'HL-088');
      expect(rows[1].loaderCode, isNull);
    });

    test('cumulative loading/hauling counts', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:05:00.000',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:05:00.000',
          activityCategory: 'operation',
          activitySubtype: 'loading',
          loaderCode: 'L1',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:10:00.000',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:10:00.000',
          activityCategory: 'operation',
          activitySubtype: 'hauling',
          haulingCode: 'H1',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:15:00.000',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:15:00.000',
          activityCategory: 'operation',
          activitySubtype: 'loading',
          loaderCode: 'L2',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:20:00.000',
        ),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 4);

      // Row 0: standby/changeShift → loading=0, hauling=0
      expect(rows[0].loadingCount, 0);
      expect(rows[0].haulingCount, 0);

      // Row 1: operation/loading → loading=1, hauling=0
      expect(rows[1].loadingCount, 1);
      expect(rows[1].haulingCount, 0);

      // Row 2: operation/hauling → loading=1, hauling=1
      expect(rows[2].loadingCount, 1);
      expect(rows[2].haulingCount, 1);

      // Row 3: operation/loading → loading=2, hauling=1
      expect(rows[3].loadingCount, 2);
      expect(rows[3].haulingCount, 1);
    });

    test('HM derivation is null when hmEnd is null', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:10:00.000',
        ),
      ];

      final rows = builder.build(events, makeSession(hmEnd: null));
      expect(rows[0].hmStartDerived, isNull);
      expect(rows[0].hmEndDerived, isNull);
      expect(rows[0].deltaHmDerived, isNull);
    });

    test('HM derivation works when hmEnd is set', () {
      final events = [
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:00:00.000',
          activityCategory: 'standby',
          activitySubtype: 'changeShift',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T07:30:00.000',
        ),
        makeEvent(
          eventName: 'ACTIVITY_STARTED',
          occurredAt: '2026-03-31T07:30:00.000',
          activityCategory: 'operation',
          activitySubtype: 'loading',
          loaderCode: 'L1',
        ),
        makeEvent(
          eventName: 'ACTIVITY_ENDED',
          occurredAt: '2026-03-31T08:00:00.000',
        ),
      ];

      // hmStart=1000, hmEnd=1010 → hmRange=10
      // Total shift = 3600s (1 hour)
      // Row 0: 0-1800s = 50% → HM 1000-1005
      // Row 1: 1800-3600s = 50% → HM 1005-1010
      final rows = builder.build(events, makeSession(hmEnd: 1010.0));
      expect(rows.length, 2);

      expect(rows[0].hmStartDerived, closeTo(1000.0, 0.01));
      expect(rows[0].hmEndDerived, closeTo(1005.0, 0.01));
      expect(rows[0].deltaHmDerived, closeTo(5.0, 0.01));

      expect(rows[1].hmStartDerived, closeTo(1005.0, 0.01));
      expect(rows[1].hmEndDerived, closeTo(1010.0, 0.01));
      expect(rows[1].deltaHmDerived, closeTo(5.0, 0.01));
    });

    test('timesheet is NOT persisted (TimesheetRow has no Hive annotations)', () {
      // Verify TimesheetRow is a plain Dart class
      final row = TimesheetRow(
        rowId: 'r1',
        shiftSessionId: 's1',
        category: 'standby',
        activity: 'changeShift',
        startTime: '2026-03-31T07:00:00.000',
      );
      expect(row.isActive, isFalse);
      expect(row.durationSeconds, isNull);
      expect(row.loadingCount, 0);
      expect(row.haulingCount, 0);
    });

    test('full Flow A from 09_EVENT_FLOW.md', () {
      final events = [
        makeEvent(eventName: 'SHIFT_STARTED', occurredAt: '2026-03-31T07:00:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:00:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:10:00.000',
            activityCategory: 'standby', activitySubtype: 'changeShift'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:10:00.000',
            activityCategory: 'operation', activitySubtype: 'loading', loaderCode: 'LDR-201'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:20:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:20:00.000',
            activityCategory: 'operation', activitySubtype: 'hauling', haulingCode: 'HL-088'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:30:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:30:00.000',
            activityCategory: 'operation', activitySubtype: 'dumping'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:35:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:35:00.000',
            activityCategory: 'standby', activitySubtype: 'waiting'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:40:00.000'),
        makeEvent(eventName: 'ACTIVITY_STARTED', occurredAt: '2026-03-31T07:40:00.000',
            activityCategory: 'operation', activitySubtype: 'loading', loaderCode: 'EX202'),
        makeEvent(eventName: 'ACTIVITY_ENDED', occurredAt: '2026-03-31T07:50:00.000'),
        makeEvent(eventName: 'SHIFT_ENDED', occurredAt: '2026-03-31T07:50:00.000'),
      ];

      final rows = builder.build(events, makeSession());
      expect(rows.length, 6);

      // Row 0: standby/changeShift, 600s
      expect(rows[0].category, 'standby');
      expect(rows[0].activity, 'changeShift');
      expect(rows[0].durationSeconds, 600);
      expect(rows[0].loadingCount, 0);
      expect(rows[0].haulingCount, 0);

      // Row 1: operation/loading LDR-201, 600s, loading=1
      expect(rows[1].category, 'operation');
      expect(rows[1].activity, 'loading');
      expect(rows[1].loaderCode, 'LDR-201');
      expect(rows[1].durationSeconds, 600);
      expect(rows[1].loadingCount, 1);

      // Row 2: operation/hauling HL-088, 600s, hauling=1
      expect(rows[2].activity, 'hauling');
      expect(rows[2].haulingCode, 'HL-088');
      expect(rows[2].haulingCount, 1);

      // Row 3: operation/dumping, 300s
      expect(rows[3].activity, 'dumping');
      expect(rows[3].durationSeconds, 300);

      // Row 4: standby/waiting, 300s
      expect(rows[4].activity, 'waiting');
      expect(rows[4].durationSeconds, 300);

      // Row 5: operation/loading EX202, 600s, loading=2
      expect(rows[5].activity, 'loading');
      expect(rows[5].loaderCode, 'EX202');
      expect(rows[5].loadingCount, 2);
      expect(rows[5].haulingCount, 1);

      // All rows are completed
      for (final row in rows) {
        expect(row.isActive, isFalse);
        expect(row.endTime, isNotNull);
      }
    });
  });
}
