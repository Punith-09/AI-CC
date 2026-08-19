import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator → computer localhost
        return 'http://10.0.2.2:3000';
      }

      if (Platform.isIOS) {
        // iOS Simulator
        return 'http://localhost:3000';
      }
    } catch (_) {}

    return 'http://localhost:3000';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
}