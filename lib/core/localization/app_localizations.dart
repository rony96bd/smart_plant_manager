import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Smart Plant Manager',
      'plants': 'Plants',
      'fertilizers': 'Fertilizers',
      'schedules': 'Schedules',
      'logs': 'Logs',
      'dashboard': 'Dashboard',
      'settings': 'Settings',
      'add_plant': 'Add Plant',
      'edit_plant': 'Edit Plant',
      'plant_name': 'Plant Name',
      'category': 'Category',
      'pot_size': 'Pot Size',
      'notes': 'Notes',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'search': 'Search',
      'filter': 'Filter',
      'add_fertilizer': 'Add Fertilizer',
      'edit_fertilizer': 'Edit Fertilizer',
      'fertilizer_name': 'Fertilizer Name',
      'type': 'Type',
      'ratio': 'Ratio',
      'usage_recommendations': 'Usage Recommendations',
      'add_schedule': 'Add Schedule',
      'edit_schedule': 'Edit Schedule',
      'select_plant': 'Select Plant',
      'select_fertilizer': 'Select Fertilizer',
      'dose': 'Dose',
      'repeat_type': 'Repeat Type',
      'reminder_time': 'Reminder Time',
      'once': 'Once',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'every_x_days': 'Every X Days',
      'monthly': 'Monthly',
      'next_schedule': 'Next Schedule',
      'detect_plant': 'Detect Plant',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'language': 'Language',
      'theme': 'Theme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'total_plants': 'Total Plants',
      'total_fertilizers': 'Total Fertilizers',
      'upcoming_reminders': 'Upcoming Reminders',
      'recently_fertilized': 'Recently Fertilized',
      'no_plants': 'No plants yet',
      'no_fertilizers': 'No fertilizers yet',
      'no_schedules': 'No schedules yet',
      'no_logs': 'No logs yet',
      'edit': 'Edit',
      'delete_schedule_confirmation': 'Are you sure you want to delete this schedule?',
      'schedule_deleted': 'Schedule deleted',
      'model_not_loaded': 'TFLite model not loaded',
      'model_not_loaded_message': 'Please add model.tflite to assets/tflite/ folder.',
      'detection_tips': 'Tips: Take clear photos in good lighting. Show the full plant for best results.',
      'detection_result': 'Detection Result',
      'confidence': 'Confidence',
    },
    'bn': {
      'app_title': 'স্মার্ট প্ল্যান্ট ম্যানেজার',
      'plants': 'গাছ',
      'fertilizers': 'সার',
      'schedules': 'সময়সূচী',
      'logs': 'লগ',
      'dashboard': 'ড্যাশবোর্ড',
      'settings': 'সেটিংস',
      'add_plant': 'গাছ যোগ করুন',
      'edit_plant': 'গাছ সম্পাদনা করুন',
      'plant_name': 'গাছের নাম',
      'category': 'বিভাগ',
      'pot_size': 'পাত্রের আকার',
      'notes': 'নোট',
      'save': 'সংরক্ষণ',
      'cancel': 'বাতিল',
      'delete': 'মুছুন',
      'search': 'খুঁজুন',
      'filter': 'ফিল্টার',
      'add_fertilizer': 'সার যোগ করুন',
      'edit_fertilizer': 'সার সম্পাদনা করুন',
      'fertilizer_name': 'সারের নাম',
      'type': 'ধরন',
      'ratio': 'অনুপাত',
      'usage_recommendations': 'ব্যবহারের সুপারিশ',
      'add_schedule': 'সময়সূচী যোগ করুন',
      'edit_schedule': 'সময়সূচী সম্পাদনা করুন',
      'select_plant': 'গাছ নির্বাচন করুন',
      'select_fertilizer': 'সার নির্বাচন করুন',
      'dose': 'মাত্রা',
      'repeat_type': 'পুনরাবৃত্তির ধরন',
      'reminder_time': 'অনুস্মারক সময়',
      'once': 'একবার',
      'daily': 'দৈনিক',
      'weekly': 'সাপ্তাহিক',
      'every_x_days': 'প্রতি X দিন',
      'monthly': 'মাসিক',
      'next_schedule': 'পরবর্তী সময়সূচী',
      'detect_plant': 'গাছ সনাক্ত করুন',
      'camera': 'ক্যামেরা',
      'gallery': 'গ্যালারি',
      'language': 'ভাষা',
      'theme': 'থিম',
      'light_mode': 'হালকা মোড',
      'dark_mode': 'ডার্ক মোড',
      'total_plants': 'মোট গাছ',
      'total_fertilizers': 'মোট সার',
      'upcoming_reminders': 'আসন্ন অনুস্মারক',
      'recently_fertilized': 'সম্প্রতি সার দেওয়া',
      'no_plants': 'এখনও কোন গাছ নেই',
      'no_fertilizers': 'এখনও কোন সার নেই',
      'no_schedules': 'এখনও কোন সময়সূচী নেই',
      'no_logs': 'এখনও কোন লগ নেই',
      'edit': 'সম্পাদনা',
      'delete_schedule_confirmation': 'আপনি কি এই সময়সূচীটি মুছতে চান?',
      'schedule_deleted': 'সময়সূচী মুছে ফেলা হয়েছে',
      'model_not_loaded': 'TFLite মডেল লোড হয়নি',
      'model_not_loaded_message': 'অনুগ্রহ করে assets/tflite/ ফোল্ডারে model.tflite যোগ করুন।',
      'detection_tips': 'টিপস: ভাল আলোতে পরিষ্কার ছবি তুলুন। সেরা ফলাফলের জন্য পুরো গাছ দেখান।',
      'detection_result': 'সনাক্তকরণ ফলাফল',
      'confidence': 'আত্মবিশ্বাস',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

