import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fertilizer_log_repository.dart';
import '../../data/repositories/plant_repository.dart';
import '../../data/repositories/fertilizer_repository.dart';
import '../../core/localization/app_localizations.dart';
import 'package:intl/intl.dart';

class RecentLogsList extends ConsumerWidget {
  const RecentLogsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logRepository = FertilizerLogRepository();
    final plantRepository = PlantRepository();
    final fertilizerRepository = FertilizerRepository();
    final localizations = AppLocalizations.of(context);

    return FutureBuilder(
      future: logRepository.getRecentLogs(5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                localizations?.translate('no_logs') ?? 'No logs yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final logs = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return FutureBuilder(
              future: Future.wait([
                plantRepository.getPlantById(log.plantId),
                fertilizerRepository.getFertilizerById(log.fertilizerId),
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
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('${plant.name} - ${fertilizer.name}'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(log.appliedAt),
                    ),
                    trailing: log.dose != null
                        ? Chip(
                            label: Text(log.dose!),
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

