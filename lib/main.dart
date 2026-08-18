import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const MyApp());
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