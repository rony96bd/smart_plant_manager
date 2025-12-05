import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../data/models/schedule_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/schedule_display_helper.dart';
import 'add_edit_schedule_screen.dart';

class SchedulesListScreen extends ConsumerStatefulWidget {
  const SchedulesListScreen({super.key});

  @override
  ConsumerState<SchedulesListScreen> createState() => _SchedulesListScreenState();
}

class _SchedulesListScreenState extends ConsumerState<SchedulesListScreen> {
  @override
  Widget build(BuildContext context) {
    final scheduleRepository = ScheduleRepository();
    final plantRepository = PlantRepository();
    final fertilizerRepository = FertilizerRepository();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('schedules') ?? 'Schedules'),
      ),
      body: FutureBuilder<List<ScheduleModel>>(
        future: scheduleRepository.getAllSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) {
            return Center(
              child: Text(
                localizations?.translate('no_schedules') ?? 'No schedules yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
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
                  final allFertilizers = snapshot.data![1] as List<dynamic>;

                  if (plant == null) {
                    return const SizedBox.shrink();
                  }

                  // Get all fertilizers for this schedule
                  final scheduleFertilizers = allFertilizers.where((f) => schedule.fertilizerIds.contains(f.id)).toList();
                  if (scheduleFertilizers.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final fertilizerNames = scheduleFertilizers.map((f) => f.name).join(', ');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        schedule.isActive ? Icons.notifications_active : Icons.notifications_off,
                        color: schedule.isActive ? Colors.green : Colors.grey,
                      ),
                      title: Text('${plant.name} - $fertilizerNames'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ScheduleDisplayHelper.getRemainingTimeText(
                              schedule.nextScheduleDate,
                              locale: Localizations.localeOf(context).languageCode,
                            ),
                            style: TextStyle(
                              color: ScheduleDisplayHelper.getRemainingTimeColor(schedule.nextScheduleDate),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Show doses for each fertilizer
                          ...scheduleFertilizers.map((fertilizer) {
                            final dose = schedule.doses[fertilizer.id];
                            if (dose != null && dose.isNotEmpty) {
                              return Text(
                                '${fertilizer.name}: ${dose}',
                                style: TextStyle(fontSize: 12),
                              );
                            }
                            return const SizedBox.shrink();
                          }).whereType<Widget>(),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text(localizations?.translate('edit') ?? 'Edit'),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditScheduleScreen(schedule: schedule),
                                      ),
                                    ).then((_) {
                                      if (mounted) setState(() {});
                                    }),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: Text(
                              localizations?.translate('delete') ?? 'Delete',
                              style: const TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _deleteSchedule(context, schedule, scheduleRepository),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditScheduleScreen(schedule: schedule),
                          ),
                        ).then((_) {
                          if (mounted) setState(() {});
                        });
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditScheduleScreen(),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteSchedule(
    BuildContext context,
    ScheduleModel schedule,
    ScheduleRepository scheduleRepository,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.translate('delete') ?? 'Delete Schedule'),
        content: Text(
          localizations?.translate('delete_schedule_confirmation') ?? 
          'Are you sure you want to delete this schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations?.translate('delete') ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Cancel notification
        await NotificationService().cancelNotification(schedule.id);
        
        // Delete schedule
        await scheduleRepository.deleteSchedule(schedule.id);
        
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.translate('schedule_deleted') ?? 'Schedule deleted'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
            ),
          );
        }
      }
    }
  }
}

