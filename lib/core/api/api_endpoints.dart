import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000";
    }
    try {
      if (Platform.isAndroid) {
        // Android emulator connects to host localhost via 10.0.2.2
        return "http://10.0.2.2:3000";
      }
    } catch (_) {
      // Platform check can fail on some platforms if not guarded
    }
    return "http://localhost:3000";
  }

  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String auditions = "/auditions";
  static String auditionDetail(String id) => "/auditions/$id";
  static const String photos = "/photos";
  static const String videos = "/videos";
}

