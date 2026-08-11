import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SizedBox(
        width: double.infinity,
        child: AppBackground(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const SizedBox(height: 1),
                Column(
                  children: [

                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: const Icon(
                        LucideIcons.clapperboard,
                        size: 65,
                        color: AppColors.black,
                      ),
                    ).animate()
                        .fade(duration: 1500.ms)
                        .scale(
                      begin: const Offset(.8, .8),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 20),


                     Text(
                      "AICC",
                      style: GoogleFonts.alfaSlabOne(
                        fontSize: 53,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 3
                      ),
                    )
                        .animate(delay: 250.ms)
                        .fade(duration: 1000.ms)
                        .slideY(begin: .4, end: 0),

                    const SizedBox(height: 2),


                    const Text(
                      "AI-MATCHED AUDITIONS",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                    ).animate(delay: 450.ms)
                        .fade(duration: 1000.ms)
                        .slideY(begin: .3, end: 0),

                    const SizedBox(height: 10),


                     Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Connecting India's top talent with visionary casting directors.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.whiteShade,
                          fontSize: 17,
                        ),
                      ).animate(delay: 650.ms)
                          .fade(duration: 1000.ms)
                          .moveY(begin: 15, end: 0),
                    ),
                  ],
                ),


                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 42),
                  child: Column(
                    children: [

                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            context.push(AppRoutes.login);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ) .animate(delay: 1000.ms)
                            .fade()
                            .slideY(begin: .6, end: 0),
                      ),

                      const SizedBox(height: 18),


                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B1F2A),
                            side: const BorderSide(
                                color: AppColors.grey
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            context.go(AppRoutes.signup);
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate(delay: 1050.ms)
                            .fade()
                            .slideY(begin: .6, end: 0)
                      ),

                      const SizedBox(height: 20),


                      const Text(
                        "By continuing, you agree to AICC's Terms of Service and Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.whiteShade,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}
