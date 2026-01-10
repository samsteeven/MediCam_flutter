import 'notification_permissions_io.dart'
    if (dart.library.html) 'notification_permissions_web.dart'
    as impl;

/// Facade: delegates to the correct platform implementation.
Future<bool> requestNotificationPermission() =>
    impl.requestNotificationPermission();
