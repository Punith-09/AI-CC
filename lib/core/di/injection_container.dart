import 'package:get_it/get_it.dart';

import '../../features/auth/data/repository/auth_repository.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/datasource/google_auth_datasource.dart';
// import '../../features/auth/domain/repositories/auth_repository.dart'; 
import '../../features/explore/data/datasource/explore_remote_datasource.dart';
import '../../features/explore/data/repository/explore_repository.dart';
import '../../features/artist_profile/data/datasource/profile_remote_datasource.dart';
import '../../features/artist_profile/data/repository/profile_repository.dart';
import '../../features/home/data/datasource/home_remote_datasource.dart';
import '../../features/home/data/repository/home_repository.dart';
import '../../features/apply_job/data/datasource/apply_job_remote_datasource.dart';
import '../../features/apply_job/data/repository/apply_job_repository.dart';
import '../../features/messages/data/datasource/messages_remote_datasource.dart';
import '../../features/messages/data/repository/messages_repository.dart';
import '../../features/subscription/data/datasource/subscription_remote_datasource.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/stories/data/datasource/stories_remote_datasource.dart';
import '../../features/stories/data/repository/stories_repository.dart';
import '../../features/artist_profile/presentation/providers/profile_provider.dart';
import '../../features/explore/presentation/providers/explore_provider.dart';
import '../../features/home/presentation/providers/home_feed_provider.dart';

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
  if (!sl.isRegistered<GoogleAuthDataSource>()) {
    sl.registerLazySingleton<GoogleAuthDataSource>(
          () => GoogleAuthDataSource(),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        sl<AuthRemoteDataSource>(),
        sl<GoogleAuthDataSource>(),
        sl<LocalStorage>(),
      ),
    );
  }

  // Explore Feature
  if (!sl.isRegistered<ExploreRemoteDataSource>()) {
    sl.registerLazySingleton<ExploreRemoteDataSource>(
          () => ExploreRemoteDataSourceImpl(
        sl<DioClient>(),
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

  // Home Feature
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        sl<HomeRemoteDataSource>(),
      ),
    );
  }

  // Apply Job Feature
  if (!sl.isRegistered<ApplyJobRemoteDataSource>()) {
    sl.registerLazySingleton<ApplyJobRemoteDataSource>(
          () => ApplyJobRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<ApplyJobRepository>()) {
    sl.registerLazySingleton<ApplyJobRepository>(
          () => ApplyJobRepositoryImpl(
        sl<ApplyJobRemoteDataSource>(),
      ),
    );
  }

  // Messages Feature
  if (!sl.isRegistered<MessagesRemoteDataSource>()) {
    sl.registerLazySingleton<MessagesRemoteDataSource>(
          () => MessagesRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<MessagesRepository>()) {
    sl.registerLazySingleton<MessagesRepository>(
          () => MessagesRepositoryImpl(
        sl<MessagesRemoteDataSource>(),
      ),
    );
  }

  // Subscription Feature
  if (!sl.isRegistered<SubscriptionRemoteDataSource>()) {
    sl.registerLazySingleton<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSource(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<SubscriptionProvider>()) {
    sl.registerLazySingleton<SubscriptionProvider>(
      () => SubscriptionProvider(
        sl<SubscriptionRemoteDataSource>(),
      ),
    );
  }

  // Stories Feature
  if (!sl.isRegistered<StoriesRemoteDataSource>()) {
    sl.registerLazySingleton<StoriesRemoteDataSource>(
      () => StoriesRemoteDataSourceImpl(
        sl<DioClient>(),
      ),
    );
  }
  if (!sl.isRegistered<StoriesRepository>()) {
    sl.registerLazySingleton<StoriesRepository>(
      () => StoriesRepositoryImpl(
        sl<StoriesRemoteDataSource>(),
      ),
    );
  }

  // Cross-feature shared Providers
  if (!sl.isRegistered<ProfileProvider>()) {
    sl.registerLazySingleton<ProfileProvider>(
      () => ProfileProvider(
        sl<ProfileRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<ExploreProvider>()) {
    sl.registerLazySingleton<ExploreProvider>(
      () => ExploreProvider(
        sl<ExploreRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<HomeFeedProvider>()) {
    sl.registerLazySingleton<HomeFeedProvider>(
      () => HomeFeedProvider(
        sl<HomeRepository>(),
      ),
    );
  }
}