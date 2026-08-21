import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserId = 'user_id';
  static const String _keyUserProfilePhoto = 'user_profile_photo';

  static LocalStorage? _instance;
  static SharedPreferences? _prefs;

  LocalStorage._();

  /// Initialize LocalStorage only once.
  static Future<void> init() async {
    if (_instance != null && _prefs != null) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _instance = LocalStorage._();
  }

  /// Get singleton instance.
  static LocalStorage get instance {
    if (_instance == null || _prefs == null) {
      throw StateError(
        'LocalStorage is not initialized. '
        'Call await LocalStorage.init() first.',
      );
    }

    return _instance!;
  }

  Future<void> saveToken(String token) async {
    await _prefs!.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs!.getString(_keyToken);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs!.setString(_keyUserEmail, email);
  }

  String? getUserEmail() {
    return _prefs!.getString(_keyUserEmail);
  }

  Future<void> saveUserId(String id) async {
    await _prefs!.setString(_keyUserId, id);
  }

  String? getUserId() {
    final id = _prefs!.getString(_keyUserId);
    if (id != null && id.trim().isNotEmpty) {
      return id;
    }

    // Try extracting from JWT token payload
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedBytes = base64Url.decode(normalized);
          final decodedString = utf8.decode(decodedBytes);
          final jsonMap = json.decode(decodedString);
          if (jsonMap is Map) {
            final tokenId = jsonMap['sub'] ??
                jsonMap['id'] ??
                jsonMap['_id'] ??
                jsonMap['userId'];
            if (tokenId != null && tokenId.toString().trim().isNotEmpty) {
              return tokenId.toString();
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }

  Future<void> saveUserName(String name) async {
    await _prefs!.setString(_keyUserName, name);
  }

  String? getUserName() {
    final name = _prefs!.getString(_keyUserName);
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    // Try extracting from JWT token payload
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedBytes = base64Url.decode(normalized);
          final decodedString = utf8.decode(decodedBytes);
          final jsonMap = json.decode(decodedString);
          if (jsonMap is Map) {
            final tokenName = jsonMap['fullName'] ??
                jsonMap['name'] ??
                jsonMap['username'] ??
                jsonMap['userName'];
            if (tokenName != null && tokenName.toString().trim().isNotEmpty) {
              return tokenName.toString();
            }
            if (jsonMap['email'] != null && jsonMap['email'].toString().isNotEmpty) {
              final emailStr = jsonMap['email'].toString();
              return emailStr.split('@')[0];
            }
          }
        }
      } catch (_) {}
    }

    // Try extracting from email
    final email = getUserEmail();
    if (email != null && email.isNotEmpty) {
      return email.split('@')[0];
    }

    return null;
  }

  Future<void> saveUserProfilePhoto(String photoUrl) async {
    await _prefs!.setString(_keyUserProfilePhoto, photoUrl);
  }

  String? getUserProfilePhoto() {
    return _prefs!.getString(_keyUserProfilePhoto);
  }

  Future<void> clearAll() async {
    await _prefs!.remove(_keyToken);
    await _prefs!.remove(_keyUserEmail);
    await _prefs!.remove(_keyUserName);
    await _prefs!.remove(_keyUserId);
    await _prefs!.remove(_keyUserProfilePhoto);
  }

  bool hasToken() {
    return getToken() != null;
  }
}