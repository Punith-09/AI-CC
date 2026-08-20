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
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TalentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch explore users');
      }
    } catch (e) {
      throw Exception('Error fetching explore users: $e');
    }
  }
}
