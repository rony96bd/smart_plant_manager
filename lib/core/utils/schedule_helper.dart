import '../../data/models/schedule_model.dart';

class ScheduleHelper {
  static DateTime calculateNextScheduleDate(
    DateTime currentDate,
    RepeatType repeatType,
    int? everyXDays,
  ) {
    switch (repeatType) {
      case RepeatType.once:
        return currentDate;
      case RepeatType.daily:
        return currentDate.add(const Duration(days: 1));
      case RepeatType.weekly:
        return currentDate.add(const Duration(days: 7));
      case RepeatType.everyXDays:
        if (everyXDays != null && everyXDays > 0) {
          return currentDate.add(Duration(days: everyXDays));
        }
        return currentDate.add(const Duration(days: 1));
      case RepeatType.monthly:
        // Add approximately one month
        final nextMonth = DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
        return nextMonth;
    }
  }

  static String getRepeatTypeLabel(RepeatType repeatType, int? everyXDays) {
    switch (repeatType) {
      case RepeatType.once:
        return 'Once';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.everyXDays:
        return everyXDays != null ? 'Every $everyXDays days' : 'Every X days';
      case RepeatType.monthly:
        return 'Monthly';
    }
  }
}

