import 'package:hive/hive.dart';

part 'fertilizer_log_model.g.dart';

@HiveType(typeId: 3)
class FertilizerLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String plantId;

  @HiveField(2)
  String fertilizerId;

  @HiveField(3)
  String? scheduleId; // Optional: if applied from a schedule

  @HiveField(4)
  String? dose;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime appliedAt;

  @HiveField(7)
  DateTime createdAt;

  FertilizerLogModel({
    required this.id,
    required this.plantId,
    required this.fertilizerId,
    this.scheduleId,
    this.dose,
    this.notes,
    required this.appliedAt,
    required this.createdAt,
  });

  FertilizerLogModel copyWith({
    String? id,
    String? plantId,
    String? fertilizerId,
    String? scheduleId,
    String? dose,
    String? notes,
    DateTime? appliedAt,
    DateTime? createdAt,
  }) {
    return FertilizerLogModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      fertilizerId: fertilizerId ?? this.fertilizerId,
      scheduleId: scheduleId ?? this.scheduleId,
      dose: dose ?? this.dose,
      notes: notes ?? this.notes,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'fertilizerId': fertilizerId,
      'scheduleId': scheduleId,
      'dose': dose,
      'notes': notes,
      'appliedAt': appliedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FertilizerLogModel.fromJson(Map<String, dynamic> json) {
    return FertilizerLogModel(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      fertilizerId: json['fertilizerId'] as String,
      scheduleId: json['scheduleId'] as String?,
      dose: json['dose'] as String?,
      notes: json['notes'] as String?,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

