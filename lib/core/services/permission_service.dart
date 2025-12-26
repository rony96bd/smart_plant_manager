import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 30) {
        // Android 11 (R) and above, MANAGE_EXTERNAL_STORAGE is needed for broad access
        // However, for picking files, no special permission is needed.
        // For saving, we let the user pick a directory.
        return true; // No explicit permission needed for file picker
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // For iOS
  }

  /// Request all necessary permissions at once
  static Future<void> requestAllPermissions() async {
    await requestStoragePermission();
    await requestNotificationPermission();
  }

  /// Open app settings to manually enable permissions
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
