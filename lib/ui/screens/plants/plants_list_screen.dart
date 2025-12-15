import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/models/plant_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants.dart';
import 'add_edit_plant_screen.dart';
import 'plant_detail_screen.dart';

class PlantsListScreen extends ConsumerStatefulWidget {
  const PlantsListScreen({super.key});

  @override
  ConsumerState<PlantsListScreen> createState() => _PlantsListScreenState();
}

class _PlantsListScreenState extends ConsumerState<PlantsListScreen> {
  final PlantRepository _repository = PlantRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

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
        title: Text(localizations?.translate('plants') ?? 'Plants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
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
            child: StreamBuilder<List<PlantModel>>(
              stream: _repository.watchPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                var plants = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  plants = plants
                      .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                } else if (_selectedCategory != null) {
                  plants = plants.where((p) => p.category == _selectedCategory).toList();
                }

                if (plants.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.translate('no_plants_or_no_results') ?? 'No plants found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: plant.imagePath != null
                              ? FileImage(File(plant.imagePath!))
                              : null,
                          child: plant.imagePath == null
                              ? const Icon(Icons.local_florist)
                              : null,
                        ),
                        title: Text(plant.name),
                        subtitle: Text(plant.category),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditPlantScreen(plant: plant),
                                ),
                              ).then((_) => setState(() {}));
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailScreen(plantId: plant.id),
                            ),
                          ).then((result) {
                            if (result == 'deleted') {
                              setState(() {}); 
                            }
                          });
                        },
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
              builder: (context) => const AddEditPlantScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deletePlant(String plantId) async {
    try {
      await _repository.deletePlant(plantId); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.translate('plant_deleted') ?? 'Plant deleted successfully'), backgroundColor: Colors.green),
        );
        setState(() {}); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.translate('delete_failed') ?? 'Failed to delete plant'}: $e'), backgroundColor: Colors.red),
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
                _deletePlant(plant.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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

  void _showFilterDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.translate('filter') ?? 'Filter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: Text(localizations?.translate('all') ?? 'All'),
                value: null,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = null);
                  Navigator.pop(context);
                },
              ),
              ...AppConstants.plantCategories.map((category) => RadioListTile<String?>(
                title: Text(category),
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
