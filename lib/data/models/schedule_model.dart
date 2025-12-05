import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

enum RepeatType {
  once,
  daily,
  weekly,
  everyXDays,
  monthly,
}

@HiveType(typeId: 2)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String plantId;

  @HiveField(2)
  String fertilizerId;

  @HiveField(3)
  String? dose;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  int repeatType; // 0: once, 1: daily, 2: weekly, 3: everyXDays, 4: monthly

  @HiveField(6)
  int? everyXDays; // For "every X days" repeat type

  @HiveField(7)
  int reminderHour;

  @HiveField(8)
  int reminderMinute;

  @HiveField(9)
  DateTime nextScheduleDate;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  ScheduleModel({
    required this.id,
    required this.plantId,
    required this.fertilizerId,
    this.dose,
    this.notes,
    required this.repeatType,
    this.everyXDays,
    required int reminderHour,
    required int reminderMinute,
    required this.nextScheduleDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  })  : reminderHour = reminderHour,
        reminderMinute = reminderMinute;

  TimeOfDay get reminderTime {
    return TimeOfDay(hour: reminderHour, minute: reminderMinute);
  }

  RepeatType get repeatTypeEnum {
    return RepeatType.values[repeatType];
  }

  ScheduleModel copyWith({
    String? id,
    String? plantId,
    String? fertilizerId,
    String? dose,
    String? notes,
    int? repeatType,
    int? everyXDays,
    int? reminderHour,
    int? reminderMinute,
    DateTime? nextScheduleDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      fertilizerId: fertilizerId ?? this.fertilizerId,
      dose: dose ?? this.dose,
      notes: notes ?? this.notes,
      repeatType: repeatType ?? this.repeatType,
      everyXDays: everyXDays ?? this.everyXDays,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      nextScheduleDate: nextScheduleDate ?? this.nextScheduleDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'fertilizerId': fertilizerId,
      'dose': dose,
      'notes': notes,
      'repeatType': repeatType,
      'everyXDays': everyXDays,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'nextScheduleDate': nextScheduleDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      fertilizerId: json['fertilizerId'] as String,
      dose: json['dose'] as String?,
      notes: json['notes'] as String?,
      repeatType: json['repeatType'] as int,
      everyXDays: json['everyXDays'] as int?,
      reminderHour: json['reminderHour'] as int,
      reminderMinute: json['reminderMinute'] as int,
      nextScheduleDate: DateTime.parse(json['nextScheduleDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

