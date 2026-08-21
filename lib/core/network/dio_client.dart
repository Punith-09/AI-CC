import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';
import '../storage/local_storage.dart';

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

        validateStatus: (status) {
          return status != null &&
              status >= 200 &&
              status < 300;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final token =
            LocalStorage.instance.getToken();

            if (token != null &&
                token.isNotEmpty) {
              options.headers['Authorization'] =
              'Bearer $token';
            }

            print(
              "TOKEN EXISTS: ${token != null && token.isNotEmpty}",
            );
          } catch (e) {
            print(
              "TOKEN ERROR: $e",
            );
          }

          print("REQUEST URL: ${options.uri}");
          print("REQUEST METHOD: ${options.method}");
          print("REQUEST HEADERS: ${options.headers}");
          print("REQUEST BODY: ${options.data}");

          return handler.next(options);
        },

        onResponse: (response, handler) {
          print(
            "RESPONSE STATUS: ${response.statusCode}",
          );

          print(
            "RESPONSE DATA: ${response.data}",
          );

          return handler.next(response);
        },

        onError: (DioException error, handler) {
          print("==============================");
          print("DIO ERROR");
          print("==============================");

          print(
            "URL: ${error.requestOptions.uri}",
          );

          print(
            "METHOD: ${error.requestOptions.method}",
          );

          print(
            "REQUEST DATA: ${error.requestOptions.data}",
          );

          print(
            "STATUS: ${error.response?.statusCode}",
          );

          print(
            "SERVER RESPONSE: ${error.response?.data}",
          );

          print(
            "ERROR MESSAGE: ${error.message}",
          );

          print("==============================");

          return handler.next(error);
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

  Dio get dio => _dio;

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

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}