import 'package:get_it/get_it.dart';

import '../../features/auth/data/repository/auth_repository.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
// import '../../features/auth/domain/repositories/auth_repository.dart'; 
import '../../features/explore/data/datasource/explore_remote_datasource.dart';
import '../../features/explore/data/repository/explore_repository.dart';
import '../../features/artist_profile/data/datasource/profile_remote_datasource.dart';
import '../../features/artist_profile/data/repository/profile_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await LocalStorage.init();

  if (!sl.isRegistered<LocalStorage>()) {
    sl.registerLazySingleton<LocalStorage>(
          () => LocalStorage.instance,
    );
  }
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
          () => DioClient(),
    );
  }
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        sl<AuthRemoteDataSource>(),
        sl<LocalStorage>(),
      ),
    );
  }

  // Explore Feature
  if (!sl.isRegistered<ExploreRemoteDataSource>()) {
    sl.registerLazySingleton<ExploreRemoteDataSource>(
          () => ExploreRemoteDataSourceImpl(
        sl<DioClient>(),
        sl<LocalStorage>(),
      ),
    );
  }
  if (!sl.isRegistered<ExploreRepository>()) {
    sl.registerLazySingleton<ExploreRepository>(
          () => ExploreRepositoryImpl(
        sl<ExploreRemoteDataSource>(),
      ),
    );
  }

  // Profile Feature
  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
          () => ProfileRemoteDataSourceImpl(
        sl<DioClient>(),
        sl<LocalStorage>(),
      ),
    );
  }
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
          () => ProfileRepositoryImpl(
        sl<ProfileRemoteDataSource>(),
      ),
    );
  }
}