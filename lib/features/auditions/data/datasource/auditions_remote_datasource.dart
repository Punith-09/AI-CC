import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/audition_model.dart';
import '../models/create_audition_request.dart';

abstract class AuditionsRemoteDataSource {
  Future<List<AuditionModel>> getAuditions({String? category});
  Future<AuditionModel> getAuditionById(String id);
  Future<AuditionModel> createAudition(CreateAuditionRequest request);
}

class AuditionsRemoteDataSourceImpl implements AuditionsRemoteDataSource {
  final DioClient _dioClient;

  AuditionsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<AuditionModel>> getAuditions({String? category}) async {
    final queryParameters = <String, dynamic>{};
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParameters['category'] = category;
    }

    final response = await _dioClient.get(
      ApiEndpoints.auditions,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.data is List) {
      final list = response.data as List;
      return list.map((item) => AuditionModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Invalid server response format for auditions');
    }
  }

  @override
  Future<AuditionModel> getAuditionById(String id) async {
    final response = await _dioClient.get(
      ApiEndpoints.auditionDetail(id),
    );

    if (response.data is Map<String, dynamic>) {
      return AuditionModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid server response format for audition details');
    }
  }

  @override
  Future<AuditionModel> createAudition(CreateAuditionRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.auditions,
      data: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return AuditionModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid server response format for create audition');
    }
  }
}
