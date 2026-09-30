// import 'dart:async';
//
// import 'package:aicc/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_animate/flutter_animate.dart';
//
// import '../../../../core/routes/app_routes.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//
//     Timer(const Duration(milliseconds: 3500), () {
//       if (mounted) {
//         context.go(AppRoutes.welcome);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF123B4A),
//       // backgroundColor: const Color(0xFFFFFFFF),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             // LOGO
//             Image.asset(
//               'assets/icons/aicc2.png',
//               width: 280,
//             )
//                 .animate()
//                 .fade(
//               duration: 1000.ms,
//             )
//                 .scale(
//               begin: const Offset(0.5, 0.5),
//               end: const Offset(1, 1),
//               duration: 1200.ms,
//               curve: Curves.easeOutBack,
//             )
//                 .then()
//                 .shimmer(
//               duration: 1200.ms,
//               color: Colors.white,
//             ),
//
//             const SizedBox(height: 25),
//
//             // TAGLINE
//             const Text(
//               'ALL INDIA CASTING CONNECT',
//               style: TextStyle(
//                 color: Color(0xFFD9A936),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 2.5,
//               ),
//             )
//                 .animate()
//                 .fade(
//               delay: 900.ms,
//               duration: 700.ms,
//             )
//                 .slideY(
//               begin: 0.3,
//               end: 0,
//               duration: 700.ms,
//             ),
//
//             const SizedBox(height: 10),
//
//             const Text(
//               'ACTORS  |  MODELS  |  ARTISTS  |  CREATORS',
//               style: TextStyle(
//                 color: Colors.white60,
//                 fontSize: 10,
//                 letterSpacing: 1.5,
//               ),
//             )
//                 .animate()
//                 .fade(
//               delay: 1300.ms,
//               duration: 700.ms,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _navigationTimer = Timer(
      const Duration(milliseconds: 3800),
          () {
        if (mounted) {
          context.go(AppRoutes.welcome);
        }
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoWidth = screenWidth > 600 ? 280.0 : (screenWidth * 0.65).clamp(200.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ----------------------------------------------------
                    // AICC LOGO
                    // ----------------------------------------------------
                    Image.asset(
                      'assets/icons/aicc2.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fade(
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        )
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 1100.ms,
                          curve: Curves.easeOutBack,
                        )
                        .then()
                        .shimmer(
                          duration: 1200.ms,
                          delay: 100.ms,
                          angle: 0.5,
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                        ),

                    const SizedBox(height: 28),

                    // ----------------------------------------------------
                    // COMPANY NAME
                    // ----------------------------------------------------
                    const Text(
                      'ALL INDIA CASTING CONNECT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    )
                        .animate()
                        .fade(
                          delay: 800.ms,
                          duration: 700.ms,
                        )
                        .slideY(
                          begin: 0.35,
                          end: 0,
                          delay: 800.ms,
                          duration: 700.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 10),

                    // ----------------------------------------------------
                    // TAGLINE
                    // ----------------------------------------------------
                    const Text(
                      'ACTORS  |  MODELS  |  ARTISTS  |  CREATORS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    )
                        .animate()
                        .fade(
                          delay: 1100.ms,
                          duration: 700.ms,
                        )
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          delay: 1100.ms,
                          duration: 700.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}