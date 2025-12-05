// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fertilizer_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FertilizerLogModelAdapter extends TypeAdapter<FertilizerLogModel> {
  @override
  final int typeId = 3;

  @override
  FertilizerLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FertilizerLogModel(
      id: fields[0] as String,
      plantId: fields[1] as String,
      fertilizerId: fields[2] as String,
      scheduleId: fields[3] as String?,
      dose: fields[4] as String?,
      notes: fields[5] as String?,
      appliedAt: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FertilizerLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantId)
      ..writeByte(2)
      ..write(obj.fertilizerId)
      ..writeByte(3)
      ..write(obj.scheduleId)
      ..writeByte(4)
      ..write(obj.dose)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.appliedAt)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FertilizerLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
