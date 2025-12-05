import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../core/utils/constants.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      // Load labels
      try {
        final labelData = await rootBundle.loadString(AppConstants.tfliteLabelsPath);
        _labels = labelData.split('\n').where((label) => label.trim().isNotEmpty).toList();
      } catch (e) {
        print('Warning: Could not load labels file. Using default labels.');
        _labels = ['Plant', 'Flower', 'Leaf', 'Tree', 'Vegetable'];
      }

      // Load model
      try {
        _interpreter = await Interpreter.fromAsset(AppConstants.tfliteModelPath);
        _isLoaded = true;
      } catch (e) {
        print('Error loading TFLite model: $e');
        print('Note: Please add a TFLite model file to assets/tflite/model.tflite');
        _isLoaded = false;
      }
    } catch (e) {
      print('Error initializing TFLite service: $e');
      _isLoaded = false;
    }
  }

  Future<Map<String, dynamic>?> predictImage(String imagePath) async {
    if (!_isLoaded || _interpreter == null) {
      await loadModel();
      if (!_isLoaded || _interpreter == null) {
        return {
          'label': 'Model not loaded',
          'confidence': 0.0,
          'index': -1,
          'error': 'TFLite model is not available. Please add model.tflite to assets/tflite/',
        };
      }
    }

    try {
      // Read and preprocess image
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return null;
      }

      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return null;
      }

      // Resize image to model input size (typically 224x224 for image classification)
      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Get model input/output shapes
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      
      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;

      // Prepare input buffer
      final inputSize = inputShape.reduce((a, b) => a * b);
      final inputBuffer = Float32List(inputSize);

      // Convert image to float32 array and normalize
      _imageToFloatList(resizedImage, inputBuffer);

      // Prepare output buffer
      final outputSize = outputShape.reduce((a, b) => a * b);
      final outputBuffer = Float32List(outputSize);

      // Run inference
      _interpreter!.run(inputBuffer, outputBuffer);

      // Get top prediction
      final topIndex = _getTopPrediction(outputBuffer);
      final confidence = outputBuffer[topIndex];

      String label = 'Unknown';
      if (topIndex < _labels.length && topIndex >= 0) {
        label = _labels[topIndex];
      }

      return {
        'label': label,
        'confidence': confidence,
        'index': topIndex,
      };
    } catch (e) {
      print('Error during prediction: $e');
      return {
        'label': 'Error',
        'confidence': 0.0,
        'index': -1,
        'error': e.toString(),
      };
    }
  }

  void _imageToFloatList(img.Image image, Float32List buffer) {
    int pixelIndex = 0;
    const int imageSize = 224;

    for (int i = 0; i < imageSize; i++) {
      for (int j = 0; j < imageSize; j++) {
        final pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r / 255.0);
        buffer[pixelIndex++] = (pixel.g / 255.0);
        buffer[pixelIndex++] = (pixel.b / 255.0);
      }
    }
  }

  int _getTopPrediction(Float32List predictions) {
    int maxIndex = 0;
    double maxValue = predictions[0];

    for (int i = 1; i < predictions.length; i++) {
      if (predictions[i] > maxValue) {
        maxValue = predictions[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}

