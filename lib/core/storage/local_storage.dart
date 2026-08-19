import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUserEmail = 'user_email';

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

  Future<void> clearAll() async {
    await _prefs!.remove(_keyToken);
    await _prefs!.remove(_keyUserEmail);
  }

  bool hasToken() {
    return getToken() != null;
  }
}