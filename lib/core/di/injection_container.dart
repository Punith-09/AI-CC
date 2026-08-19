import 'package:get_it/get_it.dart';

import '../../features/auth/data/repository/auth_repository.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
//import '../../features/auth/domain/repositories/auth_repository.dart';

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
}