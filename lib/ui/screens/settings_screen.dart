import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/backup_service.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('settings') ?? 'Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(localizations?.translate('theme') ?? 'Theme'),
            subtitle: Text(
              isDarkMode
                  ? localizations?.translate('dark_mode') ?? 'Dark Mode'
                  : localizations?.translate('light_mode') ?? 'Light Mode',
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(value);
              },
            ),
          ),
          const Divider(),

          // Language Section
          ExpansionTile(
            leading: const Icon(Icons.language),
            title: Text(localizations?.translate('language') ?? 'Language'),
            subtitle: Text(
              locale.languageCode == 'bn' ? 'বাংলা (Bangla)' : 'English',
            ),
            children: [
              RadioListTile<Locale>(
                title: const Text('English'),
                subtitle: const Text('English (Default)'),
                value: const Locale('en'),
                groupValue: locale,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(value);
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('বাংলা'),
                subtitle: const Text('Bangla'),
                value: const Locale('bn'),
                groupValue: locale,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(value);
                  }
                },
              ),
            ],
          ),
          const Divider(),

          // Backup & Restore Section
          ExpansionTile(
            leading: const Icon(Icons.backup),
            title: Text(localizations?.translate('backup_restore') ?? 'Backup & Restore'),
            subtitle: const Text('Export/Import app data'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder(
                      future: BackupService.getBackupStats(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final stats = snapshot.data ?? {};
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.translate('data_summary') ?? 'Data Summary',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text('Plants: ${stats['plants'] ?? 0}'),
                                Text('Fertilizers: ${stats['fertilizers'] ?? 0}'),
                                Text('Schedules: ${stats['schedules'] ?? 0}'),
                                Text('Logs: ${stats['logs'] ?? 0}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _createBackup(context),
                      icon: const Icon(Icons.backup),
                      label: Text(localizations?.translate('create_backup') ?? 'Create Backup'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _restoreBackup(context),
                      icon: const Icon(Icons.restore),
                      label: Text(localizations?.translate('restore_backup') ?? 'Restore Backup'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(localizations?.translate('about') ?? 'About'),
            subtitle: const Text('Smart Plant Manager v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: localizations?.translate('app_title') ?? 'Smart Plant Manager',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.local_florist, size: 48),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      await BackupService.createBackup();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate('backup_created') ?? 'Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();

        if (!BackupService.validateBackupFile(jsonData)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid backup file format'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)?.translate('restore_backup') ?? 'Restore Backup'),
            content: Text(
              AppLocalizations.of(context)?.translate('restore_warning') ??
              'This will add data from the backup file. Existing data will remain. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)?.translate('restore') ?? 'Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final stats = await BackupService.importData(jsonData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Backup restored!\n'
                'Plants: ${stats['plants']}, '
                'Fertilizers: ${stats['fertilizers']}, '
                'Schedules: ${stats['schedules']}, '
                'Logs: ${stats['logs']}'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

