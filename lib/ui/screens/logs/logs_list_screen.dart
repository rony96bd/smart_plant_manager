import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/fertilizer_log_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'add_log_screen.dart';

class LogsListScreen extends ConsumerStatefulWidget {
  const LogsListScreen({super.key});

  @override
  ConsumerState<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends ConsumerState<LogsListScreen> {
  @override
  Widget build(BuildContext context) {
    final logRepository = FertilizerLogRepository();
    final plantRepository = PlantRepository();
    final fertilizerRepository = FertilizerRepository();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('logs') ?? 'Logs'),
      ),
      body: FutureBuilder(
        future: logRepository.getAllLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Text(
                localizations?.translate('no_logs') ?? 'No logs yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text('${plant.name} - ${fertilizer.name}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(log.appliedAt),
                          ),
                          if (log.dose != null) Text('Dose: ${log.dose}'),
                          if (log.notes != null) Text('Notes: ${log.notes}'),
                        ],
                      ),
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
              builder: (context) => const AddLogScreen(),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

