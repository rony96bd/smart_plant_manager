# TFLite Model Setup

## Instructions

1. Download or create a TensorFlow Lite model file for plant/leaf classification
2. Place the model file as `model.tflite` in this directory
3. Create a `labels.txt` file with one label per line

## Example labels.txt format:
```
Flower
Fruit
Indoor
Outdoor
Bonsai
Cactus
Vegetable
Tree
Leaf
```

## Free TFLite Models

You can find free plant classification models at:
- TensorFlow Hub: https://tfhub.dev/
- Kaggle: https://www.kaggle.com/models
- Model Zoo: https://github.com/tensorflow/models

## Model Requirements

- Input shape: 224x224x3 (RGB image)
- Output: Classification probabilities
- Format: TensorFlow Lite (.tflite)

## Note

If you don't have a model yet, the app will still work but plant detection will show a warning message.

