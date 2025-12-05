import 'package:hive/hive.dart';

part 'plant_model.g.dart';

@HiveType(typeId: 0)
class PlantModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  String? potSize;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  PlantModel({
    required this.id,
    required this.name,
    required this.category,
    this.imagePath,
    this.potSize,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  PlantModel copyWith({
    String? id,
    String? name,
    String? category,
    String? imagePath,
    String? potSize,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      potSize: potSize ?? this.potSize,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'potSize': potSize,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imagePath: json['imagePath'] as String?,
      potSize: json['potSize'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

