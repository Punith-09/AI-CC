import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/application_model.dart';

abstract class ApplyJobRemoteDataSource {
  Future<ApplicationModel> applyForAudition(
      String auditionId, {
        required String coverLetter,
      });

  Future<List<ApplicationModel>> getMyApplications();

  Future<void> withdrawApplication(
      String applicationId,
      );

  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      );
}

class ApplyJobRemoteDataSourceImpl
    implements ApplyJobRemoteDataSource {
  final DioClient _dioClient;

  ApplyJobRemoteDataSourceImpl(
      this._dioClient,
      );

  // =========================================================
  // APPLY
  // =========================================================

  @override
  Future<ApplicationModel> applyForAudition(
      String auditionId, {
        required String coverLetter,
      }) async {
    try {
      print('');
      print('========================================');
      print('🚀 APPLY AUDITION API');
      print('========================================');
      print('AUDITION ID: $auditionId');
      print(
        'URL: ${ApiEndpoints.applyAudition(auditionId)}',
      );
      print('METHOD: POST');
      print('BODY:');
      print({
        'coverLetter': coverLetter,
      });
      print('========================================');

      final response = await _dioClient.post(
        ApiEndpoints.applyAudition(auditionId),
        data: {
          'coverLetter': coverLetter,
        },
      );

      print('');
      print('========================================');
      print('✅ APPLY SUCCESS');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');

      final Map<String, dynamic>? applicationJson =
      _extractApplicationMap(response.data);

      if (applicationJson == null) {
        throw Exception(
          'Invalid server response for application.',
        );
      }

      final application =
      ApplicationModel.fromJson(
        applicationJson,
      );

      print('APPLICATION ID: ${application.id}');
      print('AUDITION ID: ${application.auditionId}');

      return application;
    } on DioException catch (e) {
      _printDioError(
        'APPLY AUDITION ERROR',
        e,
      );

      rethrow;
    }
  }

  // =========================================================
  // GET MY APPLICATIONS
  // =========================================================

  @override
  Future<List<ApplicationModel>>
  getMyApplications() async {
    try {
      print('');
      print('========================================');
      print('📋 GET MY APPLICATIONS');
      print('========================================');
      print(
        'URL: ${ApiEndpoints.myApplications}',
      );
      print('========================================');

      final response = await _dioClient.get(
        ApiEndpoints.myApplications,
      );

      print('');
      print('========================================');
      print('✅ GET APPLICATIONS SUCCESS');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');

      final List<dynamic>? list =
      _extractApplicationList(
        response.data,
      );

      if (list == null) {
        throw Exception(
          'Invalid server response for my applications.',
        );
      }

      final applications = <ApplicationModel>[];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final application =
          ApplicationModel.fromJson(item);

          print(
            'APPLICATION => '
                'ID: ${application.id}, '
                'AUDITION: ${application.auditionId}',
          );

          applications.add(application);
        }
      }

      return applications;
    } on DioException catch (e) {
      _printDioError(
        'GET MY APPLICATIONS ERROR',
        e,
      );

      rethrow;
    }
  }

  // =========================================================
  // WITHDRAW APPLICATION
  // =========================================================

  @override
  Future<void> withdrawApplication(
      String applicationId,
      ) async {
    try {
      print('');
      print('========================================');
      print('🗑️ WITHDRAW APPLICATION');
      print('========================================');
      print('APPLICATION ID: $applicationId');
      print(
        'URL: ${ApiEndpoints.withdrawApplication(applicationId)}',
      );
      print('METHOD: DELETE');
      print('========================================');

      /*
      IMPORTANT:

      This DELETE request deletes/withdraws the APPLICATION.

      It does NOT delete the audition.

      The applicationId MUST be the application ID,
      NOT the audition ID.
      */

      final response = await _dioClient.delete(
        ApiEndpoints.withdrawApplication(
          applicationId,
        ),
      );

      print('');
      print('========================================');
      print('✅ APPLICATION WITHDRAWN');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');
    } on DioException catch (e) {
      _printDioError(
        'WITHDRAW APPLICATION ERROR',
        e,
      );

      rethrow;
    }
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  @override
  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      ) async {
    try {
      await _dioClient.patch(
        ApiEndpoints.updateApplicationStatus(
          applicationId,
        ),
        data: {
          'status': status,
        },
      );
    } on DioException catch (e) {
      _printDioError(
        'UPDATE APPLICATION STATUS ERROR',
        e,
      );

      rethrow;
    }
  }

  // =========================================================
  // RESPONSE HELPERS
  // =========================================================

  Map<String, dynamic>? _extractApplicationMap(
      dynamic data,
      ) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    dynamic current = data;

    /*
    Possible responses:

    {
      data: {...}
    }

    {
      data: {
        application: {...}
      }
    }

    {
      application: {...}
    }
    */

    if (current['application']
    is Map<String, dynamic>) {
      return current['application'];
    }

    if (current['data']
    is Map<String, dynamic>) {
      final dataMap =
      current['data'] as Map<String, dynamic>;

      if (dataMap['application']
      is Map<String, dynamic>) {
        return dataMap['application'];
      }

      return dataMap;
    }

    return current;
  }

  List<dynamic>? _extractApplicationList(
      dynamic data,
      ) {
    if (data is List) {
      return data;
    }

    if (data is! Map<String, dynamic>) {
      return null;
    }

    if (data['applications'] is List) {
      return data['applications'];
    }

    if (data['data'] is List) {
      return data['data'];
    }

    if (data['data'] is Map<String, dynamic>) {
      final dataMap =
      data['data'] as Map<String, dynamic>;

      if (dataMap['applications'] is List) {
        return dataMap['applications'];
      }

      if (dataMap['data'] is List) {
        return dataMap['data'];
      }
    }

    return null;
  }

  // =========================================================
  // ERROR LOGGER
  // =========================================================

  void _printDioError(
      String title,
      DioException e,
      ) {
    print('');
    print('========================================');
    print('❌ $title');
    print('========================================');
    print('STATUS: ${e.response?.statusCode}');
    print('URL: ${e.requestOptions.uri}');
    print('METHOD: ${e.requestOptions.method}');
    print('REQUEST DATA: ${e.requestOptions.data}');
    print('RESPONSE: ${e.response?.data}');
    print('MESSAGE: ${e.message}');
    print('========================================');
  }
}