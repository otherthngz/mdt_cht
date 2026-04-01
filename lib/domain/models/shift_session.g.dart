// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftSessionAdapter extends TypeAdapter<ShiftSession> {
  @override
  final int typeId = 0;

  @override
  ShiftSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftSession(
      shiftSessionId: fields[0] as String,
      unitId: fields[1] as String,
      operatorId: fields[2] as String,
      shiftDate: fields[3] as String,
      hmStart: fields[4] as double,
      hmEnd: fields[5] as double?,
      startedAt: fields[6] as String,
      endedAt: fields[7] as String?,
      status: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.shiftSessionId)
      ..writeByte(1)
      ..write(obj.unitId)
      ..writeByte(2)
      ..write(obj.operatorId)
      ..writeByte(3)
      ..write(obj.shiftDate)
      ..writeByte(4)
      ..write(obj.hmStart)
      ..writeByte(5)
      ..write(obj.hmEnd)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.endedAt)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
