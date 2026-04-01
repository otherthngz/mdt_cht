import 'package:hive/hive.dart';

part 'activity_event.g.dart';

/// ActivityEvent — per 05_DATA_MODEL.md §6.
/// Persisted to Hive. Field names are EXACT matches.
@HiveType(typeId: 1)
class ActivityEvent extends HiveObject {
  @HiveField(0)
  final String eventId;

  @HiveField(1)
  final String eventName;

  @HiveField(2)
  final String shiftSessionId;

  @HiveField(3)
  final String unitId;

  @HiveField(4)
  final String operatorId;

  @HiveField(5)
  final String occurredAt;

  @HiveField(6)
  final String source;

  @HiveField(7)
  final String? activityCategory;

  @HiveField(8)
  final String? activitySubtype;

  @HiveField(9)
  final String? loaderCode;

  @HiveField(10)
  final String? haulingCode;

  @HiveField(11)
  final double? hmStart;

  @HiveField(12)
  final double? hmEnd;

  ActivityEvent({
    required this.eventId,
    required this.eventName,
    required this.shiftSessionId,
    required this.unitId,
    required this.operatorId,
    required this.occurredAt,
    this.source = 'MDT',
    this.activityCategory,
    this.activitySubtype,
    this.loaderCode,
    this.haulingCode,
    this.hmStart,
    this.hmEnd,
  });
}
