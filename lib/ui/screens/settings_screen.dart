import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
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
            subtitle: Text(localizations?.translate('backup_restore_subtitle') ?? 'Export/Import app data'),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<Map<String, int>>(
                      future: BackupService.getBackupStats(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
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
                                Text('${localizations?.translate('plants') ?? 'Plants'}: ${stats['plants'] ?? 0}'),
                                Text('${localizations?.translate('fertilizers') ?? 'Fertilizers'}: ${stats['fertilizers'] ?? 0}'),
                                Text('${localizations?.translate('schedules') ?? 'Schedules'}: ${stats['schedules'] ?? 0}'),
                                Text('${localizations?.translate('logs') ?? 'Logs'}: ${stats['logs'] ?? 0}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _createBackup(context),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(localizations?.translate('create_backup') ?? 'Create Backup'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _restoreBackup(context),
                      icon: const Icon(Icons.cloud_download_outlined),
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
            leading: const Icon(Icons.info_outline),
            title: Text(localizations?.translate('about') ?? 'About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(24),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/App_Logo.png', height: 60),
                        const SizedBox(height: 16),
                        Text(
                          localizations?.translate('app_title') ?? 'Smart Plant Manager',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const Text('Version 1.0.0'),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/developer.jpg'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rakib Uddin Rony',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations?.translate('app_developer') ?? 'App Developer',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showLicensePage(context: context);
                        },
                        child: Text(localizations?.translate('licenses') ?? 'Licenses'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(localizations?.translate('close') ?? 'Close'),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final path = await BackupService.createAndSaveBackup();
      if (!mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.translate('backup_created_successfully_at') ?? 'Backup saved to'}: $path'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.translate('backup_cancelled') ?? 'Backup cancelled by user.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)?.translate('backup_failed') ?? 'Backup failed'}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    try {
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('restore_backup') ?? 'Restore Backup'),
          content: Text(
            AppLocalizations.of(context)?.translate('restore_warning_destructive') ??
                'This will REPLACE all current data with the data from the backup file. This action cannot be undone. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)?.translate('restore') ?? 'Restore'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final stats = await BackupService.restoreFromBackup();
      if (!mounted) return;

      if (stats != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)?.translate('backup_restored') ?? 'Backup restored!'}\n'
              '${AppLocalizations.of(context)?.translate('plants') ?? 'Plants'}: ${stats['plants']}, '
              '${AppLocalizations.of(context)?.translate('fertilizers') ?? 'Fertilizers'}: ${stats['fertilizers']}, '
              '${AppLocalizations.of(context)?.translate('schedules') ?? 'Schedules'}: ${stats['schedules']}, '
              '${AppLocalizations.of(context)?.translate('logs') ?? 'Logs'}: ${stats['logs']}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.translate('restore_cancelled') ?? 'Restore cancelled by user.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)?.translate('restore_failed') ?? 'Restore failed'}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
