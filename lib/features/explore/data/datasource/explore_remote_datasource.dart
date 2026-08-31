import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TalentModel>> fetchExploreUsers({
    String? query,
    String? category,
    String? location,
  });

  Future<TalentModel> fetchUserPublicProfile(String id);
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

    // GET /users/explore may return a list or a wrapped { data/users/results }.
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

    return list.whereType<Map>().map((item) {
      final source = Map<String, dynamic>.from(item);
      final merged = <String, dynamic>{};
      final nested = source['user'] ?? source['artist'] ?? source['details'];
      if (nested is Map) {
        merged.addAll(Map<String, dynamic>.from(nested));
      }
      source.forEach((key, value) {
        if (key == 'user' || key == 'artist' || key == 'details') return;
        if (value == null) return;
        if (value is String && value.trim().isEmpty) return;
        merged[key] = value;
      });
      return TalentModel.fromJson(merged);
    }).toList();
  }

  @override
  Future<TalentModel> fetchUserPublicProfile(String id) async {
    final response = await _dioClient.get(ApiEndpoints.userProfile(id));
    final rawData = response.data;

    Map<String, dynamic> source;
    if (rawData is Map) {
      final wrapped = rawData['data'] ?? rawData['user'] ?? rawData['profile'];
      source = Map<String, dynamic>.from(
        wrapped is Map ? wrapped : rawData,
      );
    } else {
      source = {};
    }

    final merged = <String, dynamic>{};
    final details = source['details'];
    if (details is Map) {
      merged.addAll(Map<String, dynamic>.from(details));
    }
    source.forEach((key, value) {
      if (key == 'details') return;
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      merged[key] = value;
    });

    return TalentModel.fromJson(merged);
  }
}
