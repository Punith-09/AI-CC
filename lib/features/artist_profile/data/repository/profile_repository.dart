import 'package:aicc/features/artist_profile/data/datasource/profile_remote_datasource.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/data/models/profile_completion_model.dart';

abstract class ProfileRepository {
  Future<ArtistModel> getProfileMe();

  Future<ArtistModel> getUserProfile(String id);

  Future<List<PortfolioModel>> getUserMedia(String userId);

  Future<bool?> followUser(String id);

  Future<ArtistModel> updateProfile(Map<String, dynamic> data);

  Future<ProfileCompletionModel> getProfileCompletion();
  Future<bool> deletePost({required String id, required bool isVideo});
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
  Future<List<PortfolioModel>> getUserMedia(String userId) {
    return remoteDataSource.getUserMedia(userId);
  }

  @override
  Future<bool?> followUser(String id) {
    return remoteDataSource.followUser(id);
  }

  @override
  Future<ArtistModel> updateProfile(Map<String, dynamic> data) {
    return remoteDataSource.updateProfile(data);
  }

  @override
  Future<ProfileCompletionModel> getProfileCompletion() {
    return remoteDataSource.getProfileCompletion();
  }

  @override
  Future<bool> deletePost({required String id, required bool isVideo}) {
    return remoteDataSource.deletePost(id: id, isVideo: isVideo);
  }
}