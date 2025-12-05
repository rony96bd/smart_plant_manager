import 'package:flutter/material.dart';
import '../../../data/models/fertilizer_log_model.dart';
import '../../../data/repositories/fertilizer_log_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../../core/notifications/notification_service.dart';

class AddLogScreen extends StatefulWidget {
  final String? plantId;

  const AddLogScreen({super.key, this.plantId});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = FertilizerLogRepository();
  final _plantRepository = PlantRepository();
  final _fertilizerRepository = FertilizerRepository();
  final _scheduleRepository = ScheduleRepository();
  final _notificationService = NotificationService();

  String? _selectedPlantId;
  String? _selectedFertilizerId;
  String? _selectedScheduleId;
  DateTime _appliedAt = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.plantId != null) {
      _selectedPlantId = widget.plantId;
    }
  }

  @override
  void dispose() {
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('logs') ?? 'Add Log'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Plant Selection
                    FutureBuilder(
                      future: _plantRepository.getAllPlants(),
                      builder: (context, snapshot) {
                        final plants = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedPlantId,
                          decoration: InputDecoration(
                            labelText: localizations?.translate('select_plant') ?? 'Select Plant',
                            prefixIcon: const Icon(Icons.local_florist),
                          ),
                          items: plants.map((plant) {
                            return DropdownMenuItem(
                              value: plant.id,
                              child: Text(plant.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlantId = value;
                              _selectedScheduleId = null;
                            });
                            _loadSchedules();
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a plant';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Schedule Selection (Optional)
                    if (_selectedPlantId != null)
                      FutureBuilder(
                        future: _scheduleRepository.getSchedulesByPlant(_selectedPlantId!),
                        builder: (context, snapshot) {
                          final schedules = snapshot.data ?? [];
                          if (schedules.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedScheduleId,
                            decoration: const InputDecoration(
                              labelText: 'Select Schedule (Optional)',
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None'),
                              ),
                              ...schedules.map((schedule) {
                                return DropdownMenuItem(
                                  value: schedule.id,
                                  child: Text('Schedule ${schedule.id.substring(0, 8)}'),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedScheduleId = value);
                              if (value != null) {
                                _loadScheduleData(value);
                              }
                            },
                          );
                        },
                      ),

                    if (_selectedScheduleId != null) const SizedBox(height: 16),

                    // Fertilizer Selection
                    FutureBuilder(
                      future: _fertilizerRepository.getAllFertilizers(),
                      builder: (context, snapshot) {
                        final fertilizers = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedFertilizerId,
                          decoration: InputDecoration(
                            labelText: localizations?.translate('select_fertilizer') ?? 'Select Fertilizer',
                            prefixIcon: const Icon(Icons.science),
                          ),
                          items: fertilizers.map((fertilizer) {
                            return DropdownMenuItem(
                              value: fertilizer.id,
                              child: Text(fertilizer.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedFertilizerId = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a fertilizer';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dose
                    TextFormField(
                      controller: _doseController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('dose') ?? 'Dose (Optional)',
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('notes') ?? 'Notes (Optional)',
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Applied At
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Applied At'),
                      subtitle: Text(_appliedAt.toString().substring(0, 16)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _appliedAt,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_appliedAt),
                          );
                          if (time != null) {
                            setState(() {
                              _appliedAt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveLog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(localizations?.translate('save') ?? 'Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _loadSchedules() async {
    // Trigger rebuild to show schedules
    setState(() {});
  }

  Future<void> _loadScheduleData(String scheduleId) async {
    final schedule = await _scheduleRepository.getScheduleById(scheduleId);
    if (schedule != null) {
      setState(() {
        _selectedFertilizerId = schedule.fertilizerId;
        _doseController.text = schedule.dose ?? '';
        _notesController.text = schedule.notes ?? '';
      });
    }
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final log = FertilizerLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: _selectedPlantId!,
        fertilizerId: _selectedFertilizerId!,
        scheduleId: _selectedScheduleId,
        dose: _doseController.text.trim().isEmpty ? null : _doseController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        appliedAt: _appliedAt,
        createdAt: now,
      );

      await _repository.addLog(log);

      // If log was created from a schedule, update the schedule's next date
      if (_selectedScheduleId != null) {
        final schedule = await _scheduleRepository.getScheduleById(_selectedScheduleId!);
        if (schedule != null && schedule.isActive) {
          final nextDate = ScheduleHelper.calculateNextScheduleDate(
            _appliedAt,
            schedule.repeatTypeEnum,
            schedule.everyXDays,
          );
          final updatedSchedule = schedule.copyWith(
            nextScheduleDate: nextDate,
            updatedAt: now,
          );
          await _scheduleRepository.updateSchedule(updatedSchedule);
          await _notificationService.updateScheduleNotification(updatedSchedule);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

