import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/theme_provider.dart';

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
}

