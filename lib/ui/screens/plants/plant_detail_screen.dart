import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/plant_model.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/fertilizer_log_repository.dart';
import '../../../core/localization/app_localizations.dart';
import 'add_edit_plant_screen.dart';
import '../../../ui/screens/schedules/add_edit_schedule_screen.dart';
import '../../../ui/screens/logs/add_log_screen.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final plantRepository = PlantRepository();
    final scheduleRepository = ScheduleRepository();
    final logRepository = FertilizerLogRepository();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<PlantModel?>(
        future: plantRepository.getPlantById(widget.plantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(localizations?.translate('no_plants') ?? 'Plant not found'),
            );
          }

          final plant = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: plant.imagePath != null
                      ? Image.file(
                          File(plant.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.green[100],
                          child: const Icon(Icons.local_florist, size: 80),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditPlantScreen(plant: plant),
                        ),
                      ).then((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(plant.category)),
                      if (plant.potSize != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${localizations?.translate('pot_size') ?? 'Pot Size'}: ${plant.potSize}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      if (plant.notes != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          localizations?.translate('notes') ?? 'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(plant.notes!),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditScheduleScreen(plantId: plant.id),
                                  ),
                                ).then((_) {
                                  if (mounted) setState(() {});
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: Text(localizations?.translate('add_schedule') ?? 'Add Schedule'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddLogScreen(plantId: plant.id),
                                  ),
                                ).then((_) {
                                  if (mounted) setState(() {});
                                });
                              },
                              icon: const Icon(Icons.check),
                              label: Text(localizations?.translate('logs') ?? 'Add Log'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations?.translate('schedules') ?? 'Schedules',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder(
                        future: scheduleRepository.getSchedulesByPlant(plant.id),
                        builder: (context, snapshot) {
                          final schedules = snapshot.data ?? [];
                          if (schedules.isEmpty) {
                            return Text(
                              localizations?.translate('no_schedules') ?? 'No schedules',
                            );
                          }
                          return Column(
                            children: schedules.map((schedule) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text('Schedule ${schedule.id.substring(0, 8)}'),
                                  subtitle: Text('Next: ${schedule.nextScheduleDate.toString().substring(0, 10)}'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations?.translate('logs') ?? 'Fertilizer History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder(
                        future: logRepository.getLogsByPlant(plant.id),
                        builder: (context, snapshot) {
                          final logs = snapshot.data ?? [];
                          if (logs.isEmpty) {
                            return Text(
                              localizations?.translate('no_logs') ?? 'No logs',
                            );
                          }
                          return Column(
                            children: logs.take(5).map((log) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text('Applied on ${log.appliedAt.toString().substring(0, 10)}'),
                                  subtitle: log.dose != null ? Text('Dose: ${log.dose}') : null,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

