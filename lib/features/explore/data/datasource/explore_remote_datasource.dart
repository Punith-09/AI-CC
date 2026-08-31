import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TalentModel>> fetchExploreUsers({
    String? query,
    String? category,
    String? location,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final DioClient _dioClient;

  ExploreRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TalentModel>> fetchExploreUsers({
    String? query,
    String? category,
    String? location,
  }) async {
    // Build query parameters matching the Swagger spec:
    // GET /users/explore?query=...&category=...&location=...
    final Map<String, dynamic> params = {};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (location != null && location.isNotEmpty) params['location'] = location;

    final response = await _dioClient.get(
      ApiEndpoints.exploreUsers,
      queryParameters: params.isEmpty ? null : params,
    );

    final rawData = response.data;

    // API returns a direct list: [ { id, name, category, pic, ... }, ... ]
    List<dynamic> list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final inner = rawData['data'] ??
          rawData['users'] ??
          rawData['results'] ??
          rawData['talents'] ??
          [];
      list = inner is List ? inner : [];
    } else {
      list = [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => TalentModel.fromJson(json))
        .toList();
  }
}
