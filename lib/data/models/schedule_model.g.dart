// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 2;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Handle backward compatibility: old data has fertilizerId as String
    List<String> fertilizerIds = [];
    Map<String, String> doses = {};

    if (fields[2] is List) {
      // New format: fertilizerIds is already a List
      fertilizerIds = (fields[2] as List).cast<String>();
      doses = (fields[3] as Map?)?.cast<String, String>() ?? {};
    } else if (fields[2] is String) {
      // Old format: fertilizerId is a String, convert to List
      final fertilizerId = fields[2] as String;
      fertilizerIds = [fertilizerId];
      // For old format, try to get dose from fields[3] if it exists
      final oldDose = fields[3] as String?;
      if (oldDose != null && oldDose.isNotEmpty) {
        doses[fertilizerId] = oldDose;
      }
    }

    return ScheduleModel(
      id: fields[0] as String,
      plantId: fields[1] as String,
      fertilizerIds: fertilizerIds,
      doses: doses,
      notes: fields[4] as String?,
      repeatType: fields[5] as int,
      everyXDays: fields[6] as int?,
      reminderHour: fields[7] as int,
      reminderMinute: fields[8] as int,
      nextScheduleDate: fields[9] as DateTime,
      isActive: fields[10] as bool? ?? true,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantId)
      ..writeByte(2)
      ..write(obj.fertilizerIds)
      ..writeByte(3)
      ..write(obj.doses)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.repeatType)
      ..writeByte(6)
      ..write(obj.everyXDays)
      ..writeByte(7)
      ..write(obj.reminderHour)
      ..writeByte(8)
      ..write(obj.reminderMinute)
      ..writeByte(9)
      ..write(obj.nextScheduleDate)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
