import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/explore/data/repository/explore_repository.dart';
import 'features/explore/presentation/providers/explore_provider.dart';
import 'features/artist_profile/data/repository/profile_repository.dart';
import 'features/artist_profile/presentation/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await initDependencies();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(sl<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(sl<ExploreRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(sl<ProfileRepository>()),
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