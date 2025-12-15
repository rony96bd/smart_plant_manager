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

  Future<void> deletePlant(String plantId) async {
    // First, delete associated schedules
    final schedulesToDelete = HiveService.schedulesBox.values
        .where((schedule) => schedule.plantId == plantId)
        .map((schedule) => schedule.id)
        .toList();
    for (final scheduleId in schedulesToDelete) {
      await HiveService.schedulesBox.delete(scheduleId);
    }

    // Then, delete associated logs
    final logsToDelete = HiveService.logsBox.values
        .where((log) => log.plantId == plantId)
        .map((log) => log.id)
        .toList();
    for (final logId in logsToDelete) {
      await HiveService.logsBox.delete(logId);
    }

    // Finally, delete the plant itself
    await _box.delete(plantId);
  }

  Stream<List<PlantModel>> watchPlants() {
    return _box.watch().map((_) => _box.values.toList());
  }
}
