import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:ptba_mdt/app/providers.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/enums.dart';
import 'package:ptba_mdt/domain/repositories/shift_repository.dart';
import 'package:ptba_mdt/domain/repositories/activity_event_repository.dart';
import 'package:ptba_mdt/domain/services/operator_activity_api.dart';
import 'package:ptba_mdt/features/shift/shift_state.dart';

const _uuid = Uuid();

/// ShiftController — Riverpod Notifier handling Start Shift flow.
/// Per 06_ARCHITECTURE.md §4.3 and §5.1.
///
/// Event order for Start Shift is strictly:
///   1. SHIFT_STARTED
///   2. ACTIVITY_STARTED (standby/changeShift)
class ShiftController extends Notifier<ShiftState> {
  late ShiftRepository _shiftRepo;
  late ActivityEventRepository _eventRepo;
  late OperatorActivityApi _operatorActivityApi;

  @override
  ShiftState build() {
    _shiftRepo = ref.read(shiftRepositoryProvider);
    _eventRepo = ref.read(activityEventRepositoryProvider);
    _operatorActivityApi = ref.read(operatorActivityApiProvider);
    return const ShiftState.initial();
  }

  void _dispatchRemote(Future<void> Function() request) {
    // Remote sync must never break the local shift flow.
    unawaited(() async {
      try {
        await request();
      } catch (_) {}
    }());
  }

  /// Restore shift from Hive on app start.
  /// Per 10_PROMPT.md §7 — do NOT auto-create new shift.
  Future<void> restoreShift() async {
    state = state.copyWith(isLoading: true);

    try {
      final session = await _shiftRepo.getLatestShiftSession();
      if (session == null) {
        state = const ShiftState.initial();
        return;
      }

      // Handle ended shift — restore to ended state.
      if (session.status == ShiftStatus.ended.name) {
        state = ShiftState(
          shiftSession: session,
          isActive: false,
          isEnded: true,
        );
        return;
      }

      // Restore current activity from events.
      final activeActivity = await _eventRepo.getCurrentActiveActivity(
        session.shiftSessionId,
      );

      state = ShiftState(
        shiftSession: session,
        isActive: true,
        currentCategory: activeActivity?.activityCategory,
        currentSubtype: activeActivity?.activitySubtype,
        currentActivityStartedAt: activeActivity?.occurredAt,
        currentLoaderCode: activeActivity?.loaderCode,
        currentHaulingCode: activeActivity?.haulingCode,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Start Shift flow — per 06_ARCHITECTURE.md §5.1.
  ///
  /// 1. Create ShiftSession
  /// 2. Append SHIFT_STARTED event
  /// 3. Append ACTIVITY_STARTED event (standby/changeShift)
  /// 4. Persist to Hive
  /// 5. Update state
  Future<bool> startShift({
    required String unitId,
    required String operatorId,
    required double hmStart,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final now = DateTime.now().toIso8601String();
      final shiftSessionId = _uuid.v4();

      // 1. Create ShiftSession
      final session = ShiftSession(
        shiftSessionId: shiftSessionId,
        unitId: unitId,
        operatorId: operatorId,
        shiftDate: DateTime.now().toIso8601String().substring(0, 10),
        hmStart: hmStart,
        startedAt: now,
        status: ShiftStatus.active.name,
      );

      // 2. Append SHIFT_STARTED event
      final shiftStartedEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.SHIFT_STARTED.name,
        shiftSessionId: shiftSessionId,
        unitId: unitId,
        operatorId: operatorId,
        occurredAt: now,
        hmStart: hmStart,
      );

      // 3. Append ACTIVITY_STARTED event (standby/changeShift)
      final activityStartedEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.ACTIVITY_STARTED.name,
        shiftSessionId: shiftSessionId,
        unitId: unitId,
        operatorId: operatorId,
        occurredAt: now,
        activityCategory: ActivityCategory.standby.name,
        activitySubtype: ActivitySubtype.changeShift.name,
      );

      // 4. Persist — order matters
      await _shiftRepo.saveShiftSession(session);
      await _eventRepo.appendEvent(shiftStartedEvent);
      await _eventRepo.appendEvent(activityStartedEvent);

      // 5. Update state
      state = ShiftState(
        shiftSession: session,
        isActive: true,
        currentCategory: ActivityCategory.standby.name,
        currentSubtype: ActivitySubtype.changeShift.name,
        currentActivityStartedAt: now,
      );

      _dispatchRemote(() {
        return _operatorActivityApi.postStartShift(
          unitId: unitId,
          operatorId: operatorId,
          hmStart: hmStart,
        );
      });

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Switch Activity flow — per 06_ARCHITECTURE.md §5.2.
  ///
  /// Event order is strictly:
  ///   1. ACTIVITY_ENDED (current activity)
  ///   2. ACTIVITY_STARTED (new activity)
  ///
  /// Both events share the SAME timestamp.
  ///
  /// Returns true on success, false on error.
  /// Returns false (no-op) if new subtype == current subtype.
  Future<bool> switchActivity({
    required String newCategory,
    required String newSubtype,
    String? loaderCode,
    String? haulingCode,
  }) async {
    final session = state.shiftSession;
    if (session == null || !state.isActive) return false;

    // Same subtype tapped = no-op (per 03_STATE_MACHINE.md §5.2)
    if (newSubtype == state.currentSubtype) return false;

    try {
      // Shared timestamp for both events (per 10_PROMPT.md §3)
      final now = DateTime.now().toIso8601String();

      // 1. ACTIVITY_ENDED for current activity
      final endEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.ACTIVITY_ENDED.name,
        shiftSessionId: session.shiftSessionId,
        unitId: session.unitId,
        operatorId: session.operatorId,
        occurredAt: now,
        activityCategory: state.currentCategory,
        activitySubtype: state.currentSubtype,
      );

      // 2. ACTIVITY_STARTED for new activity
      final startEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.ACTIVITY_STARTED.name,
        shiftSessionId: session.shiftSessionId,
        unitId: session.unitId,
        operatorId: session.operatorId,
        occurredAt: now,
        activityCategory: newCategory,
        activitySubtype: newSubtype,
        loaderCode: loaderCode,
        haulingCode: haulingCode,
      );

      // Persist — order matters
      await _eventRepo.appendEvent(endEvent);
      await _eventRepo.appendEvent(startEvent);

      // Update state
      state = ShiftState(
        shiftSession: session,
        isActive: true,
        currentCategory: newCategory,
        currentSubtype: newSubtype,
        currentActivityStartedAt: now,
        currentLoaderCode: loaderCode,
        currentHaulingCode: haulingCode,
      );

      _dispatchRemote(() {
        return _operatorActivityApi.postSwitchActivity(
          shiftSessionId: session.shiftSessionId,
          nextActivityCategory: newCategory,
          nextActivitySubtype: newSubtype,
          loaderCode: loaderCode,
          haulingCode: haulingCode,
        );
      });

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// End Shift flow — per 06_ARCHITECTURE.md §5.3.
  ///
  /// Event order is strictly:
  ///   1. ACTIVITY_ENDED (current activity)
  ///   2. SHIFT_ENDED (with hmEnd)
  ///
  /// Both events share the SAME timestamp.
  ///
  /// Side effects:
  ///   - updates ShiftSession: hmEnd, endedAt, status = ended
  ///   - clears current activity
  ///   - sets isActive = false, isEnded = true
  Future<bool> endShift({required double hmEnd}) async {
    final session = state.shiftSession;
    if (session == null || !state.isActive) return false;

    // Validate: hmEnd >= hmStart
    if (hmEnd < session.hmStart) return false;

    try {
      // Shared timestamp for both events (per 10_PROMPT.md §3)
      final now = DateTime.now().toIso8601String();

      // 1. ACTIVITY_ENDED for current activity
      final endActivityEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.ACTIVITY_ENDED.name,
        shiftSessionId: session.shiftSessionId,
        unitId: session.unitId,
        operatorId: session.operatorId,
        occurredAt: now,
        activityCategory: state.currentCategory,
        activitySubtype: state.currentSubtype,
      );

      // 2. SHIFT_ENDED
      final shiftEndedEvent = ActivityEvent(
        eventId: _uuid.v4(),
        eventName: EventName.SHIFT_ENDED.name,
        shiftSessionId: session.shiftSessionId,
        unitId: session.unitId,
        operatorId: session.operatorId,
        occurredAt: now,
        hmEnd: hmEnd,
      );

      // Persist events — order matters
      await _eventRepo.appendEvent(endActivityEvent);
      await _eventRepo.appendEvent(shiftEndedEvent);

      // Update ShiftSession
      final updatedSession = ShiftSession(
        shiftSessionId: session.shiftSessionId,
        unitId: session.unitId,
        operatorId: session.operatorId,
        shiftDate: session.shiftDate,
        hmStart: session.hmStart,
        hmEnd: hmEnd,
        startedAt: session.startedAt,
        endedAt: now,
        status: ShiftStatus.ended.name,
      );
      await _shiftRepo.updateShiftSession(updatedSession);

      // Update state — no idle; shift goes directly to ended
      state = ShiftState(
        shiftSession: updatedSession,
        isActive: false,
        isEnded: true,
      );

      _dispatchRemote(() {
        return _operatorActivityApi.postEndShift(
          shiftSessionId: session.shiftSessionId,
          hmEnd: hmEnd,
        );
      });

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reset for a new shift — clears all persisted data.
  /// Used from ShiftEndedPage "Mulai Shift Baru" button.
  Future<void> resetForNewShift() async {
    final session = state.shiftSession;
    if (session != null) {
      await _eventRepo.clearEvents();
    }
    await _shiftRepo.clearShiftSession();
    state = const ShiftState.initial();
  }
}

// ──────────────────────────────────────────────────────────────────────
// Providers — kept in the same file for simplicity in Step 1.
// ──────────────────────────────────────────────────────────────────────

/// ShiftRepository provider.
final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  throw UnimplementedError(
    'shiftRepositoryProvider must be overridden in ProviderScope',
  );
});

/// ActivityEventRepository provider.
final activityEventRepositoryProvider = Provider<ActivityEventRepository>((
  ref,
) {
  throw UnimplementedError(
    'activityEventRepositoryProvider must be overridden in ProviderScope',
  );
});

/// ShiftController provider.
final shiftControllerProvider = NotifierProvider<ShiftController, ShiftState>(
  ShiftController.new,
);
