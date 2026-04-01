// All enums as defined in 05_DATA_MODEL.md §9.
// Names are EXACT matches — do not rename.

enum ShiftStatus {
  active,
  ended,
}

enum EventName {
  // ignore: constant_identifier_names
  SHIFT_STARTED,
  // ignore: constant_identifier_names
  ACTIVITY_STARTED,
  // ignore: constant_identifier_names
  ACTIVITY_ENDED,
  // ignore: constant_identifier_names
  SHIFT_ENDED,
}

enum ActivityCategory {
  operation,
  standby,
  delay,
  breakdown,
}

enum ActivitySubtype {
  // Operation
  loading,
  hauling,
  dumping,
  nonProductive,

  // Standby
  changeShift,
  refueling,
  waiting,
  // ignore: constant_identifier_names
  break_, // 'break' is a Dart keyword — use break_ internally, map to 'break' for storage

  // Delay
  rain,
  flood,
  roadIssue,
  extremeDust,
  lightningStorm,
  landslide,

  // Breakdown
  engine,
  hydraulic,
  electrical,
  transmission,
  undercarriageBody,
  brakeSteering,
}

/// Maps each subtype to its parent category.
const Map<ActivitySubtype, ActivityCategory> subtypeCategoryMap = {
  // Operation
  ActivitySubtype.loading: ActivityCategory.operation,
  ActivitySubtype.hauling: ActivityCategory.operation,
  ActivitySubtype.dumping: ActivityCategory.operation,
  ActivitySubtype.nonProductive: ActivityCategory.operation,

  // Standby
  ActivitySubtype.changeShift: ActivityCategory.standby,
  ActivitySubtype.refueling: ActivityCategory.standby,
  ActivitySubtype.waiting: ActivityCategory.standby,
  ActivitySubtype.break_: ActivityCategory.standby,

  // Delay
  ActivitySubtype.rain: ActivityCategory.delay,
  ActivitySubtype.flood: ActivityCategory.delay,
  ActivitySubtype.roadIssue: ActivityCategory.delay,
  ActivitySubtype.extremeDust: ActivityCategory.delay,
  ActivitySubtype.lightningStorm: ActivityCategory.delay,
  ActivitySubtype.landslide: ActivityCategory.delay,

  // Breakdown
  ActivitySubtype.engine: ActivityCategory.breakdown,
  ActivitySubtype.hydraulic: ActivityCategory.breakdown,
  ActivitySubtype.electrical: ActivityCategory.breakdown,
  ActivitySubtype.transmission: ActivityCategory.breakdown,
  ActivitySubtype.undercarriageBody: ActivityCategory.breakdown,
  ActivitySubtype.brakeSteering: ActivityCategory.breakdown,
};

/// Subtypes grouped by category for UI selection.
const Map<ActivityCategory, List<ActivitySubtype>> categorySubtypes = {
  ActivityCategory.operation: [
    ActivitySubtype.loading,
    ActivitySubtype.hauling,
    ActivitySubtype.dumping,
    ActivitySubtype.nonProductive,
  ],
  ActivityCategory.standby: [
    ActivitySubtype.changeShift,
    ActivitySubtype.refueling,
    ActivitySubtype.waiting,
    ActivitySubtype.break_,
  ],
  ActivityCategory.delay: [
    ActivitySubtype.rain,
    ActivitySubtype.flood,
    ActivitySubtype.roadIssue,
    ActivitySubtype.extremeDust,
    ActivitySubtype.lightningStorm,
    ActivitySubtype.landslide,
  ],
  ActivityCategory.breakdown: [
    ActivitySubtype.engine,
    ActivitySubtype.hydraulic,
    ActivitySubtype.electrical,
    ActivitySubtype.transmission,
    ActivitySubtype.undercarriageBody,
    ActivitySubtype.brakeSteering,
  ],
};

/// Convert subtype enum to storage string.
/// Handles break_ → 'break' mapping.
String subtypeToString(ActivitySubtype subtype) {
  if (subtype == ActivitySubtype.break_) return 'break';
  return subtype.name;
}

/// Convert storage string to subtype enum.
/// Returns [ActivitySubtype.nonProductive] for unknown strings.
ActivitySubtype subtypeFromString(String value) {
  if (value == 'break') return ActivitySubtype.break_;
  return ActivitySubtype.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ActivitySubtype.nonProductive,
  );
}
