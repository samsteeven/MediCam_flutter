import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easypharma_flutter/core/services/location_service.dart';
import 'notification_permissions.dart';

/// Request app permissions after login/register in a single call.
/// Mirrors the behaviour of location permission flow: tries to obtain
/// permissions but never throws to the UI; logs errors and continues.
Future<void> requestAllPermissions() async {
  // 1) Notifications (web / mobile)
  try {
    final notifGranted = await requestNotificationPermission();
    debugPrint('Notification permission granted: $notifGranted');
  } catch (e) {
    debugPrint('Error requesting notification permission: $e');
  }

  // 2) Location: call LocationService.getCurrentLocation to trigger prompt
  try {
    final locService = LocationService();
    await locService.getCurrentLocation();
    debugPrint('Location requested successfully');
  } catch (e) {
    debugPrint('Location request failed or denied: $e');
  }

  // 3) Camera + Storage/Photos
  try {
    // Camera
    final camStatus = await Permission.camera.status;
    if (!camStatus.isGranted) {
      final r = await Permission.camera.request();
      debugPrint('Camera permission: ${r.isGranted}');
    }

    // Storage / Photos
    if (kIsWeb) {
      // Web does not use permission_handler for photos; skip
      debugPrint('Web: skipping storage/photos request');
    } else if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        final r = await Permission.storage.request();
        debugPrint('Storage permission: ${r.isGranted}');
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        final r = await Permission.photos.request();
        debugPrint('Photos permission: ${r.isGranted}');
      }
    }
  } catch (e) {
    debugPrint('Error requesting camera/storage permissions: $e');
  }
}
