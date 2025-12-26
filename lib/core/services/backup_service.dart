import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../data/db/hive_service.dart';
import '../../data/models/plant_model.dart';
import '../../data/models/fertilizer_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/fertilizer_log_model.dart';

class BackupService {
  static const String backupFileName = 'smart_plant_manager_backup.json';

  /// Export all app data to JSON string
  static Future<String> exportData() async {
    final plants = HiveService.plantsBox.values.toList();
    final fertilizers = HiveService.fertilizersBox.values.toList();
    final schedules = HiveService.schedulesBox.values.toList();
    final logs = HiveService.logsBox.values.toList();

    final backupData = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'plants': plants.map((plant) => plant.toJson()).toList(),
      'fertilizers': fertilizers.map((fertilizer) => fertilizer.toJson()).toList(),
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'logs': logs.map((log) => log.toJson()).toList(),
    };

    return jsonEncode(backupData);
  }

  /// Create and save backup file to device storage
  static Future<String?> createAndSaveBackup() async {
    final jsonData = await exportData();
    final timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-').replaceAll(' ', '_');
    final fileName = 'smart_plant_backup_$timestamp.json';

    String? path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Please select a backup directory',
      lockParentWindow: true,
    );

    if (path != null) {
      final file = File('$path/$fileName');
      await file.writeAsString(jsonData);
      return file.path;
    }
    return null;
  }

  /// Restore data from a selected backup file
  static Future<Map<String, int>?> restoreFromBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Use FileType.any for better compatibility
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      if (!path.toLowerCase().endsWith('.json')) {
        throw Exception('Invalid file type. Please select a .json backup file.');
      }
      final file = File(path);
      final jsonData = await file.readAsString();
      return await importData(jsonData);
    }
    return null;
  }

  /// Import data from JSON backup
  static Future<Map<String, int>> importData(String jsonData) async {
    final backupData = jsonDecode(jsonData) as Map<String, dynamic>;

    if (!validateBackupFile(jsonData)) {
      throw Exception('Invalid backup file format');
    }

    await clearAllData();

    final idMapping = <String, String>{}; // Old ID -> New ID
    int plantsImported = 0;
    int fertilizersImported = 0;
    int schedulesImported = 0;
    int logsImported = 0;

    final plantsData = backupData['plants'] as List<dynamic>;
    for (final plantJson in plantsData) {
      final plant = PlantModel.fromJson(plantJson as Map<String, dynamic>);
      final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_plant_' + plantsImported.toString();
      idMapping[plant.id] = newId;
      final newPlant = plant.copyWith(id: newId, updatedAt: DateTime.now());
      await HiveService.plantsBox.put(newPlant.id, newPlant);
      plantsImported++;
    }

    final fertilizersData = backupData['fertilizers'] as List<dynamic>;
    for (final fertilizerJson in fertilizersData) {
      final fertilizer = FertilizerModel.fromJson(fertilizerJson as Map<String, dynamic>);
      final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_fertilizer_' + fertilizersImported.toString();
      idMapping[fertilizer.id] = newId;
      final newFertilizer = fertilizer.copyWith(id: newId, updatedAt: DateTime.now());
      await HiveService.fertilizersBox.put(newFertilizer.id, newFertilizer);
      fertilizersImported++;
    }

    final schedulesData = backupData['schedules'] as List<dynamic>;
    for (final scheduleJson in schedulesData) {
      final schedule = ScheduleModel.fromJson(scheduleJson as Map<String, dynamic>);
      final newPlantId = idMapping[schedule.plantId];
      if (newPlantId == null) continue;

      final newFertilizerIds = schedule.fertilizerIds.map((id) => idMapping[id]).where((id) => id != null).cast<String>().toList();

      final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_schedule_' + schedulesImported.toString();
      final newSchedule = schedule.copyWith(
        id: newId,
        plantId: newPlantId,
        fertilizerIds: newFertilizerIds,
        updatedAt: DateTime.now(),
      );
      await HiveService.schedulesBox.put(newId, newSchedule);
      schedulesImported++;
    }

    final logsData = backupData['logs'] as List<dynamic>;
    for (final logJson in logsData) {
      final log = FertilizerLogModel.fromJson(logJson as Map<String, dynamic>);
      final newPlantId = idMapping[log.plantId];
      final newFertilizerId = idMapping[log.fertilizerId];

      final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_log_' + logsImported.toString();
      final newLog = log.copyWith(
        id: newId,
        plantId: newPlantId ?? log.plantId, 
        fertilizerId: newFertilizerId ?? log.fertilizerId,
      );
      await HiveService.logsBox.put(newId, newLog);
      logsImported++;
    }

    return {
      'plants': plantsImported,
      'fertilizers': fertilizersImported,
      'schedules': schedulesImported,
      'logs': logsImported,
    };
  }

  static Future<Map<String, int>> getBackupStats() async {
    return {
      'plants': HiveService.plantsBox.length,
      'fertilizers': HiveService.fertilizersBox.length,
      'schedules': HiveService.schedulesBox.length,
      'logs': HiveService.logsBox.length,
    };
  }

  static Future<void> clearAllData() async {
    await HiveService.plantsBox.clear();
    await HiveService.fertilizersBox.clear();
    await HiveService.schedulesBox.clear();
    await HiveService.logsBox.clear();
  }

  static bool validateBackupFile(String jsonData) {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      return data.containsKey('version') &&
          data.containsKey('plants') &&
          data.containsKey('fertilizers') &&
          data.containsKey('schedules') &&
          data.containsKey('logs');
    } catch (e) {
      return false;
    }
  }
}
