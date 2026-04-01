// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityEventAdapter extends TypeAdapter<ActivityEvent> {
  @override
  final int typeId = 1;

  @override
  ActivityEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityEvent(
      eventId: fields[0] as String,
      eventName: fields[1] as String,
      shiftSessionId: fields[2] as String,
      unitId: fields[3] as String,
      operatorId: fields[4] as String,
      occurredAt: fields[5] as String,
      source: fields[6] as String,
      activityCategory: fields[7] as String?,
      activitySubtype: fields[8] as String?,
      loaderCode: fields[9] as String?,
      haulingCode: fields[10] as String?,
      hmStart: fields[11] as double?,
      hmEnd: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityEvent obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.eventName)
      ..writeByte(2)
      ..write(obj.shiftSessionId)
      ..writeByte(3)
      ..write(obj.unitId)
      ..writeByte(4)
      ..write(obj.operatorId)
      ..writeByte(5)
      ..write(obj.occurredAt)
      ..writeByte(6)
      ..write(obj.source)
      ..writeByte(7)
      ..write(obj.activityCategory)
      ..writeByte(8)
      ..write(obj.activitySubtype)
      ..writeByte(9)
      ..write(obj.loaderCode)
      ..writeByte(10)
      ..write(obj.haulingCode)
      ..writeByte(11)
      ..write(obj.hmStart)
      ..writeByte(12)
      ..write(obj.hmEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
