# 🌿 Smart Plant Manager

A comprehensive Flutter mobile application for managing plants, fertilizers, schedules, and plant detection using TensorFlow Lite.

## Features

### 🌱 Plant Management
- Add, edit, and delete plants
- Categorize plants (Flower, Fruit, Indoor, Outdoor, Bonsai, Cactus, Vegetable, etc.)
- Add plant images from camera or gallery
- Track pot size and notes
- Search and filter plants

### 🧪 Fertilizer Management
- Add, edit, and delete fertilizers
- Categorize by type (NPK, DAP, MOP, Urea, Organic, etc.)
- Store ratio and usage recommendations
- Search fertilizers

### 📅 Fertilizer Scheduling
- Create schedules for each plant
- Multiple repeat types:
  - Once
  - Daily
  - Weekly
  - Every X days
  - Monthly
- Set reminder times
- Automatic notification scheduling
- Auto-update next schedule date when completed

### 📝 Fertilizer Logs
- Log fertilizer applications
- View history per plant
- Link logs to schedules
- Track dose and notes

### 🔔 Notifications
- Local notifications for fertilizer reminders
- Works offline
- Timezone support
- Automatic rescheduling

### 🌍 Localization
- English and Bangla (বাংলা) support
- All UI texts localized
- Language preference saved

### 🌑 Themes
- Material 3 design
- Light and dark mode
- Theme preference saved

### 🤖 Plant Detection
- Offline TensorFlow Lite plant detection
- Camera and gallery support
- Confidence scores
- Category suggestions

### 📊 Dashboard
- Total plants and fertilizers count
- Upcoming reminders
- Recently fertilized plants
- Quick access to all features

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   ├── localization/
│   ├── utils/
│   ├── notifications/
│   └── constants/
├── data/
│   ├── models/
│   ├── db/
│   └── repositories/
├── features/
│   └── detection/
└── ui/
    ├── screens/
    ├── widgets/
    └── components/
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Hive Adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Add TFLite Model (Optional)

1. Download or create a TensorFlow Lite model for plant classification
2. Place it in `assets/tflite/model.tflite`
3. Ensure `assets/tflite/labels.txt` contains your model's labels

**Note:** The app will work without a model, but plant detection will show a warning.

### 4. Run the App

```bash
flutter run
```

## Dependencies

- **flutter_riverpod**: State management
- **hive**: Local database
- **tflite_flutter**: TensorFlow Lite inference
- **flutter_local_notifications**: Local notifications
- **image_picker**: Camera and gallery access
- **shared_preferences**: User preferences
- **intl**: Internationalization

## Database

The app uses Hive for local storage. All data is stored locally on the device.

### Models
- `PlantModel`: Plant information
- `FertilizerModel`: Fertilizer details
- `ScheduleModel`: Fertilizer schedules
- `FertilizerLogModel`: Application logs

## TFLite Model Setup

### Requirements
- Input: 224x224x3 RGB image
- Output: Classification probabilities
- Format: TensorFlow Lite (.tflite)

### Free Models
You can find free plant classification models at:
- [TensorFlow Hub](https://tfhub.dev/)
- [Kaggle](https://www.kaggle.com/models)
- [Model Zoo](https://github.com/tensorflow/models)

## Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take plant photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select plant images</string>
```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

Test key features:
- Fertilizer schedule recurrence logic
- Notification scheduling
- Model inference with sample images
- Language switching persistence
- Theme switching persistence

## Troubleshooting

### TFLite Model Not Loading
- Ensure `model.tflite` is in `assets/tflite/`
- Check `pubspec.yaml` includes the assets path
- Run `flutter clean` and `flutter pub get`

### Notifications Not Working
- Check device notification permissions
- Verify timezone settings
- Ensure notifications are enabled in device settings

### Hive Adapters Not Generated
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Check for errors in the generated files

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Support

For issues and questions, please open an issue on GitHub.

---

**Made with ❤️ for plant lovers**
