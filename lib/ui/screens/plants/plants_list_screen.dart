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
            child: FutureBuilder<List<PlantModel>>(
              future: _getPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final plants = snapshot.data ?? [];

                if (plants.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.translate('no_plants') ?? 'No plants yet',
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
                              ? Image.file(plant.imagePath as dynamic).image
                              : null,
                          child: plant.imagePath == null
                              ? const Icon(Icons.local_florist)
                              : null,
                        ),
                        title: Text(plant.name),
                        subtitle: Text(plant.category),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlantDetailScreen(plantId: plant.id),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailScreen(plantId: plant.id),
                            ),
                          );
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

  Future<List<PlantModel>> _getPlants() async {
    if (_searchQuery.isNotEmpty) {
      return await _repository.searchPlants(_searchQuery);
    } else if (_selectedCategory != null) {
      return await _repository.filterByCategory(_selectedCategory!);
    } else {
      return await _repository.getAllPlants();
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('filter') ?? 'Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...AppConstants.plantCategories.map((category) => RadioListTile<String?>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    Navigator.pop(context);
                  },
                )),
            RadioListTile<String?>(
              title: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'All'),
              value: null,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

