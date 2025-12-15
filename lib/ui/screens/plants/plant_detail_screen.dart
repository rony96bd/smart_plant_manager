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
  final PlantRepository _plantRepository = PlantRepository();

  @override
  Widget build(BuildContext context) {
    final scheduleRepository = ScheduleRepository();
    final logRepository = FertilizerLogRepository();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<PlantModel?>(
        future: _plantRepository.getPlantById(widget.plantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(localizations?.translate('plant_not_found') ?? 'Plant not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localizations?.translate('go_back') ?? 'Go Back'),
                  )
                ],
              ),
            );
          }

          final plant = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(plant.name, style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
                  background: plant.imagePath != null
                      ? Hero(
                          tag: 'plant_image_${plant.id}',
                          child: Image.file(
                            File(plant.imagePath!),
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.3),
                            colorBlendMode: BlendMode.darken,
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.local_florist, size: 120, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
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
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, plant);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(localizations?.translate('edit') ?? 'Edit'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(localizations?.translate('delete') ?? 'Delete'),
                      ),
                    ],
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

  Future<void> _deletePlant(PlantModel plant) async {
    try {
      await _plantRepository.deletePlant(plant.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.translate('plant_deleted') ?? 'Plant deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop screen and return 'deleted' to signal a refresh
        Navigator.of(context).pop('deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.translate('delete_failed') ?? 'Failed to delete plant'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, PlantModel plant) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(localizations?.translate('delete_plant') ?? 'Delete Plant'),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(text: localizations?.translate('delete_plant_confirm') ?? 'Are you sure you want to delete'),
                TextSpan(text: ' \'${plant.name}\'?', style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '\n\n'),
                TextSpan(text: localizations?.translate('delete_plant_associated_data') ?? 'All associated schedules and logs will also be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(localizations?.translate('cancel') ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _deletePlant(plant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                localizations?.translate('delete') ?? 'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ],
        );
      },
    );
  }
}
