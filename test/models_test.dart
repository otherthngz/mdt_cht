import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/features/shift/shift_state.dart';

void main() {
  group('ShiftSession', () {
    test('required fields are set', () {
      final session = ShiftSession(
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        shiftDate: '2026-03-31',
        hmStart: 1000.0,
        startedAt: '2026-03-31T07:00:00.000',
        status: 'active',
      );
      expect(session.shiftSessionId, 'shift-1');
      expect(session.unitId, 'HD-001');
      expect(session.operatorId, 'OP-001');
      expect(session.hmStart, 1000.0);
      expect(session.hmEnd, isNull);
      expect(session.endedAt, isNull);
      expect(session.status, 'active');
    });

    test('copyWith creates new instance with overrides', () {
      final original = ShiftSession(
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        shiftDate: '2026-03-31',
        hmStart: 1000.0,
        startedAt: '2026-03-31T07:00:00.000',
        status: 'active',
      );

      final updated = original.copyWith(
        status: 'ended',
        hmEnd: 1010.0,
        endedAt: '2026-03-31T15:00:00.000',
      );

      expect(updated.status, 'ended');
      expect(updated.hmEnd, 1010.0);
      expect(updated.endedAt, '2026-03-31T15:00:00.000');
      // Unchanged fields remain
      expect(updated.shiftSessionId, 'shift-1');
      expect(updated.unitId, 'HD-001');
      expect(updated.hmStart, 1000.0);
    });

    test('hmStart is double (not int)', () {
      final session = ShiftSession(
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        shiftDate: '2026-03-31',
        hmStart: 1000.5,
        startedAt: '2026-03-31T07:00:00.000',
        status: 'active',
      );
      expect(session.hmStart, 1000.5);
    });
  });

  group('ActivityEvent', () {
    test('required fields are set', () {
      final event = ActivityEvent(
        eventId: 'evt-1',
        eventName: 'SHIFT_STARTED',
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        occurredAt: '2026-03-31T07:00:00.000',
      );
      expect(event.eventId, 'evt-1');
      expect(event.eventName, 'SHIFT_STARTED');
      expect(event.source, 'MDT');
      expect(event.activityCategory, isNull);
      expect(event.activitySubtype, isNull);
      expect(event.loaderCode, isNull);
      expect(event.haulingCode, isNull);
    });

    test('optional fields for ACTIVITY_STARTED', () {
      final event = ActivityEvent(
        eventId: 'evt-2',
        eventName: 'ACTIVITY_STARTED',
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        occurredAt: '2026-03-31T07:00:00.000',
        activityCategory: 'operation',
        activitySubtype: 'loading',
        loaderCode: 'LDR-201',
      );
      expect(event.activityCategory, 'operation');
      expect(event.activitySubtype, 'loading');
      expect(event.loaderCode, 'LDR-201');
      expect(event.haulingCode, isNull);
    });

    test('loaderCode and haulingCode are strings (alphanumeric)', () {
      final event = ActivityEvent(
        eventId: 'evt-3',
        eventName: 'ACTIVITY_STARTED',
        shiftSessionId: 'shift-1',
        unitId: 'HD-001',
        operatorId: 'OP-001',
        occurredAt: '2026-03-31T07:00:00.000',
        activityCategory: 'operation',
        activitySubtype: 'hauling',
        haulingCode: 'HL-088',
      );
      expect(event.haulingCode, 'HL-088');
      expect(event.haulingCode is String, isTrue);
    });
  });

  group('ShiftState', () {
    test('initial state has no shift', () {
      const state = ShiftState.initial();
      expect(state.shiftSession, isNull);
      expect(state.isActive, isFalse);
      expect(state.currentCategory, isNull);
      expect(state.currentSubtype, isNull);
      expect(state.currentActivityStartedAt, isNull);
      expect(state.currentLoaderCode, isNull);
      expect(state.currentHaulingCode, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith preserves non-overridden fields', () {
      final state = ShiftState(
        isActive: true,
        currentCategory: 'standby',
        currentSubtype: 'changeShift',
        currentActivityStartedAt: '2026-03-31T07:00:00.000',
      );

      final updated = state.copyWith(isLoading: true);
      expect(updated.isActive, isTrue); // preserved
      expect(updated.currentCategory, 'standby'); // preserved
      expect(updated.isLoading, isTrue); // changed
    });

    test('copyWith with error clears error when null', () {
      final state = ShiftState(error: 'something');
      final cleared = state.copyWith(); // error defaults to null
      expect(cleared.error, isNull);
    });
  });
}
