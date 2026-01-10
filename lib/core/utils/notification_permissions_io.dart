import 'package:permission_handler/permission_handler.dart';

/// Requests notification permission on mobile platforms (Android / iOS).
/// Returns true if granted.
Future<bool> requestNotificationPermission() async {
  try {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  } catch (e) {
    return false;
  }
}
