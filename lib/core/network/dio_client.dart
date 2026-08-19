import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,

        connectTimeout:
        const Duration(seconds: 15),

        receiveTimeout:
        const Duration(seconds: 15),

        sendTimeout:
        const Duration(seconds: 15),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
      String path, {
        dynamic data,
      }) async {
    return await _dio.put(
      path,
      data: data,
    );
  }

  Future<Response> delete(
      String path, {
        dynamic data,
      }) async {
    return await _dio.delete(
      path,
      data: data,
    );
  }
}