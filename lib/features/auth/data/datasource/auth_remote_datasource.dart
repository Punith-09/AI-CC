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
        return LoginResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception(
        'Invalid registration server response format',
      );
    } catch (e) {
      print('REGISTER API ERROR: $e');
      rethrow;
    }
  }
}