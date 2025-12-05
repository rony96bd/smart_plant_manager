import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: localizations?.translate('dashboard') ?? 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_florist),
          label: localizations?.translate('plants') ?? 'Plants',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.science),
          label: localizations?.translate('fertilizers') ?? 'Fertilizers',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.schedule),
          label: localizations?.translate('schedules') ?? 'Schedules',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: localizations?.translate('logs') ?? 'Logs',
        ),
      ],
    );
  }
}

