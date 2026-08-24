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
    } catch (e) {
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
      // ========================================
      // PRE-REGISTRATION MOBILE VALIDATION
      // ========================================
      try {
        final usersResponse = await _dioClient.get(ApiEndpoints.exploreUsers);
        
        List<dynamic> usersList = [];
        final rawData = usersResponse.data;
        if (rawData is List) {
          usersList = rawData;
        } else if (rawData is Map) {
          final inner = rawData['data'] ??
              rawData['users'] ??
              rawData['results'] ??
              rawData['talents'] ??
              [];
          usersList = inner is List ? inner : [];
        }

        final isRegistered = usersList.any(
          (user) => user is Map && (user['mobile'] == request.mobile || user['phone'] == request.mobile),
        );

        if (isRegistered) {
          throw Exception('Mobile number is already registered.');
        }
      } catch (e) {
        if (e.toString().contains('Mobile number is already registered')) {
          rethrow;
        }
      }

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
        if (data.containsKey('message') && 
            (data['token'] == null || data['token'].toString().isEmpty) && 
            (data['accessToken'] == null) && 
            (data['access_token'] == null)) {
          throw Exception(data['message']);
        }
        return LoginResponse.fromJson(data);
      }

      throw Exception(
        'Invalid registration server response format',
      );
    } on DioException catch (e) {
      print('REGISTER API DIO ERROR: ${e.response?.data}');
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      } else if (e.response?.data is Map && e.response!.data['error'] != null) {
        throw Exception(e.response!.data['error']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('REGISTER API ERROR: $e');
      rethrow;
    }
  }
}