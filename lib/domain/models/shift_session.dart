import 'package:hive/hive.dart';

part 'shift_session.g.dart';

/// ShiftSession — per 05_DATA_MODEL.md §5.
/// Persisted to Hive. Field names are EXACT matches.
@HiveType(typeId: 0)
class ShiftSession extends HiveObject {
  @HiveField(0)
  final String shiftSessionId;

  @HiveField(1)
  final String unitId;

  @HiveField(2)
  final String operatorId;

  @HiveField(3)
  final String shiftDate;

  @HiveField(4)
  final double hmStart;

  @HiveField(5)
  double? hmEnd;

  @HiveField(6)
  final String startedAt;

  @HiveField(7)
  String? endedAt;

  @HiveField(8)
  String status;

  ShiftSession({
    required this.shiftSessionId,
    required this.unitId,
    required this.operatorId,
    required this.shiftDate,
    required this.hmStart,
    this.hmEnd,
    required this.startedAt,
    this.endedAt,
    required this.status,
  });

  /// Creates a copy with updated fields.
  ShiftSession copyWith({
    String? shiftSessionId,
    String? unitId,
    String? operatorId,
    String? shiftDate,
    double? hmStart,
    double? hmEnd,
    String? startedAt,
    String? endedAt,
    String? status,
  }) {
    return ShiftSession(
      shiftSessionId: shiftSessionId ?? this.shiftSessionId,
      unitId: unitId ?? this.unitId,
      operatorId: operatorId ?? this.operatorId,
      shiftDate: shiftDate ?? this.shiftDate,
      hmStart: hmStart ?? this.hmStart,
      hmEnd: hmEnd ?? this.hmEnd,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
    );
  }
}
