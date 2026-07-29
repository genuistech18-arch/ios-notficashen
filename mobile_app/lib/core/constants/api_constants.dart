import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // Override at build/run time with:
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
  // Defaults assume a local backend: 10.0.2.2 is the Android emulator's
  // alias for the host machine's localhost; iOS simulator can use localhost directly.
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String registerPath = '/api/v1/clients/register';
  static String notificationsHistoryPath(String code) =>
      '/api/v1/clients/$code/notifications';
  static String markReadPath(String notificationId) =>
      '/api/v1/notifications/$notificationId/read';
}
