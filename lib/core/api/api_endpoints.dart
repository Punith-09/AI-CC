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

      if (Platform.isIOS) {
        // iOS Simulator
        return 'http://localhost:3000';
      }
    } catch (_) {}

    return 'http://localhost:3000';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static const String exploreUsers = '/users/explore';
  static const String profileMe = '/profile/me';

  static String userProfile(String id) => '/users/$id';
  static String followUser(String id) => '/users/$id/follow';
  static const String auditions = "/auditions";
  static String auditionDetail(String id) => "/auditions/$id";
  static String applyAudition(String id) => "/auditions/$id/apply";

  static const String myApplications = "/applications/me";
  static String withdrawApplication(String id) => "/applications/$id";
  static String updateApplication(String id) => "/applications/$id";
  static String updateApplicationStatus(String id) => "/applications/$id/status";

  static const String photos = "/photos";
  static const String videos = "/videos";

  static const String chats = "/chats";
  static String startChat(String userId) => "/chats/start/$userId";
  static String chatMessages(String chatId) => "/chats/$chatId/messages";
}
