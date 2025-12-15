import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../data/models/fertilizer_model.dart';
import '../../../core/localization/app_localizations.dart';
import 'add_edit_fertilizer_screen.dart';

class FertilizersListScreen extends ConsumerStatefulWidget {
  const FertilizersListScreen({super.key});

  @override
  ConsumerState<FertilizersListScreen> createState() => _FertilizersListScreenState();
}

class _FertilizersListScreenState extends ConsumerState<FertilizersListScreen> {
  final FertilizerRepository _repository = FertilizerRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('fertilizers') ?? 'Fertilizers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations?.translate('search') ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FertilizerModel>>(
              stream: _repository.watchFertilizers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                var fertilizers = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  fertilizers = fertilizers
                      .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (fertilizers.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.translate('no_fertilizers_or_no_results') ?? 'No fertilizers found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: fertilizers.length,
                  itemBuilder: (context, index) {
                    final fertilizer = fertilizers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.science_outlined, size: 40),
                        title: Text(fertilizer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fertilizer.type),
                            if (fertilizer.ratio != null) Text('Ratio: ${fertilizer.ratio}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                             if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditFertilizerScreen(fertilizer: fertilizer),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (value == 'delete') {
                              _deleteFertilizer(context, fertilizer);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(localizations?.translate('edit') ?? 'Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                localizations?.translate('delete') ?? 'Delete',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditFertilizerScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteFertilizer(BuildContext context, FertilizerModel fertilizer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('delete_fertilizer') ?? 'Delete Fertilizer'),
        content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(text: AppLocalizations.of(context)?.translate('delete_fertilizer_confirm') ?? 'Are you sure you want to delete'),
                TextSpan(text: ' \'${fertilizer.name}\'?', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
             style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            child: Text(
              AppLocalizations.of(context)?.translate('delete') ?? 'Delete',
               style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteFertilizer(fertilizer.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.translate('fertilizer_deleted') ?? 'Fertilizer deleted'), backgroundColor: Colors.green,),
          );
        }
      } catch (e) {
         if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)?.translate('delete_failed') ?? 'Failed to delete fertilizer'}: $e'), backgroundColor: Colors.red,),
          );
        }
      }
    }
  }
}
