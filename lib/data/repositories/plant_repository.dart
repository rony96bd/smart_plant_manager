import 'package:hive/hive.dart';
import '../db/hive_service.dart';
import '../models/plant_model.dart';

class PlantRepository {
  final Box<PlantModel> _box = HiveService.plantsBox;

  Future<List<PlantModel>> getAllPlants() async {
    return _box.values.toList();
  }

  Future<List<PlantModel>> searchPlants(String query) async {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((plant) {
      return plant.name.toLowerCase().contains(lowerQuery) ||
          plant.category.toLowerCase().contains(lowerQuery) ||
          (plant.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<PlantModel>> filterByCategory(String category) async {
    return _box.values.where((plant) => plant.category == category).toList();
  }

  Future<PlantModel?> getPlantById(String id) async {
    return _box.get(id);
  }

  Future<void> addPlant(PlantModel plant) async {
    await _box.put(plant.id, plant);
  }

  Future<void> updatePlant(PlantModel plant) async {
    await _box.put(plant.id, plant);
  }

  Future<void> deletePlant(String id) async {
    await _box.delete(id);
  }

  Stream<List<PlantModel>> watchPlants() {
    return _box.watch().map((_) => _box.values.toList());
  }
}

