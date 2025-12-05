class AppConstants {
  // Plant Categories
  static const List<String> plantCategories = [
    'Flower',
    'Fruit',
    'Indoor',
    'Outdoor',
    'Bonsai',
    'Cactus',
    'Vegetable',
    'Herb',
    'Tree',
    'Shrub',
    'Other',
  ];

  // Fertilizer Types
  static const List<String> fertilizerTypes = [
    'NPK',
    'DAP',
    'MOP',
    'Urea',
    'Organic',
    'Mixed',
    'Compost',
    'Humic',
    'Bio-fertilizer',
    'Other',
  ];

  // TFLite Model Paths
  static const String tfliteModelPath = 'assets/tflite/model.tflite';
  static const String tfliteLabelsPath = 'assets/tflite/labels.txt';

  // Image Paths
  static const String defaultPlantImage = 'assets/images/default_plant.png';
}

