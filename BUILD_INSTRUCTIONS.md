# Build Instructions

## Prerequisites

- Flutter SDK 3.10.3 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Android SDK / Xcode Command Line Tools

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Generate Code

Generate Hive adapters and other code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

If you encounter issues, try:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 3: Configure Permissions

### Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- ... existing code ... -->
    </application>
</manifest>
```

### iOS

Edit `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take plant photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select plant images</string>
```

## Step 4: Add TFLite Model (Optional)

1. Download a plant classification TFLite model
2. Place it as `assets/tflite/model.tflite`
3. Update `assets/tflite/labels.txt` with your model's labels

**Note:** The app works without a model, but detection will show a warning.

## Step 5: Run the App

### Development

```bash
flutter run
```

### Release Build

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Build Runner Errors

If you see errors about missing generated files:

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### TFLite Model Issues

- Ensure `model.tflite` exists in `assets/tflite/`
- Check `pubspec.yaml` includes the assets path
- The app will show a warning if the model is missing (this is normal)

### Notification Permissions

- Android 13+ requires runtime permission
- The app will request permission on first use
- Check device settings if notifications don't work

### Import Errors

If you see import errors:
1. Run `flutter pub get`
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Restart your IDE

## Testing

After building, test:
- [ ] Add a plant
- [ ] Add a fertilizer
- [ ] Create a schedule
- [ ] Test notifications
- [ ] Switch language
- [ ] Toggle theme
- [ ] Test plant detection (if model is available)

## Next Steps

See `SETUP.md` for detailed setup instructions and `README.md` for feature documentation.

