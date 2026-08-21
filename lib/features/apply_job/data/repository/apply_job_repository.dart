import '../datasource/apply_job_remote_datasource.dart';
import '../models/application_model.dart';

abstract class ApplyJobRepository {
  Future<ApplicationModel> applyForAudition(
      String auditionId, {
        required String coverLetter,
      });

  Future<List<ApplicationModel>> getMyApplications();

  Future<void> withdrawApplication(
      String applicationId,
      );

  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      );
}

class ApplyJobRepositoryImpl
    implements ApplyJobRepository {
  final ApplyJobRemoteDataSource _remoteDataSource;

  ApplyJobRepositoryImpl(
      this._remoteDataSource,
      );

  @override
  Future<ApplicationModel> applyForAudition(
      String auditionId, {
        required String coverLetter,
      }) {
    return _remoteDataSource.applyForAudition(
      auditionId,
      coverLetter: coverLetter,
    );
  }

  @override
  Future<List<ApplicationModel>>
  getMyApplications() {
    return _remoteDataSource.getMyApplications();
  }

  @override
  Future<void> withdrawApplication(
      String applicationId,
      ) {
    return _remoteDataSource.withdrawApplication(
      applicationId,
    );
  }

  @override
  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      ) {
    return _remoteDataSource
        .updateApplicationStatus(
      applicationId,
      status,
    );
  }
}