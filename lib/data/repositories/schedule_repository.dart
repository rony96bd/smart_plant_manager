import 'package:hive/hive.dart';
import '../db/hive_service.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final Box<ScheduleModel> _box = HiveService.schedulesBox;

  Future<List<ScheduleModel>> getAllSchedules() async {
    return _box.values.toList();
  }

  Future<List<ScheduleModel>> getSchedulesByPlant(String plantId) async {
    return _box.values.where((schedule) => schedule.plantId == plantId).toList();
  }

  Future<List<ScheduleModel>> getActiveSchedules() async {
    return _box.values.where((schedule) => schedule.isActive).toList();
  }

  Future<List<ScheduleModel>> getUpcomingSchedules(DateTime date) async {
    return _box.values
        .where((schedule) => schedule.isActive && schedule.nextScheduleDate.isBefore(date))
        .toList()
      ..sort((a, b) => a.nextScheduleDate.compareTo(b.nextScheduleDate));
  }

  Future<ScheduleModel?> getScheduleById(String id) async {
    return _box.get(id);
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteSchedulesByPlant(String plantId) async {
    final schedules = await getSchedulesByPlant(plantId);
    for (final schedule in schedules) {
      await deleteSchedule(schedule.id);
    }
  }

  Stream<List<ScheduleModel>> watchSchedules() {
    return _box.watch().map((_) => _box.values.toList());
  }
}

