import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/plant_model.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants.dart';
import '../../../features/detection/plant_detection_screen.dart';

class AddEditPlantScreen extends StatefulWidget {
  final PlantModel? plant;

  const AddEditPlantScreen({super.key, this.plant});

  @override
  State<AddEditPlantScreen> createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends State<AddEditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _potSizeController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = PlantRepository();
  final _imagePicker = ImagePicker();

  String? _selectedCategory;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _selectedCategory = widget.plant!.category;
      _potSizeController.text = widget.plant!.potSize ?? '';
      _notesController.text = widget.plant!.notes ?? '';
      _imagePath = widget.plant!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _potSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEdit = widget.plant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? localizations?.translate('edit_plant') ?? 'Edit Plant'
              : localizations?.translate('add_plant') ?? 'Add Plant',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _showImageSourceDialog,
            tooltip: localizations?.translate('detect_plant') ?? 'Detect Plant',
          ),
        ],
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
                    // Image Preview
                    if (_imagePath != null)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() => _imagePath = null);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                localizations?.translate('camera') ?? 'Add Image',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Plant Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('plant_name') ?? 'Plant Name',
                        prefixIcon: const Icon(Icons.local_florist),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter plant name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('category') ?? 'Category',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: AppConstants.plantCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pot Size
                    TextFormField(
                      controller: _potSizeController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('pot_size') ?? 'Pot Size',
                        prefixIcon: const Icon(Icons.square_foot),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('notes') ?? 'Notes',
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _savePlant,
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('detect_plant') ?? 'Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)?.translate('camera') ?? 'Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)?.translate('gallery') ?? 'Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(AppLocalizations.of(context)?.translate('detect_plant') ?? 'Detect Plant'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDetection();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _navigateToDetection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantDetectionScreen(),
      ),
    ).then((result) {
      if (result != null && result is Map) {
        setState(() {
          _imagePath = result['imagePath'];
          if (result['category'] != null) {
            _selectedCategory = result['category'];
          }
        });
      }
    });
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final plant = PlantModel(
        id: widget.plant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        imagePath: _imagePath,
        potSize: _potSizeController.text.trim().isEmpty ? null : _potSizeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.plant?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.addPlant(plant);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.plant != null ? 'Plant updated' : 'Plant added')),
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

