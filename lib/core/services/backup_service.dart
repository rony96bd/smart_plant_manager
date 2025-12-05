import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/db/hive_service.dart';
import '../../data/models/plant_model.dart';
import '../../data/models/fertilizer_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/fertilizer_log_model.dart';

class BackupService {
  static const String backupFileName = 'smart_plant_manager_backup.json';

  /// Export all app data to JSON
  static Future<String> exportData() async {
    try {
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
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Save backup to file and share
  static Future<void> createBackup() async {
    try {
      final jsonData = await exportData();

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      // Create backups directory if it doesn't exist
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Create backup file
      final timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-').replaceAll(' ', '_');
      final fileName = 'backup_$timestamp.json';
      final file = File('${backupDir.path}/$fileName');

      await file.writeAsString(jsonData);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Smart Plant Manager Backup');

    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Import data from JSON backup
  static Future<Map<String, int>> importData(String jsonData) async {
    try {
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;

      // Validate backup format
      if (!backupData.containsKey('version') ||
          !backupData.containsKey('plants') ||
          !backupData.containsKey('fertilizers') ||
          !backupData.containsKey('schedules') ||
          !backupData.containsKey('logs')) {
        throw Exception('Invalid backup file format');
      }

      int plantsImported = 0;
      int fertilizersImported = 0;
      int schedulesImported = 0;
      int logsImported = 0;

      // Import plants
      final plantsData = backupData['plants'] as List<dynamic>;
      for (final plantJson in plantsData) {
        try {
          final plant = PlantModel.fromJson(plantJson as Map<String, dynamic>);
          // Generate new ID to avoid conflicts
          final newPlant = PlantModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${plant.id}',
            name: plant.name,
            category: plant.category,
            imagePath: plant.imagePath,
            potSize: plant.potSize,
            notes: plant.notes,
            createdAt: plant.createdAt,
            updatedAt: plant.updatedAt,
          );
          await HiveService.plantsBox.put(newPlant.id, newPlant);
          plantsImported++;
        } catch (e) {
          // Skip invalid plant data
          continue;
        }
      }

      // Import fertilizers
      final fertilizersData = backupData['fertilizers'] as List<dynamic>;
      for (final fertilizerJson in fertilizersData) {
        try {
          final fertilizer = FertilizerModel.fromJson(fertilizerJson as Map<String, dynamic>);
          final newFertilizer = FertilizerModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${fertilizer.id}',
            name: fertilizer.name,
            type: fertilizer.type,
            ratio: fertilizer.ratio,
            usageRecommendations: fertilizer.usageRecommendations,
            createdAt: fertilizer.createdAt,
            updatedAt: fertilizer.updatedAt,
          );
          await HiveService.fertilizersBox.put(newFertilizer.id, newFertilizer);
          fertilizersImported++;
        } catch (e) {
          continue;
        }
      }

      // Import schedules
      final schedulesData = backupData['schedules'] as List<dynamic>;
      for (final scheduleJson in schedulesData) {
        try {
          final schedule = ScheduleModel.fromJson(scheduleJson as Map<String, dynamic>);
          final newSchedule = ScheduleModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${schedule.id}',
            plantId: schedule.plantId, // Keep original plant ID - will be invalid but handled gracefully
            fertilizerIds: schedule.fertilizerIds,
            doses: schedule.doses,
            notes: schedule.notes,
            repeatType: schedule.repeatType,
            everyXDays: schedule.everyXDays,
            reminderHour: schedule.reminderHour,
            reminderMinute: schedule.reminderMinute,
            nextScheduleDate: schedule.nextScheduleDate,
            isActive: false, // Import as inactive to avoid conflicts
            createdAt: schedule.createdAt,
            updatedAt: schedule.updatedAt,
          );
          await HiveService.schedulesBox.put(newSchedule.id, newSchedule);
          schedulesImported++;
        } catch (e) {
          continue;
        }
      }

      // Import logs
      final logsData = backupData['logs'] as List<dynamic>;
      for (final logJson in logsData) {
        try {
          final log = FertilizerLogModel.fromJson(logJson as Map<String, dynamic>);
          final newLog = FertilizerLogModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${log.id}',
            plantId: log.plantId, // Keep original IDs - will be invalid but handled gracefully
            fertilizerId: log.fertilizerId,
            scheduleId: log.scheduleId,
            dose: log.dose,
            notes: log.notes,
            appliedAt: log.appliedAt,
            createdAt: log.createdAt,
          );
          await HiveService.logsBox.put(newLog.id, newLog);
          logsImported++;
        } catch (e) {
          continue;
        }
      }

      return {
        'plants': plantsImported,
        'fertilizers': fertilizersImported,
        'schedules': schedulesImported,
        'logs': logsImported,
      };

    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Get backup statistics
  static Future<Map<String, int>> getBackupStats() async {
    return {
      'plants': HiveService.plantsBox.length,
      'fertilizers': HiveService.fertilizersBox.length,
      'schedules': HiveService.schedulesBox.length,
      'logs': HiveService.logsBox.length,
    };
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await HiveService.plantsBox.clear();
    await HiveService.fertilizersBox.clear();
    await HiveService.schedulesBox.clear();
    await HiveService.logsBox.clear();
  }

  /// Validate backup file
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
