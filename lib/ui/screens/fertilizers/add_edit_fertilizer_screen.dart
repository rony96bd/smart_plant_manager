import 'package:flutter/material.dart';
import '../../../data/models/fertilizer_model.dart';
import '../../../data/repositories/fertilizer_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants.dart';

class AddEditFertilizerScreen extends StatefulWidget {
  final FertilizerModel? fertilizer;

  const AddEditFertilizerScreen({super.key, this.fertilizer});

  @override
  State<AddEditFertilizerScreen> createState() => _AddEditFertilizerScreenState();
}

class _AddEditFertilizerScreenState extends State<AddEditFertilizerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratioController = TextEditingController();
  final _usageController = TextEditingController();
  final _repository = FertilizerRepository();

  String? _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.fertilizer != null) {
      _nameController.text = widget.fertilizer!.name;
      _selectedType = widget.fertilizer!.type;
      _ratioController.text = widget.fertilizer!.ratio ?? '';
      _usageController.text = widget.fertilizer!.usageRecommendations ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ratioController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEdit = widget.fertilizer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? localizations?.translate('edit_fertilizer') ?? 'Edit Fertilizer'
              : localizations?.translate('add_fertilizer') ?? 'Add Fertilizer',
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
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('fertilizer_name') ?? 'Fertilizer Name',
                        prefixIcon: const Icon(Icons.science),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fertilizer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('type') ?? 'Type',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: AppConstants.fertilizerTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ratio
                    TextFormField(
                      controller: _ratioController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('ratio') ?? 'Ratio (Optional)',
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Usage Recommendations
                    TextFormField(
                      controller: _usageController,
                      decoration: InputDecoration(
                        labelText: localizations?.translate('usage_recommendations') ?? 'Usage Recommendations (Optional)',
                        prefixIcon: const Icon(Icons.info),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveFertilizer,
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

  Future<void> _saveFertilizer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final fertilizer = FertilizerModel(
        id: widget.fertilizer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType!,
        ratio: _ratioController.text.trim().isEmpty ? null : _ratioController.text.trim(),
        usageRecommendations: _usageController.text.trim().isEmpty ? null : _usageController.text.trim(),
        createdAt: widget.fertilizer?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.addFertilizer(fertilizer);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.fertilizer != null ? 'Fertilizer updated' : 'Fertilizer added')),
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

