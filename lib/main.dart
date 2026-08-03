import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AICC',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // home: const HomeScreen(),
      routerConfig: appRouter,
    );
  }
}
