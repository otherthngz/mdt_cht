// TimesheetRow — per 05_DATA_MODEL.md §7.
// Derived from ActivityEvent pairs. NEVER persisted.

/// A single row in the timesheet, derived by pairing
/// ACTIVITY_STARTED with its corresponding ACTIVITY_ENDED.
class TimesheetRow {
  final String rowId;
  final String shiftSessionId;

  /// activityCategory string (e.g. 'operation', 'standby')
  final String category;

  /// activitySubtype string (e.g. 'loading', 'changeShift')
  final String activity;

  /// ISO datetime of ACTIVITY_STARTED.occurredAt
  final String startTime;

  /// ISO datetime of ACTIVITY_ENDED.occurredAt, or null if still active
  final String? endTime;

  /// Derived: endTime - startTime in seconds. Null if active.
  final int? durationSeconds;

  /// Derived HM values (null if hmEnd is not yet set on shift session)
  final double? hmStartDerived;
  final double? hmEndDerived;
  final double? deltaHmDerived;

  /// Only set for subtype == 'loading'
  final String? loaderCode;

  /// Only set for subtype == 'hauling'
  final String? haulingCode;

  /// Cumulative count of loading activities up to and including this row.
  final int loadingCount;

  /// Cumulative count of hauling activities up to and including this row.
  final int haulingCount;

  /// True if this row has no endTime (activity still running).
  final bool isActive;

  const TimesheetRow({
    required this.rowId,
    required this.shiftSessionId,
    required this.category,
    required this.activity,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    this.hmStartDerived,
    this.hmEndDerived,
    this.deltaHmDerived,
    this.loaderCode,
    this.haulingCode,
    this.loadingCount = 0,
    this.haulingCount = 0,
    this.isActive = false,
  });
}
