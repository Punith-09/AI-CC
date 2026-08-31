import '../datasource/auditions_remote_datasource.dart';
import '../models/audition_model.dart';
import '../models/create_audition_request.dart';

abstract class AuditionsRepository {
  Future<List<AuditionModel>> getAuditions({String? category});
  Future<List<AuditionModel>> getMyPostedAuditions();
  Future<AuditionModel> getAuditionById(String id);
  Future<AuditionModel> createAudition(CreateAuditionRequest request);
}

class AuditionsRepositoryImpl implements AuditionsRepository {
  final AuditionsRemoteDataSource _remoteDataSource;

  AuditionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AuditionModel>> getAuditions({String? category}) async {
    return await _remoteDataSource.getAuditions(category: category);
  }

  @override
  Future<List<AuditionModel>> getMyPostedAuditions() async {
    return await _remoteDataSource.getMyPostedAuditions();
  }

  @override
  Future<AuditionModel> getAuditionById(String id) async {
    return await _remoteDataSource.getAuditionById(id);
  }

  @override
  Future<AuditionModel> createAudition(CreateAuditionRequest request) async {
    return await _remoteDataSource.createAudition(request);
  }
}
