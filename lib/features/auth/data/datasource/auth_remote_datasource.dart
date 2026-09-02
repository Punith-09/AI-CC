import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

import '../models/login_response.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(
      String email,
      String password,
      );

  Future<LoginResponse> register(
      RegisterRequest request,
      );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  // ============================
  // LOGIN
  // ============================

  @override
  Future<LoginResponse> login(
      String email,
      String password,
      ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
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
        final msg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            responseData['detail']?.toString() ??
            responseData['msg']?.toString() ??
            '';
        if (msg.isNotEmpty && !msg.toLowerCase().contains('internal server error')) {
          throw Exception(msg);
        }
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        throw Exception('Invalid email/HCC ID or password. Please try again.');
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
      throw Exception('Invalid email/HCC ID or password. Please try again.');
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

      // Debug: See exactly what Flutter is sending
      print('========================================');
      print('REGISTER API REQUEST');
      print('URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.register}');
      print('DATA: $requestData');
      print('========================================');

      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      print('========================================');
      print('REGISTER API RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.data}');
      print('========================================');

      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data);
        return LoginResponse.fromJson(data);
      }

      throw Exception(
        'Invalid registration server response format',
      );
    } on DioException catch (e) {
      print('REGISTER API DIO ERROR: ${e.response?.data}');
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
        if (lower.contains('duplicate') || lower.contains('unique constraint')) {
          throw Exception('This mobile number or email is already registered.');
        }
        if (msg.isNotEmpty && msg != 'Internal server error') {
          throw Exception(msg);
        }
      }
      if (e.response?.statusCode == 500) {
        throw Exception('This mobile number is already registered. Please use another number.');
      }
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      print('REGISTER API ERROR: $e');
      rethrow;
    }
  }
}