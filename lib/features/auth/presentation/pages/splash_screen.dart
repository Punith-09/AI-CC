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
          context.go(AppRoutes.login);
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
    return Scaffold(
      backgroundColor: const Color(0xFF06151D),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [

            Image.asset(
              'assets/images/splash_background.png',
              fit: BoxFit.cover,
            ),

            // Slight dark overlay for better logo visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),

            // ============================================================
            // CONTENT
            // ============================================================

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ----------------------------------------------------
                    // AICC LOGO
                    // ----------------------------------------------------

                    Image.asset(
                      'assets/icons/aicc2.png',
                      width: MediaQuery.of(context).size.width * 0.68,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fade(
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    )
                        .scale(
                      begin: const Offset(0.55, 0.55),
                      end: const Offset(1, 1),
                      duration: 1200.ms,
                      curve: Curves.easeOutBack,
                    )
                        .then()
                        .shimmer(
                      duration: 1200.ms,
                      delay: 100.ms,
                      angle: 0.5,
                    ),

                    const SizedBox(height: 28),

                    // ----------------------------------------------------
                    // COMPANY NAME
                    // ----------------------------------------------------

                    const Text(
                      'ALL INDIA CASTING CONNECT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD9A936),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    )
                        .animate()
                        .fade(
                      delay: 1100.ms,
                      duration: 700.ms,
                    )
                        .slideY(
                      begin: 0.35,
                      end: 0,
                      delay: 1100.ms,
                      duration: 700.ms,
                      curve: Curves.easeOut,
                    ),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------
                    // TAGLINE
                    // ----------------------------------------------------

                    const Text(
                      'ACTORS  |  MODELS  |  ARTISTS  |  CREATORS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.7,
                      ),
                    )
                        .animate()
                        .fade(
                      delay: 1500.ms,
                      duration: 700.ms,
                    )
                        .slideY(
                      begin: 0.25,
                      end: 0,
                      delay: 1500.ms,
                      duration: 700.ms,
                      curve: Curves.easeOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}