import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ptba_mdt/app/providers.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/features/shift/shift_state.dart';

import 'mocks/mock_repositories.dart';

void main() {
  late ProviderContainer container;
  late MockShiftRepository mockShiftRepo;
  late MockActivityEventRepository mockEventRepo;
  late MockOperatorActivityApi mockOperatorActivityApi;

  setUp(() {
    mockShiftRepo = MockShiftRepository();
    mockEventRepo = MockActivityEventRepository();
    mockOperatorActivityApi = MockOperatorActivityApi();
    container = ProviderContainer(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(mockShiftRepo),
        activityEventRepositoryProvider.overrideWithValue(mockEventRepo),
        operatorActivityApiProvider.overrideWithValue(mockOperatorActivityApi),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  ShiftState readState() => container.read(shiftControllerProvider);
  ShiftController readNotifier() =>
      container.read(shiftControllerProvider.notifier);

  // ═════════════════════════════════════════════════════════════════════
  // START SHIFT
  // ═════════════════════════════════════════════════════════════════════

  group('startShift', () {
    test('creates SHIFT_STARTED + ACTIVITY_STARTED events', () async {
      final success = await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      expect(success, isTrue);

      final events = mockEventRepo.storedEvents;
      expect(events.length, 2);
      expect(events[0].eventName, 'SHIFT_STARTED');
      expect(events[1].eventName, 'ACTIVITY_STARTED');
    });

    test('SHIFT_STARTED comes before ACTIVITY_STARTED', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final events = mockEventRepo.storedEvents;
      expect(events[0].eventName, 'SHIFT_STARTED');
      expect(events[1].eventName, 'ACTIVITY_STARTED');
      // Append order is preserved in the list
    });

    test('auto-starts standby/changeShift (no idle state)', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final state = readState();
      expect(state.isActive, isTrue);
      expect(state.currentCategory, 'standby');
      expect(state.currentSubtype, 'changeShift');
      expect(state.currentActivityStartedAt, isNotNull);
    });

    test('both events share same timestamp', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final events = mockEventRepo.storedEvents;
      expect(events[0].occurredAt, events[1].occurredAt);
    });

    test('SHIFT_STARTED carries hmStart', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1234.5,
      );

      final shiftStarted = mockEventRepo.storedEvents[0];
      expect(shiftStarted.hmStart, 1234.5);
    });

    test('ACTIVITY_STARTED carries category/subtype', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final actStarted = mockEventRepo.storedEvents[1];
      expect(actStarted.activityCategory, 'standby');
      expect(actStarted.activitySubtype, 'changeShift');
    });

    test('ShiftSession is persisted with correct fields', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final session = mockShiftRepo.stored;
      expect(session, isNotNull);
      expect(session!.unitId, 'HD-001');
      expect(session.operatorId, 'OP-001');
      expect(session.hmStart, 1000.0);
      expect(session.status, 'active');
      expect(session.hmEnd, isNull);
      expect(session.endedAt, isNull);
    });

    test('all events have unique eventIds', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final events = mockEventRepo.storedEvents;
      final ids = events.map((e) => e.eventId).toSet();
      expect(ids.length, events.length, reason: 'All eventIds must be unique');
    });

    test('all events carry correct shiftSessionId', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final session = mockShiftRepo.stored!;
      final events = mockEventRepo.storedEvents;
      for (final event in events) {
        expect(event.shiftSessionId, session.shiftSessionId);
      }
    });

    test('posts start shift payload to operator API', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1234.5,
      );

      expect(mockOperatorActivityApi.calls, hasLength(1));
      expect(mockOperatorActivityApi.calls.first.action, 'startShift');
      expect(mockOperatorActivityApi.calls.first.payload, {
        'unitId': 'HD-001',
        'operatorId': 'OP-001',
        'hmStart': 1234.5,
      });
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // SWITCH ACTIVITY
  // ═════════════════════════════════════════════════════════════════════

  group('switchActivity', () {
    Future<void> startShiftFirst() async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
    }

    test('creates ACTIVITY_ENDED + ACTIVITY_STARTED', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      final success = await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-001',
      );

      expect(success, isTrue);
      final events = mockEventRepo.storedEvents;
      expect(events.length, eventsBefore + 2);
      expect(events[eventsBefore].eventName, 'ACTIVITY_ENDED');
      expect(events[eventsBefore + 1].eventName, 'ACTIVITY_STARTED');
    });

    test('ACTIVITY_ENDED and ACTIVITY_STARTED share same timestamp', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-001',
      );

      final events = mockEventRepo.storedEvents;
      final endedAt = events[eventsBefore].occurredAt;
      final startedAt = events[eventsBefore + 1].occurredAt;
      expect(endedAt, startedAt);
    });

    test('ACTIVITY_ENDED carries the PREVIOUS category/subtype', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-001',
      );

      final endEvent = mockEventRepo.storedEvents[eventsBefore];
      expect(endEvent.activityCategory, 'standby');
      expect(endEvent.activitySubtype, 'changeShift');
    });

    test('ACTIVITY_STARTED carries the NEW category/subtype', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-001',
      );

      final startEvent = mockEventRepo.storedEvents[eventsBefore + 1];
      expect(startEvent.activityCategory, 'operation');
      expect(startEvent.activitySubtype, 'loading');
    });

    test('loaderCode is on ACTIVITY_STARTED for loading', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-201',
      );

      final startEvent = mockEventRepo.storedEvents.last;
      expect(startEvent.loaderCode, 'LDR-201');
      expect(startEvent.haulingCode, isNull);
    });

    test('haulingCode is on ACTIVITY_STARTED for hauling', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'hauling',
        haulingCode: 'HL-088',
      );

      final startEvent = mockEventRepo.storedEvents.last;
      expect(startEvent.haulingCode, 'HL-088');
      expect(startEvent.loaderCode, isNull);
    });

    test('dumping has no codes', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'dumping',
      );

      final startEvent = mockEventRepo.storedEvents.last;
      expect(startEvent.loaderCode, isNull);
      expect(startEvent.haulingCode, isNull);
    });

    test('state updated to new category/subtype after switch', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'delay',
        newSubtype: 'rain',
      );

      final state = readState();
      expect(state.currentCategory, 'delay');
      expect(state.currentSubtype, 'rain');
      expect(state.isActive, isTrue);
      expect(state.currentLoaderCode, isNull);
      expect(state.currentHaulingCode, isNull);
    });

    test('state carries loaderCode after switching to loading', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-201',
      );

      final state = readState();
      expect(state.currentLoaderCode, 'LDR-201');
      expect(state.currentHaulingCode, isNull);
    });

    test('state carries haulingCode after switching to hauling', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'hauling',
        haulingCode: 'HL-088',
      );

      final state = readState();
      expect(state.currentHaulingCode, 'HL-088');
      expect(state.currentLoaderCode, isNull);
    });

    test('codes cleared when switching to non-code activity', () async {
      await startShiftFirst();

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-201',
      );
      await readNotifier().switchActivity(
        newCategory: 'standby',
        newSubtype: 'break',
      );

      final state = readState();
      expect(state.currentLoaderCode, isNull);
      expect(state.currentHaulingCode, isNull);
    });

    test('currentActivityStartedAt updates on switch', () async {
      await startShiftFirst();
      final beforeSwitch = readState().currentActivityStartedAt;

      // Tiny delay to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 10));

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'dumping',
      );

      final afterSwitch = readState().currentActivityStartedAt;
      expect(afterSwitch, isNot(beforeSwitch));
    });

    test('posts switch activity payload to operator API', () async {
      await startShiftFirst();
      final shiftSessionId = readState().shiftSession!.shiftSessionId;

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'hauling',
        haulingCode: 'HL-088',
      );

      expect(mockOperatorActivityApi.calls.last.action, 'switchActivity');
      expect(mockOperatorActivityApi.calls.last.payload, {
        'shiftSessionId': shiftSessionId,
        'nextActivityCategory': 'operation',
        'nextActivitySubtype': 'hauling',
        'loaderCode': null,
        'haulingCode': 'HL-088',
      });
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // SAME SUBTYPE = NO-OP
  // ═════════════════════════════════════════════════════════════════════

  group('same subtype no-op', () {
    test('same subtype tapped returns false', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final result = await readNotifier().switchActivity(
        newCategory: 'standby',
        newSubtype: 'changeShift', // same as current
      );

      expect(result, isFalse);
    });

    test('same subtype does NOT generate any events', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      final countBefore = mockEventRepo.storedEvents.length;

      await readNotifier().switchActivity(
        newCategory: 'standby',
        newSubtype: 'changeShift',
      );

      expect(mockEventRepo.storedEvents.length, countBefore);
    });

    test('state is unchanged after same subtype tap', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      final stateBefore = readState();

      await readNotifier().switchActivity(
        newCategory: 'standby',
        newSubtype: 'changeShift',
      );

      final stateAfter = readState();
      expect(stateAfter.currentCategory, stateBefore.currentCategory);
      expect(stateAfter.currentSubtype, stateBefore.currentSubtype);
      expect(
        stateAfter.currentActivityStartedAt,
        stateBefore.currentActivityStartedAt,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // EDGE CASES
  // ═════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('switchActivity returns false when no active shift', () async {
      // No shift started
      final result = await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
      );
      expect(result, isFalse);
    });

    test('switchActivity returns false when isActive is false', () async {
      // Simulate non-active state
      final state = readState();
      expect(state.isActive, isFalse);

      final result = await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
      );
      expect(result, isFalse);
    });

    test('rapid sequential switches produce correct event order', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      // Multiple rapid switches
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'hauling',
        haulingCode: 'H1',
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'dumping',
      );

      final events = mockEventRepo.storedEvents;
      // Start: SHIFT_STARTED, ACTIVITY_STARTED
      // Switch 1: ACTIVITY_ENDED, ACTIVITY_STARTED (loading)
      // Switch 2: ACTIVITY_ENDED, ACTIVITY_STARTED (hauling)
      // Switch 3: ACTIVITY_ENDED, ACTIVITY_STARTED (dumping)
      expect(events.length, 8);

      final names = events.map((e) => e.eventName).toList();
      expect(names, [
        'SHIFT_STARTED',
        'ACTIVITY_STARTED', // changeShift
        'ACTIVITY_ENDED', // end changeShift
        'ACTIVITY_STARTED', // loading
        'ACTIVITY_ENDED', // end loading
        'ACTIVITY_STARTED', // hauling
        'ACTIVITY_ENDED', // end hauling
        'ACTIVITY_STARTED', // dumping
      ]);
    });

    test('only one active activity exists at any time', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      // Verify: exactly one active activity via repository logic
      final events = mockEventRepo.storedEvents;
      int openCount = 0;
      for (final e in events) {
        if (e.eventName == 'ACTIVITY_STARTED') openCount++;
        if (e.eventName == 'ACTIVITY_ENDED') openCount--;
      }
      expect(openCount, 1, reason: 'Exactly one activity should be open');
    });

    test('event sequence has no invalid patterns', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );
      await readNotifier().switchActivity(
        newCategory: 'standby',
        newSubtype: 'break',
      );

      final events = mockEventRepo.storedEvents;

      // Validate: no two consecutive ACTIVITY_STARTED without ACTIVITY_ENDED
      String? lastEvent;
      for (final e in events) {
        if (e.eventName == 'ACTIVITY_STARTED' &&
            lastEvent == 'ACTIVITY_STARTED') {
          // This is only valid right after SHIFT_STARTED
          fail('Two consecutive ACTIVITY_STARTED without ACTIVITY_ENDED');
        }
        if (e.eventName == 'ACTIVITY_ENDED' && lastEvent == 'ACTIVITY_ENDED') {
          fail('Two consecutive ACTIVITY_ENDED');
        }
        if (e.eventName == 'ACTIVITY_STARTED' ||
            e.eventName == 'ACTIVITY_ENDED') {
          lastEvent = e.eventName;
        }
      }
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // STATE RESTORATION
  // ═════════════════════════════════════════════════════════════════════

  group('restoreShift', () {
    test('restores active shift and current activity', () async {
      // Start shift, switch activity, then create new container to simulate restart
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      // Create fresh container (simulate app restart)
      container.dispose();
      container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(mockShiftRepo),
          activityEventRepositoryProvider.overrideWithValue(mockEventRepo),
        ],
      );

      // Restore
      await readNotifier().restoreShift();

      final state = readState();
      expect(state.isActive, isTrue);
      expect(state.shiftSession, isNotNull);
      expect(state.shiftSession!.unitId, 'HD-001');
      expect(state.currentCategory, 'operation');
      expect(state.currentSubtype, 'loading');
      expect(state.currentActivityStartedAt, isNotNull);
      expect(state.currentLoaderCode, 'L1');
      expect(state.currentHaulingCode, isNull);
    });

    test('returns initial state when no active shift exists', () async {
      await readNotifier().restoreShift();

      final state = readState();
      expect(state.isActive, isFalse);
      expect(state.shiftSession, isNull);
      expect(state.currentCategory, isNull);
    });

    test('does NOT auto-create new shift', () async {
      await readNotifier().restoreShift();

      expect(mockShiftRepo.stored, isNull);
      expect(mockEventRepo.storedEvents, isEmpty);
    });

    test('preserves timer source (currentActivityStartedAt)', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      final originalStartedAt = readState().currentActivityStartedAt;

      // Simulate restart
      container.dispose();
      container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(mockShiftRepo),
          activityEventRepositoryProvider.overrideWithValue(mockEventRepo),
        ],
      );

      await readNotifier().restoreShift();

      expect(readState().currentActivityStartedAt, originalStartedAt);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // DATA INTEGRITY
  // ═════════════════════════════════════════════════════════════════════

  group('data integrity', () {
    test('all events carry source = MDT', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      for (final event in mockEventRepo.storedEvents) {
        expect(event.source, 'MDT');
      }
    });

    test('timestamps are valid ISO 8601', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );

      for (final event in mockEventRepo.storedEvents) {
        expect(
          () => DateTime.parse(event.occurredAt),
          returnsNormally,
          reason: 'occurredAt must be valid ISO 8601',
        );
      }
    });

    test('timestamps are non-decreasing', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'dumping',
      );

      final events = mockEventRepo.storedEvents;
      for (int i = 1; i < events.length; i++) {
        final prev = DateTime.parse(events[i - 1].occurredAt);
        final curr = DateTime.parse(events[i].occurredAt);
        expect(
          curr.isAfter(prev) || curr.isAtSameMomentAs(prev),
          isTrue,
          reason: 'Event $i timestamp must be >= event ${i - 1}',
        );
      }
    });

    test('shiftSessionId is consistent across all events', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      final sessionId = mockShiftRepo.stored!.shiftSessionId;
      for (final event in mockEventRepo.storedEvents) {
        expect(event.shiftSessionId, sessionId);
      }
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // END SHIFT
  // ═════════════════════════════════════════════════════════════════════

  group('endShift', () {
    Future<void> startShiftFirst() async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
    }

    test('creates ACTIVITY_ENDED + SHIFT_ENDED events', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      final success = await readNotifier().endShift(hmEnd: 1050.0);

      expect(success, isTrue);
      final events = mockEventRepo.storedEvents;
      expect(events.length, eventsBefore + 2);
      expect(events[eventsBefore].eventName, 'ACTIVITY_ENDED');
      expect(events[eventsBefore + 1].eventName, 'SHIFT_ENDED');
    });

    test('ACTIVITY_ENDED and SHIFT_ENDED share same timestamp', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      await readNotifier().endShift(hmEnd: 1050.0);

      final events = mockEventRepo.storedEvents;
      expect(
        events[eventsBefore].occurredAt,
        events[eventsBefore + 1].occurredAt,
      );
    });

    test('ACTIVITY_ENDED carries the current activity info', () async {
      await startShiftFirst();

      // Switch to loading first
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'LDR-100',
      );

      final eventsBefore = mockEventRepo.storedEvents.length;
      await readNotifier().endShift(hmEnd: 1050.0);

      final endEvent = mockEventRepo.storedEvents[eventsBefore];
      expect(endEvent.activityCategory, 'operation');
      expect(endEvent.activitySubtype, 'loading');
    });

    test('SHIFT_ENDED carries hmEnd', () async {
      await startShiftFirst();

      await readNotifier().endShift(hmEnd: 1234.5);

      final shiftEndedEvent = mockEventRepo.storedEvents.last;
      expect(shiftEndedEvent.eventName, 'SHIFT_ENDED');
      expect(shiftEndedEvent.hmEnd, 1234.5);
    });

    test('updates ShiftSession with hmEnd, endedAt, status=ended', () async {
      await startShiftFirst();

      await readNotifier().endShift(hmEnd: 1050.0);

      final session = mockShiftRepo.stored!;
      expect(session.hmEnd, 1050.0);
      expect(session.endedAt, isNotNull);
      expect(session.status, 'ended');
    });

    test('sets isActive=false and isEnded=true', () async {
      await startShiftFirst();

      await readNotifier().endShift(hmEnd: 1050.0);

      final state = readState();
      expect(state.isActive, isFalse);
      expect(state.isEnded, isTrue);
    });

    test('clears current activity state', () async {
      await startShiftFirst();

      await readNotifier().endShift(hmEnd: 1050.0);

      final state = readState();
      expect(state.currentCategory, isNull);
      expect(state.currentSubtype, isNull);
      expect(state.currentActivityStartedAt, isNull);
    });

    test('rejects hmEnd < hmStart', () async {
      await startShiftFirst();
      final eventsBefore = mockEventRepo.storedEvents.length;

      final success = await readNotifier().endShift(hmEnd: 999.0);

      expect(success, isFalse);
      expect(
        mockEventRepo.storedEvents.length,
        eventsBefore,
        reason: 'No events should be generated',
      );
      expect(
        readState().isActive,
        isTrue,
        reason: 'Shift should remain active',
      );
    });

    test('accepts hmEnd == hmStart', () async {
      await startShiftFirst();

      final success = await readNotifier().endShift(hmEnd: 1000.0);

      expect(success, isTrue);
      expect(readState().isEnded, isTrue);
    });

    test('rejects when shift is not active', () async {
      // No shift started
      final result = await readNotifier().endShift(hmEnd: 1050.0);
      expect(result, isFalse);
    });

    test('does not introduce idle state (no gap before SHIFT_ENDED)', () async {
      await startShiftFirst();
      await readNotifier().endShift(hmEnd: 1050.0);

      final events = mockEventRepo.storedEvents;
      // Verify: second-to-last event is ACTIVITY_ENDED, last is SHIFT_ENDED
      final secondToLast = events[events.length - 2];
      final last = events.last;
      expect(secondToLast.eventName, 'ACTIVITY_ENDED');
      expect(last.eventName, 'SHIFT_ENDED');
      // Same timestamp = no idle gap
      expect(secondToLast.occurredAt, last.occurredAt);
    });

    test('full flow event sequence is valid', () async {
      await startShiftFirst();

      // Switch to loading
      await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      // End shift
      await readNotifier().endShift(hmEnd: 1050.0);

      final names = mockEventRepo.storedEvents.map((e) => e.eventName).toList();
      expect(names, [
        'SHIFT_STARTED',
        'ACTIVITY_STARTED', // changeShift
        'ACTIVITY_ENDED', // end changeShift
        'ACTIVITY_STARTED', // loading
        'ACTIVITY_ENDED', // end loading
        'SHIFT_ENDED',
      ]);
    });

    test('all events carry correct shiftSessionId', () async {
      await startShiftFirst();
      await readNotifier().endShift(hmEnd: 1050.0);

      final sessionId = mockShiftRepo.stored!.shiftSessionId;
      for (final event in mockEventRepo.storedEvents) {
        expect(event.shiftSessionId, sessionId);
      }
    });

    test('cannot switch activity after end shift', () async {
      await startShiftFirst();
      await readNotifier().endShift(hmEnd: 1050.0);

      final result = await readNotifier().switchActivity(
        newCategory: 'operation',
        newSubtype: 'loading',
        loaderCode: 'L1',
      );

      expect(result, isFalse);
    });

    test('cannot end shift twice', () async {
      await startShiftFirst();
      await readNotifier().endShift(hmEnd: 1050.0);

      final result = await readNotifier().endShift(hmEnd: 1100.0);
      expect(result, isFalse);
    });

    test('posts end shift payload to operator API', () async {
      await startShiftFirst();
      final shiftSessionId = readState().shiftSession!.shiftSessionId;

      await readNotifier().endShift(hmEnd: 1050.0);

      expect(mockOperatorActivityApi.calls.last.action, 'endShift');
      expect(mockOperatorActivityApi.calls.last.payload, {
        'shiftSessionId': shiftSessionId,
        'hmEnd': 1050.0,
      });
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // RESTORE ENDED SHIFT
  // ═════════════════════════════════════════════════════════════════════

  group('restoreShift - ended state', () {
    test('restores ended shift with isEnded=true', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().endShift(hmEnd: 1050.0);

      // Simulate app restart
      container.dispose();
      container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(mockShiftRepo),
          activityEventRepositoryProvider.overrideWithValue(mockEventRepo),
        ],
      );

      await readNotifier().restoreShift();

      final state = readState();
      expect(state.isEnded, isTrue);
      expect(state.isActive, isFalse);
      expect(state.shiftSession, isNotNull);
      expect(state.shiftSession!.hmEnd, 1050.0);
      expect(state.shiftSession!.status, 'ended');
    });

    test('ended shift has no current activity', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().endShift(hmEnd: 1050.0);

      container.dispose();
      container = ProviderContainer(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(mockShiftRepo),
          activityEventRepositoryProvider.overrideWithValue(mockEventRepo),
        ],
      );

      await readNotifier().restoreShift();

      final state = readState();
      expect(state.currentCategory, isNull);
      expect(state.currentSubtype, isNull);
      expect(state.currentActivityStartedAt, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════
  // RESET FOR NEW SHIFT
  // ═════════════════════════════════════════════════════════════════════

  group('resetForNewShift', () {
    test('clears session and events', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().endShift(hmEnd: 1050.0);

      await readNotifier().resetForNewShift();

      expect(mockShiftRepo.stored, isNull);
      expect(mockEventRepo.storedEvents, isEmpty);
    });

    test('returns to initial state', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().endShift(hmEnd: 1050.0);

      await readNotifier().resetForNewShift();

      final state = readState();
      expect(state.isActive, isFalse);
      expect(state.isEnded, isFalse);
      expect(state.shiftSession, isNull);
      expect(state.currentCategory, isNull);
    });

    test('allows starting a new shift after reset', () async {
      await readNotifier().startShift(
        unitId: 'HD-001',
        operatorId: 'OP-001',
        hmStart: 1000.0,
      );
      await readNotifier().endShift(hmEnd: 1050.0);
      await readNotifier().resetForNewShift();

      final success = await readNotifier().startShift(
        unitId: 'HD-002',
        operatorId: 'OP-002',
        hmStart: 2000.0,
      );

      expect(success, isTrue);
      expect(readState().isActive, isTrue);
      expect(readState().shiftSession!.unitId, 'HD-002');
    });
  });
}
