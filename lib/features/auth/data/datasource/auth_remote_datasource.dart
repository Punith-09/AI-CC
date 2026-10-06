import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

import '../models/login_response.dart';
import '../models/register_request.dart';


abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(
    String identifier,
    String password,
  );

  Future<LoginResponse> register(
    RegisterRequest request,
  );

  Future<LoginResponse> loginWithGoogle(String idToken);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String newPassword, {String? email, String? otp});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  // ============================
  // LOGIN
  // ============================

  @override
  Future<LoginResponse> login(
    String identifier,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      if (response.data is Map) {
        return LoginResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception(
        'Invalid login server response format',
      );
    } on DioException catch (e) {
      print('LOGIN API DIO ERROR: ${e.response?.data}');
      final responseData = e.response?.data;
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
          throw Exception(msg);
        }
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        throw Exception('Invalid identifier or password. Please try again.');
      } else if (statusCode == 404) {
        throw Exception('Account not found. Please check your credentials or sign up.');
      } else if (statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Network connection error. Please check your internet connection.');
      }
      throw Exception('Invalid identifier or password. Please try again.');
    } catch (e) {
      print('LOGIN API ERROR: $e');
      rethrow;
    }
  }

  // ============================
  // REGISTER
  // ============================

  @override
  Future<LoginResponse> register(
      RegisterRequest request,
      ) async {
    try {
      final requestData = request.toJson();

      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data);
        return LoginResponse.fromJson(data);
      }

      throw Exception(
        'Invalid registration server response format',
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        final msg = responseData['message']?.toString() ?? responseData['error']?.toString() ?? '';
        final lower = msg.toLowerCase();
        if (lower.contains('mobile') || lower.contains('phone') || lower.contains('users_mobile_unique')) {
          throw Exception('This mobile number is already registered.');
        }
        if (lower.contains('email') || lower.contains('users_email_unique')) {
          throw Exception('A user with this email address already exists.');
        }
        if (msg.isNotEmpty && msg != 'Internal server error') {
          throw Exception(msg);
        }
      }
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      rethrow;
    }
  }


  // ============================
  // GOOGLE LOGIN
  // ============================

  @override
  Future<LoginResponse> loginWithGoogle(String idToken) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.googleLogin,
        data: {
          'idToken': idToken,
        },
      );

      if (response.data is Map) {
        return LoginResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception(
        'Invalid google login server response format',
      );
    } on DioException catch (e) {
      print('GOOGLE LOGIN API DIO ERROR: ${e.response?.data}');
      final responseData = e.response?.data;
      if (responseData is Map) {
        final msg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            '';
        if (msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      throw Exception('Google Sign-In failed on backend.');
    } catch (e) {
       print('GOOGLE LOGIN API ERROR: $e');
       rethrow;
    }
  }

  // ============================
  // FORGOT PASSWORD
  // ============================

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?.toString();
      if (msg != null && msg.isNotEmpty) {
        throw Exception(msg);
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 400) {
        throw Exception('Email ID not found in database. Please check your email or sign up.');
      }
      throw Exception('Failed to send reset email. Please check your connection and try again.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword, {String? email, String? otp}) async {
    try {
      await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'otp': otp ?? token,
          'newPassword': newPassword,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.response?.data?['error']?.toString();
      if (msg != null && msg.isNotEmpty) {
        throw Exception(msg);
      }
      throw Exception('Failed to reset password. OTP/Token might be invalid or expired.');
    } catch (e) {
      rethrow;
    }
  }
}