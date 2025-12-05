import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/fertilizer_repository.dart';
import '../../data/models/schedule_model.dart';
import '../../core/localization/app_localizations.dart';
import 'package:intl/intl.dart';

class UpcomingRemindersList extends ConsumerWidget {
  const UpcomingRemindersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleRepository = ScheduleRepository();
    final plantRepository = PlantRepository();
    final fertilizerRepository = FertilizerRepository();
    final localizations = AppLocalizations.of(context);

    return FutureBuilder<List<ScheduleModel>>(
      future: scheduleRepository.getUpcomingSchedules(
        DateTime.now().add(const Duration(days: 7)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                localizations?.translate('no_schedules') ?? 'No schedules yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final schedules = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length > 5 ? 5 : schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return FutureBuilder(
              future: Future.wait([
                plantRepository.getPlantById(schedule.plantId),
                fertilizerRepository.getFertilizerById(schedule.fertilizerId),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final plant = snapshot.data![0] as dynamic;
                final fertilizer = snapshot.data![1] as dynamic;

                if (plant == null || fertilizer == null) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: Text('${plant.name} - ${fertilizer.name}'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(schedule.nextScheduleDate),
                    ),
                    trailing: schedule.dose != null
                        ? Chip(
                            label: Text(schedule.dose!),
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

