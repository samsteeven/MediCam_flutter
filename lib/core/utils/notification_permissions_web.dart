import 'dart:html' as html;

/// Requests notification permission on web. Returns true if granted.
Future<bool> requestNotificationPermission() async {
  try {
    final current = html.Notification.permission;
    if (current == 'granted') return true;
    final result = await html.Notification.requestPermission();
    return result == 'granted';
  } catch (e) {
    return false;
  }
}
