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
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations?.translate('language') ?? 'Language'),
            subtitle: Text(
              locale.languageCode == 'bn' ? 'বাংলা' : 'English',
            ),
            trailing: DropdownButton<Locale>(
              value: locale,
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('bn'),
                  child: Text('বাংলা'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                }
              },
            ),
          ),
          const Divider(),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Smart Plant Manager v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Smart Plant Manager',
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

