import 'package:hive/hive.dart';

part 'fertilizer_model.g.dart';

@HiveType(typeId: 1)
class FertilizerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  String? ratio;

  @HiveField(4)
  String? usageRecommendations;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  FertilizerModel({
    required this.id,
    required this.name,
    required this.type,
    this.ratio,
    this.usageRecommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  FertilizerModel copyWith({
    String? id,
    String? name,
    String? type,
    String? ratio,
    String? usageRecommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FertilizerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      ratio: ratio ?? this.ratio,
      usageRecommendations: usageRecommendations ?? this.usageRecommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'ratio': ratio,
      'usageRecommendations': usageRecommendations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FertilizerModel.fromJson(Map<String, dynamic> json) {
    return FertilizerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      ratio: json['ratio'] as String?,
      usageRecommendations: json['usageRecommendations'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

