import 'package:permission_handler/permission_handler.dart';

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

  /// Open app settings to manually enable permissions
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
