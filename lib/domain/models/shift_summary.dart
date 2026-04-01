// ShiftSummary — per 05_DATA_MODEL.md §8.
// Derived from ActivityEvent[] + ShiftSession. NEVER persisted.

/// Shift-level summary, fully derived from events and session.
class ShiftSummary {
  final String shiftSessionId;

  /// Category duration totals in seconds.
  final int totalShiftSeconds;
  final int totalOperationSeconds;
  final int totalStandbySeconds;
  final int totalDelaySeconds;
  final int totalBreakdownSeconds;

  /// HM values.
  final double hmStart;
  final double? hmEnd;
  final double? totalDeltaHm;

  /// Physical Availability = (total - breakdown) / total * 100
  final double? pa;

  /// Use of Availability = operation / (total - breakdown) * 100
  final double? ua;

  /// Cumulative trip counts.
  final int loadingCountTotal;
  final int haulingCountTotal;

  const ShiftSummary({
    required this.shiftSessionId,
    required this.totalShiftSeconds,
    required this.totalOperationSeconds,
    required this.totalStandbySeconds,
    required this.totalDelaySeconds,
    required this.totalBreakdownSeconds,
    required this.hmStart,
    this.hmEnd,
    this.totalDeltaHm,
    this.pa,
    this.ua,
    this.loadingCountTotal = 0,
    this.haulingCountTotal = 0,
  });
}
