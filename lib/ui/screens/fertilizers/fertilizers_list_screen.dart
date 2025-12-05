import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../data/models/fertilizer_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants.dart';
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
            child: FutureBuilder<List<FertilizerModel>>(
              future: _searchQuery.isNotEmpty
                  ? _repository.searchFertilizers(_searchQuery)
                  : _repository.getAllFertilizers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final fertilizers = snapshot.data ?? [];

                if (fertilizers.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.translate('no_fertilizers') ?? 'No fertilizers yet',
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
                        leading: const Icon(Icons.science, size: 40),
                        title: Text(fertilizer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fertilizer.type),
                            if (fertilizer.ratio != null) Text('Ratio: ${fertilizer.ratio}'),
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
                                          builder: (context) => AddEditFertilizerScreen(fertilizer: fertilizer),
                                        ),
                                      ).then((_) => setState(() {})),
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
                                  () => _deleteFertilizer(context, fertilizer.id),
                                );
                              },
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

  Future<void> _deleteFertilizer(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
        content: const Text('Are you sure you want to delete this fertilizer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)?.translate('delete') ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteFertilizer(id);
      if (context.mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fertilizer deleted')),
        );
      }
    }
  }
}

