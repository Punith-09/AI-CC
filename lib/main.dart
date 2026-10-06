import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auditions/data/datasource/auditions_remote_datasource.dart';
import 'features/auditions/data/repository/auditions_repository.dart';
import 'features/auditions/presentation/providers/auditions_provider.dart';
import 'features/post/data/datasource/photos_remote_datasource.dart';
import 'features/post/data/repository/photos_repository.dart';
import 'features/post/presentation/providers/photos_provider.dart';
import 'features/post/data/datasource/videos_remote_datasource.dart';
import 'features/post/data/repository/videos_repository.dart';
import 'features/post/presentation/providers/videos_provider.dart';

import 'features/explore/presentation/providers/explore_provider.dart';
import 'features/artist_profile/presentation/providers/profile_provider.dart';
import 'features/home/presentation/providers/home_feed_provider.dart';
import 'features/apply_job/data/repository/apply_job_repository.dart';
import 'features/apply_job/presentation/providers/apply_job_provider.dart';
import 'features/messages/data/repository/messages_repository.dart';
import 'features/messages/presentation/providers/messages_provider.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/stories/data/repository/stories_repository.dart';
import 'features/stories/presentation/providers/stories_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorage.init();
  await initDependencies();


  final dioClient = sl<DioClient>();

  final auditionsRemoteDataSource = AuditionsRemoteDataSourceImpl(dioClient);
  final auditionsRepository = AuditionsRepositoryImpl(auditionsRemoteDataSource);

  final photosRemoteDataSource = PhotosRemoteDataSourceImpl(dioClient);
  final photosRepository = PhotosRepositoryImpl(photosRemoteDataSource);

  final videosRemoteDataSource = VideosRemoteDataSourceImpl(dioClient);
  final videosRepository = VideosRepositoryImpl(videosRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(sl<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ExploreProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<HomeFeedProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuditionsProvider(auditionsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PhotosProvider(photosRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => VideosProvider(videosRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplyJobProvider(sl<ApplyJobRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MessagesProvider(sl<MessagesRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = sl<SubscriptionProvider>();
            if (LocalStorage.instance.getToken() != null &&
                LocalStorage.instance.getToken()!.isNotEmpty) {
              provider.fetchSubscription(silent: true);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => StoriesProvider(sl<StoriesRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: "Treeko",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter,
    );
  }
}