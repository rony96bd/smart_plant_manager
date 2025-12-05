import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant_model.dart';
import '../models/fertilizer_model.dart';
import '../models/schedule_model.dart';
import '../models/fertilizer_log_model.dart';

class HiveService {
  static const String plantsBoxName = 'plants';
  static const String fertilizersBoxName = 'fertilizers';
  static const String schedulesBoxName = 'schedules';
  static const String logsBoxName = 'fertilizer_logs';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlantModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FertilizerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ScheduleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FertilizerLogModelAdapter());
    }

    // Open boxes
    await Hive.openBox<PlantModel>(plantsBoxName);
    await Hive.openBox<FertilizerModel>(fertilizersBoxName);
    await Hive.openBox<ScheduleModel>(schedulesBoxName);
    await Hive.openBox<FertilizerLogModel>(logsBoxName);
  }

  static Box<PlantModel> get plantsBox => Hive.box<PlantModel>(plantsBoxName);
  static Box<FertilizerModel> get fertilizersBox => Hive.box<FertilizerModel>(fertilizersBoxName);
  static Box<ScheduleModel> get schedulesBox => Hive.box<ScheduleModel>(schedulesBoxName);
  static Box<FertilizerLogModel> get logsBox => Hive.box<FertilizerLogModel>(logsBoxName);
}

