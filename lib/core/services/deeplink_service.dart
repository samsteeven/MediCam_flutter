import 'dart:async';

import 'package:flutter/services.dart';

class DeeplinkService {
  static const MethodChannel _methodChannel = MethodChannel(
    'easypharma/deeplink',
  );
  static const EventChannel _eventChannel = EventChannel(
    'easypharma/deeplink_stream',
  );

  static Stream<String?>? _stream;

  static Future<String?> getInitialLink() async {
    try {
      final result = await _methodChannel.invokeMethod<String?>(
        'getInitialLink',
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  static Stream<String?> get linkStream {
    _stream ??= _eventChannel.receiveBroadcastStream().map((event) {
      if (event == null) return null;
      return event as String;
    });
    return _stream!;
  }
}
