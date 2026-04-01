import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_form_state.dart';

/// Manages transient form state across the 2-step Start Shift flow.
///
/// Responsibilities:
///   - Persist unitId / operatorId from Step 1 so Step 2 can read them.
///   - Fetch the last known hourmeter for the selected unit from storage.
///   - Reset state after a successful shift start.
class StartShiftFormController extends Notifier<StartShiftFormState> {
  @override
  StartShiftFormState build() => const StartShiftFormState();

  /// Saves Step 1 values. Call this before navigating to Step 2.
  void setStep1({required String unitId, required String operatorId}) {
    state = StartShiftFormState(unitId: unitId, operatorId: operatorId);
  }

  /// Fetches the last known hourmeter for [state.unitId] from the shift
  /// repository and updates [StartShiftFormState.lastHm].
  ///
  /// Source: the most recent [ShiftSession] stored in Hive.
  ///   - If the session's unitId matches → use hmEnd (preferred) or hmStart.
  ///   - Otherwise → lastHm remains null (no prefill).
  Future<void> fetchLastHm() async {
    if (state.unitId.isEmpty) return;

    // Signal loading — clear any stale lastHm from a previous unit.
    state = StartShiftFormState(
      unitId: state.unitId,
      operatorId: state.operatorId,
      isLoadingHm: true,
    );

    try {
      final session =
          await ref.read(shiftRepositoryProvider).getLatestShiftSession();

      double? lastHm;
      if (session != null && session.unitId == state.unitId) {
        // Prefer hmEnd (last reading at end-of-shift).
        // Fall back to hmStart when the prior shift was never ended.
        lastHm = session.hmEnd ?? session.hmStart;
      }

      state = StartShiftFormState(
        unitId: state.unitId,
        operatorId: state.operatorId,
        lastHm: lastHm,
        isLoadingHm: false,
      );
    } catch (_) {
      // Silently degrade: Step 2 stays editable, just without prefill.
      state = StartShiftFormState(
        unitId: state.unitId,
        operatorId: state.operatorId,
        isLoadingHm: false,
      );
    }
  }

  /// Clears all form state. Call this after a successful shift start.
  void reset() {
    state = const StartShiftFormState();
  }
}

final startShiftFormControllerProvider =
    NotifierProvider<StartShiftFormController, StartShiftFormState>(
  StartShiftFormController.new,
);
