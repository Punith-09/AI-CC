import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/live_stats_model.dart';

abstract class LiveStatsRemoteDataSource {
  Future<LiveStatsModel> getStats();
}

class LiveStatsRemoteDataSourceImpl implements LiveStatsRemoteDataSource {
  final DioClient _client;

  LiveStatsRemoteDataSourceImpl(this._client);

  @override
  Future<LiveStatsModel> getStats() async {
    final response = await _client.get(ApiEndpoints.liveStats);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LiveStatsModel.fromJson(data);
    }
    throw Exception('Unexpected response format for /stats');
  }
}
