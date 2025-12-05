import 'package:hive/hive.dart';
import '../db/hive_service.dart';
import '../models/fertilizer_log_model.dart';

class FertilizerLogRepository {
  final Box<FertilizerLogModel> _box = HiveService.logsBox;

  Future<List<FertilizerLogModel>> getAllLogs() async {
    return _box.values.toList()..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  Future<List<FertilizerLogModel>> getLogsByPlant(String plantId) async {
    return _box.values
        .where((log) => log.plantId == plantId)
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  Future<List<FertilizerLogModel>> getRecentLogs(int limit) async {
    final logs = await getAllLogs();
    return logs.take(limit).toList();
  }

  Future<FertilizerLogModel?> getLogById(String id) async {
    return _box.get(id);
  }

  Future<void> addLog(FertilizerLogModel log) async {
    await _box.put(log.id, log);
  }

  Future<void> updateLog(FertilizerLogModel log) async {
    await _box.put(log.id, log);
  }

  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteLogsByPlant(String plantId) async {
    final logs = await getLogsByPlant(plantId);
    for (final log in logs) {
      await deleteLog(log.id);
    }
  }

  Stream<List<FertilizerLogModel>> watchLogs() {
    return _box.watch().map((_) => _box.values.toList()..sort((a, b) => b.appliedAt.compareTo(a.appliedAt)));
  }
}

