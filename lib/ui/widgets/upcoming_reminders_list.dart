import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/fertilizer_repository.dart';
import '../../data/models/schedule_model.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/schedule_display_helper.dart';

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
                  fertilizerRepository.getAllFertilizers(),
                ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final plant = snapshot.data![0] as dynamic;
                final fertilizers = snapshot.data![1] as List<dynamic>;

                if (plant == null) {
                  return const SizedBox.shrink();
                }

                // Get fertilizers for this schedule
                final scheduleFertilizers = fertilizers.where((f) => schedule.fertilizerIds.contains(f.id)).toList();
                if (scheduleFertilizers.isEmpty) {
                  return const SizedBox.shrink();
                }

                final fertilizerNames = scheduleFertilizers.map((f) => f.name).join(', ');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: Text('${plant.name} - $fertilizerNames'),
                      subtitle: Text(
                        ScheduleDisplayHelper.getRemainingTimeText(
                          schedule.nextScheduleDate,
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                        style: TextStyle(
                          color: ScheduleDisplayHelper.getRemainingTimeColor(schedule.nextScheduleDate),
                          fontWeight: FontWeight.w500,
                        ),
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

