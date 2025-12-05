// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fertilizer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FertilizerModelAdapter extends TypeAdapter<FertilizerModel> {
  @override
  final int typeId = 1;

  @override
  FertilizerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FertilizerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      ratio: fields[3] as String?,
      usageRecommendations: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FertilizerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.ratio)
      ..writeByte(4)
      ..write(obj.usageRecommendations)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FertilizerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
