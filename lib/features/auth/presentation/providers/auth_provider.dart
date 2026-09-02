import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authRepository.isUserLoggedIn();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email.trim(), password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  String _cleanErrorMessage(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        final msg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            responseData['detail']?.toString() ??
            responseData['msg']?.toString();
        if (msg != null && msg.isNotEmpty && !msg.toLowerCase().contains('internal server error')) {
          return msg;
        }
      }
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        return 'Invalid email/HCC ID or password. Please try again.';
      } else if (statusCode == 404) {
        return 'Account not found. Please check your credentials or sign up.';
      } else if (statusCode == 500) {
        return 'Server error. Please try again later.';
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Network connection error. Please check your internet connection.';
      }
      return 'Invalid email/HCC ID or password. Please try again.';
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.contains('DioException') || raw.contains('RequestOptions.validateStatus') || raw.isEmpty) {
      return 'Invalid email/HCC ID or password. Please try again.';
    }
    return raw;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    notifyListeners();
  }
}
