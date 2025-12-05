import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/fertilizer_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/fertilizer_log_repository.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_reminders_list.dart';
import '../widgets/recent_logs_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final plantRepository = PlantRepository();
    final fertilizerRepository = FertilizerRepository();
    final scheduleRepository = ScheduleRepository();
    final logRepository = FertilizerLogRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('dashboard') ?? 'Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              FutureBuilder(
                future: Future.wait([
                  plantRepository.getAllPlants(),
                  fertilizerRepository.getAllFertilizers(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final plants = snapshot.data?[0] as List? ?? [];
                  final fertilizers = snapshot.data?[1] as List? ?? [];

                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: localizations?.translate('total_plants') ?? 'Total Plants',
                          value: plants.length.toString(),
                          icon: Icons.local_florist,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: localizations?.translate('total_fertilizers') ?? 'Total Fertilizers',
                          value: fertilizers.length.toString(),
                          icon: Icons.science,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Upcoming Reminders
              Text(
                localizations?.translate('upcoming_reminders') ?? 'Upcoming Reminders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const UpcomingRemindersList(),
              const SizedBox(height: 24),

              // Recently Fertilized
              Text(
                localizations?.translate('recently_fertilized') ?? 'Recently Fertilized',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const RecentLogsList(),
            ],
          ),
        ),
      ),
    );
  }
}

