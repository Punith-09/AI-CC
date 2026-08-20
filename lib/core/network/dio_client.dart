import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
           // We would need to import LocalStorage, wait let's just make get/post accept options
          return handler.next(options);
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
        Options? options,
      }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    return await _dio.put(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    return await _dio.delete(
      path,
      data: data,
      options: options,
    );
  }
}