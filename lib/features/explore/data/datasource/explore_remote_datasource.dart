import 'package:dio/dio.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:aicc/core/storage/local_storage.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TalentModel>> fetchExploreUsers();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  ExploreRemoteDataSourceImpl(this._dioClient, this._localStorage);

  @override
  Future<List<TalentModel>> fetchExploreUsers() async {
    try {
      final token = _localStorage.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _dioClient.get(
        ApiEndpoints.exploreUsers,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final rawData = response.data;

        // Handle various API response shapes:
        // 1. Direct list:          [{ ... }, { ... }]
        // 2. Wrapped in 'data':    { "data": [ ... ] }
        // 3. Wrapped in 'users':   { "users": [ ... ] }
        // 4. Wrapped in 'results': { "results": [ ... ] }
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
      } else {
        throw Exception('Failed to fetch explore users');
      }
    } catch (e) {
      throw Exception('Error fetching explore users: $e');
    }
  }
}
