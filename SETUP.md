# Setup Guide

## Step-by-Step Setup Instructions

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Generate Code (Hive Adapters)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the Hive adapter files for all models.

### 3. Configure Android Permissions

Edit `android/app/src/main/AndroidManifest.xml` and add:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 4. Configure iOS Permissions

Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take plant photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select plant images</string>
```

### 5. Add TFLite Model (Optional)

1. Download a plant classification model (see README.md for sources)
2. Place it as `assets/tflite/model.tflite`
3. Update `assets/tflite/labels.txt` with your model's labels

**Note:** The app works without a model, but detection will show a warning.

### 6. Run the App

```bash
flutter run
```

## First Run

1. The app will initialize Hive database automatically
2. Notifications service will be initialized
3. You can start adding plants and fertilizers

## Common Issues

### Build Runner Errors
If you see errors about missing generated files:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### TFLite Model Issues
- Ensure the model file exists in `assets/tflite/`
- Check that `pubspec.yaml` includes the assets path
- The app will show a warning if the model is missing (this is normal)

### Notification Permissions
- Android 13+ requires runtime permission for notifications
- The app will request permission on first use

## Testing Checklist

- [ ] Add a plant
- [ ] Add a fertilizer
- [ ] Create a schedule
- [ ] Test notifications
- [ ] Switch language
- [ ] Toggle theme
- [ ] Test plant detection (if model is available)

