import 'package:hive/hive.dart';
import '../db/hive_service.dart';
import '../models/fertilizer_model.dart';

class FertilizerRepository {
  final Box<FertilizerModel> _box = HiveService.fertilizersBox;

  Future<List<FertilizerModel>> getAllFertilizers() async {
    return _box.values.toList();
  }

  Future<List<FertilizerModel>> searchFertilizers(String query) async {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((fertilizer) {
      return fertilizer.name.toLowerCase().contains(lowerQuery) ||
          fertilizer.type.toLowerCase().contains(lowerQuery) ||
          (fertilizer.usageRecommendations?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<FertilizerModel>> filterByType(String type) async {
    return _box.values.where((fertilizer) => fertilizer.type == type).toList();
  }

  Future<FertilizerModel?> getFertilizerById(String id) async {
    return _box.get(id);
  }

  Future<void> addFertilizer(FertilizerModel fertilizer) async {
    await _box.put(fertilizer.id, fertilizer);
  }

  Future<void> updateFertilizer(FertilizerModel fertilizer) async {
    await _box.put(fertilizer.id, fertilizer);
  }

  Future<void> deleteFertilizer(String id) async {
    await _box.delete(id);
  }

  Stream<List<FertilizerModel>> watchFertilizers() {
    return _box.watch().map((_) => _box.values.toList());
  }
}

