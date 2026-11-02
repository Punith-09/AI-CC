import 'package:aicc/features/explore/data/datasource/explore_remote_datasource.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';

abstract class ExploreRepository {
  Future<List<TalentModel>> getExploreUsers({
    String? query,
    String? category,
    String? location,
    String? role,
    String? gender,
    int? limit,
  });

  Future<TalentModel> getUserPublicProfile(String id);
}

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TalentModel>> getExploreUsers({
    String? query,
    String? category,
    String? location,
    String? role,
    String? gender,
    int? limit,
  }) async {
    return await remoteDataSource.fetchExploreUsers(
      query: query,
      category: category,
      location: location,
      role: role,
      gender: gender,
      limit: limit,
    );
  }

  @override
  Future<TalentModel> getUserPublicProfile(String id) {
    return remoteDataSource.fetchUserPublicProfile(id);
  }
}
