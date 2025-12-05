import 'package:flutter/material.dart';

class ScheduleDisplayHelper {
  static String getRemainingTimeText(DateTime scheduleDate, {String? locale = 'en'}) {
    final now = DateTime.now();
    final difference = scheduleDate.difference(now);

    if (difference.isNegative) {
      return locale == 'bn' ? 'সময় অতিবাহিত' : 'Time passed';
    }

    // More accurate calculation
    final totalMinutes = difference.inMinutes;
    final totalHours = difference.inHours;
    final totalDays = difference.inDays;

    // Calculate remaining time more accurately
    final remainingDays = totalDays;
    final remainingHours = totalHours - (totalDays * 24);
    final remainingMinutes = totalMinutes - (totalHours * 60);

    if (totalDays > 7) {
      return locale == 'bn'
          ? _formatDateBangla(scheduleDate)
          : _formatDateEnglish(scheduleDate);
    } else if (totalDays > 1) {
      return locale == 'bn'
          ? '$totalDays দিন পরে (${_formatTimeBangla(scheduleDate)})'
          : 'In $totalDays days (at ${_formatTimeEnglish(scheduleDate)})';
    } else if (totalDays == 1) {
      return locale == 'bn'
          ? 'আগামীকাল ${_formatTimeBangla(scheduleDate)}-এ'
          : 'Tomorrow at ${_formatTimeEnglish(scheduleDate)}';
    } else if (totalHours >= 1) {
      final hourText = locale == 'bn'
          ? '$remainingHours ঘণ্টা'
          : '$remainingHours hour${remainingHours == 1 ? '' : 's'}';
      final minuteText = remainingMinutes > 0
          ? (locale == 'bn' ? '$remainingMinutes মিনিট' : ' $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}')
          : '';
      return locale == 'bn'
          ? '$hourText$minuteText পরে'
          : 'In $hourText$minuteText';
    } else if (remainingMinutes > 0) {
      return locale == 'bn'
          ? '$remainingMinutes মিনিট পরে'
          : 'In $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}';
    } else {
      return locale == 'bn' ? 'এখনই' : 'Now';
    }
  }

  static Color getRemainingTimeColor(DateTime scheduleDate) {
    final now = DateTime.now();
    final difference = scheduleDate.difference(now);

    if (difference.isNegative) {
      return Colors.red; // Overdue
    } else if (difference.inHours < 1) {
      return Colors.red; // Less than 1 hour (urgent)
    } else if (difference.inHours < 6) {
      return Colors.deepOrange; // Less than 6 hours (very urgent)
    } else if (difference.inHours < 24) {
      return Colors.orange; // Less than 24 hours (today)
    } else if (difference.inDays < 3) {
      return Colors.amber; // Less than 3 days (soon)
    } else {
      return Colors.green; // More than 3 days (plenty of time)
    }
  }

  static String _formatDateEnglish(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatTimeEnglish(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDateBangla(DateTime date) {
    final months = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
                    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return '${date.day} ${months[date.month - 1]}, ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatTimeBangla(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
