import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../data/models/schedule_model.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/fertilizer_repository.dart';
import '../../data/repositories/schedule_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final PlantRepository _plantRepository = PlantRepository();
  final FertilizerRepository _fertilizerRepository = FertilizerRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka')); // Default to Bangladesh timezone

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
  }

  Future<void> scheduleNotification(ScheduleModel schedule) async {
    if (!_initialized) await initialize();

    final plant = await _plantRepository.getPlantById(schedule.plantId);
    final fertilizer = await _fertilizerRepository.getFertilizerById(schedule.fertilizerId);

    if (plant == null || fertilizer == null) return;

    final scheduledDate = _getScheduledDateTime(schedule.nextScheduleDate, schedule.reminderTime);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // Don't schedule past notifications
    }

    // Check if exact alarms are permitted, fallback to inexact if not
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    try {
      // Try to schedule with exact alarm first
      await _notifications.zonedSchedule(
        int.parse(schedule.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(8, '0').substring(0, 8)),
        '${plant.name} - ${fertilizer.name}',
        schedule.dose != null
            ? 'Fertilizer reminder: ${schedule.dose}'
            : 'Time to fertilize your plant!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fertilizer_reminders',
            'Fertilizer Reminders',
            channelDescription: 'Notifications for fertilizer schedules',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // If exact alarm fails, try with inexact alarm
      if (e.toString().contains('exact_alarms_not_permitted') || 
          e.toString().contains('SCHEDULE_EXACT_ALARM')) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        await _notifications.zonedSchedule(
          int.parse(schedule.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(8, '0').substring(0, 8)),
          '${plant.name} - ${fertilizer.name}',
          schedule.dose != null
              ? 'Fertilizer reminder: ${schedule.dose}'
              : 'Time to fertilize your plant!',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'fertilizer_reminders',
              'Fertilizer Reminders',
              channelDescription: 'Notifications for fertilizer schedules',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        // Re-throw if it's a different error
        rethrow;
      }
    }
  }

  Future<void> cancelNotification(String scheduleId) async {
    final notificationId = int.parse(scheduleId.replaceAll(RegExp(r'[^0-9]'), '').padLeft(8, '0').substring(0, 8));
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> rescheduleAllNotifications() async {
    await cancelAllNotifications();
    final schedules = await _scheduleRepository.getActiveSchedules();
    for (final schedule in schedules) {
      await scheduleNotification(schedule);
    }
  }

  DateTime _getScheduledDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> updateScheduleNotification(ScheduleModel schedule) async {
    await cancelNotification(schedule.id);
    if (schedule.isActive) {
      await scheduleNotification(schedule);
    }
  }

  /// Check if exact alarms are permitted (Android 12+)
  /// Returns true if exact alarms can be scheduled, false otherwise
  Future<bool> canScheduleExactAlarms() async {
    if (!_initialized) await initialize();
    
    // On Android 12+, we need to check if exact alarms are permitted
    // For now, we'll try to schedule and catch the error
    // In a production app, you might want to use a plugin to check this
    return true; // Default to true, will fallback to inexact if needed
  }
}

