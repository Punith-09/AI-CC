import 'package:aicc/features/explore/data/datasource/explore_remote_datasource.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';

abstract class ExploreRepository {
  Future<List<TalentModel>> getExploreUsers();
}

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TalentModel>> getExploreUsers() async {
    try {
      return await remoteDataSource.fetchExploreUsers();
    } catch (e) {
      rethrow;
    }
  }
}
