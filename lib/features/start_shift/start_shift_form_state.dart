/// Shared form state for the 2-step Start Shift flow.
///
/// Held in [StartShiftFormController] and shared between
/// [StartShiftStep1Page] and [StartShiftStep2Page].
class StartShiftFormState {
  /// Unit ID entered in Step 1.
  final String unitId;

  /// Operator ID entered in Step 1.
  final String operatorId;

  /// Last known hourmeter for [unitId], fetched from persisted storage.
  /// Null until fetched or when no prior record exists for this unit.
  final double? lastHm;

  /// True while the HM fetch is in flight.
  final bool isLoadingHm;

  const StartShiftFormState({
    this.unitId = '',
    this.operatorId = '',
    this.lastHm,
    this.isLoadingHm = false,
  });
}
