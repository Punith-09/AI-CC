import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  final dioClient = DioClient();
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, LocalStorage.instance);

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
          create: (_) => AuthProvider(authRepository),
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "AICC",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}