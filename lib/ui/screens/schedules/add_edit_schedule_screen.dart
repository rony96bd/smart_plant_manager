import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../../core/notifications/notification_service.dart';
import 'package:intl/intl.dart';

class AddEditScheduleScreen extends ConsumerStatefulWidget {
  final String? plantId;
  final ScheduleModel? schedule;

  const AddEditScheduleScreen({super.key, this.plantId, this.schedule});

  @override
  ConsumerState<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends ConsumerState<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();
  final _everyXDaysController = TextEditingController();
  final _repository = ScheduleRepository();
  final _plantRepository = PlantRepository();
  final _fertilizerRepository = FertilizerRepository();
  final _notificationService = NotificationService();

  String? _selectedPlantId;
  String? _selectedFertilizerId;
  RepeatType _repeatType = RepeatType.once;
  DateTime _nextScheduleDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _selectedPlantId = widget.schedule!.plantId;
      _selectedFertilizerId = widget.schedule!.fertilizerId;
      _repeatType = widget.schedule!.repeatTypeEnum;
      _nextScheduleDate = widget.schedule!.nextScheduleDate;
      _reminderTime = widget.schedule!.reminderTime;
      _isActive = widget.schedule!.isActive;
      _doseController.text = widget.schedule!.dose ?? '';
      _notesController.text = widget.schedule!.notes ?? '';
      if (widget.schedule!.everyXDays != null) {
        _everyXDaysController.text = widget.schedule!.everyXDays.toString();
      }
    } else if (widget.plantId != null) {
      _selectedPlantId = widget.plantId;
    }
  }

  @override
  void dispose() {
    _doseController.dispose();
    _notesController.dispose();
    _everyXDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEdit = widget.schedule != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? localizations?.translate('edit_schedule') ?? 'Edit Schedule'
              : localizations?.translate('add_schedule') ?? 'Add Schedule',
        ),
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
                            setState(() => _selectedPlantId = value);
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

                    // Repeat Type
                    DropdownButtonFormField<RepeatType>(
                      initialValue: _repeatType,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('repeat_type') ?? 'Repeat Type',
                        prefixIcon: const Icon(Icons.repeat),
                      ),
                      items: RepeatType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getRepeatTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _repeatType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Every X Days (if applicable)
                    if (_repeatType == RepeatType.everyXDays)
                      TextFormField(
                        controller: _everyXDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Every X Days',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of days';
                          }
                          final days = int.tryParse(value);
                          if (days == null || days <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                    // Next Schedule Date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(localizations?.translate('next_schedule') ?? 'Next Schedule'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_nextScheduleDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _nextScheduleDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() => _nextScheduleDate = date);
                        }
                      },
                    ),

                    // Reminder Time
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(localizations?.translate('reminder_time') ?? 'Reminder Time'),
                      subtitle: Text(_reminderTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (time != null) {
                          setState(() => _reminderTime = time);
                        }
                      },
                    ),

                    // Active Toggle
                    SwitchListTile(
                      title: Text(localizations?.translate('schedules') ?? 'Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveSchedule,
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

  String _getRepeatTypeLabel(RepeatType type) {
    final localizations = AppLocalizations.of(context);
    switch (type) {
      case RepeatType.once:
        return localizations?.translate('once') ?? 'Once';
      case RepeatType.daily:
        return localizations?.translate('daily') ?? 'Daily';
      case RepeatType.weekly:
        return localizations?.translate('weekly') ?? 'Weekly';
      case RepeatType.everyXDays:
        return localizations?.translate('every_x_days') ?? 'Every X Days';
      case RepeatType.monthly:
        return localizations?.translate('monthly') ?? 'Monthly';
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_repeatType == RepeatType.everyXDays) {
      if (_everyXDaysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter number of days')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final schedule = ScheduleModel(
        id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: _selectedPlantId!,
        fertilizerId: _selectedFertilizerId!,
        dose: _doseController.text.trim().isEmpty ? null : _doseController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        repeatType: _repeatType.index,
        everyXDays: _repeatType == RepeatType.everyXDays
            ? int.tryParse(_everyXDaysController.text)
            : null,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
        nextScheduleDate: _nextScheduleDate,
        isActive: _isActive,
        createdAt: widget.schedule?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.addSchedule(schedule);

      // Schedule notification
      if (_isActive) {
        await _notificationService.scheduleNotification(schedule);
      } else {
        await _notificationService.cancelNotification(schedule.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.schedule != null ? 'Schedule updated' : 'Schedule added')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error: $e';
        if (e.toString().contains('exact_alarms_not_permitted')) {
          errorMessage = 'Schedule saved, but exact alarm permission is required for precise notifications. '
              'Please enable "Schedule exact alarms" in app settings.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

