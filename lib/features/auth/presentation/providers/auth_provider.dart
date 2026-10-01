import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/login_response.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/models/register_request.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get userRole => _currentUser?.role ?? LocalStorage.instance.getUserRole();
  bool get isLoggedIn => _authRepository.isUserLoggedIn();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(identifier.trim(), password);
      _currentUser = response.userModel;
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

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(request);
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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.loginWithGoogle();
      _isLoading = false;
      notifyListeners();
      return _authRepository.isUserLoggedIn();
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
        final rawMsg = responseData['message'] ??
            responseData['error'] ??
            responseData['detail'] ??
            responseData['msg'];
        String msg = '';
        if (rawMsg is List) {
          msg = rawMsg.join(', ');
        } else if (rawMsg != null) {
          msg = rawMsg.toString();
        }
        if (msg.isNotEmpty && !msg.toLowerCase().contains('internal server error')) {
          return msg;
        }
      }
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        return 'Invalid email / phone / TRK ID or password. Please try again.';
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
      return 'Invalid email / phone / TRK ID or password. Please try again.';
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.contains('DioException') || raw.contains('RequestOptions.validateStatus') || raw.isEmpty) {
      return 'Invalid email / phone / TRK ID or password. Please try again.';
    }
    return raw;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _authRepository.logout();
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
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

  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(token, newPassword);
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
}
