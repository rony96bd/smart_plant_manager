import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/constants.dart';
import 'tflite_service.dart';

class PlantDetectionScreen extends StatefulWidget {
  const PlantDetectionScreen({super.key});

  @override
  State<PlantDetectionScreen> createState() => _PlantDetectionScreenState();
}

class _PlantDetectionScreenState extends State<PlantDetectionScreen> {
  final _tfliteService = TFLiteService();
  final _imagePicker = ImagePicker();
  String? _imagePath;
  Map<String, dynamic>? _prediction;
  bool _isLoading = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() => _isLoading = true);
    await _tfliteService.loadModel();
    setState(() {
      _modelLoaded = _tfliteService.isLoaded;
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _prediction = null;
        });
        await _predictImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _predictImage(String imagePath) async {
    setState(() => _isLoading = true);
    try {
      final result = await _tfliteService.predictImage(imagePath);
      setState(() {
        _prediction = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during prediction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('detect_plant') ?? 'Detect Plant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_modelLoaded)
              Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.warning, size: 48, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.translate('model_not_loaded') ?? 'TFLite model not loaded',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.translate('model_not_loaded_message') ?? 
                        'Please add model.tflite to assets/tflite/ folder.\n\n'
                        'You can download free plant classification models from:\n'
                        '• TensorFlow Hub\n'
                        '• Kaggle\n'
                        '• Model Zoo',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations?.translate('detection_tips') ?? 
                          'Tips: Take clear photos in good lighting. Show the full plant for best results.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Image Picker Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _modelLoaded ? () => _pickImage(ImageSource.camera) : null,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(localizations?.translate('camera') ?? 'Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _modelLoaded ? () => _pickImage(ImageSource.gallery) : null,
                    icon: const Icon(Icons.photo_library),
                    label: Text(localizations?.translate('gallery') ?? 'Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Image Preview
            if (_imagePath != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(_imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],

            // Prediction Result
            if (_prediction != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.translate('detection_result') ?? 'Detection Result',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _prediction!['label'] ?? 'Unknown',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${localizations?.translate('confidence') ?? 'Confidence'}: ${((_prediction!['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${((_prediction!['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                            ),
                            backgroundColor: (_prediction!['confidence'] ?? 0.0) > 0.7
                                ? Colors.green[100]
                                : (_prediction!['confidence'] ?? 0.0) > 0.5
                                    ? Colors.orange[100]
                                    : Colors.red[100],
                          ),
                        ],
                      ),
                      if (_prediction!['error'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _prediction!['error'],
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Use This Image Button
            if (_imagePath != null && _prediction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final category = _getCategoryFromLabel(_prediction!['label']);
                  Navigator.pop(context, {
                    'imagePath': _imagePath,
                    'category': category,
                    'detectedLabel': _prediction!['label'],
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(localizations?.translate('save') ?? 'Use This Image'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getCategoryFromLabel(String label) {
    final lowerLabel = label.toLowerCase();
    for (final category in AppConstants.plantCategories) {
      if (lowerLabel.contains(category.toLowerCase())) {
        return category;
      }
    }
    return 'Other';
  }
}

