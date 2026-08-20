import 'package:aicc/features/artist_profile/data/datasource/profile_remote_datasource.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';

abstract class ProfileRepository {
  Future<ArtistModel> getProfileMe();

  Future<ArtistModel> getUserProfile(String id);

  Future<void> followUser(String id);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ArtistModel> getProfileMe() {
    return remoteDataSource.getProfileMe();
  }

  @override
  Future<ArtistModel> getUserProfile(String id) {
    return remoteDataSource.getUserProfile(id);
  }

  @override
  Future<void> followUser(String id) {
    return remoteDataSource.followUser(id);
  }
}