import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return
       Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.12),

                        // The Tree Logo
                        SizedBox(
                          width: 126.99,
                          height: 117.01,
                          child: Image.asset(
                            'assets/icons/aicc3.png',
                            fit: BoxFit.contain,
                          ).animate().fade(
                            duration: 800.ms,
                          ).scale(
                            begin: const Offset(0.9, 0.9),
                            duration: 800.ms,
                            curve: Curves.easeOut,
                          ),
                        ),

                        const SizedBox(height:1),

                        // The TREEK golden text logo
                        SizedBox(
                          width: 191,
                          height: 63.81,
                          child: Image.asset(
                            'assets/icons/text.png',
                            fit: BoxFit.contain,
                          ).animate().fade(duration: 800.ms).scale(
                                begin: const Offset(0.9, 0.9),
                                duration: 800.ms,
                                curve: Curves.easeOut,
                              ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'ALL KINDS OF FILM INDUSTRY WORKS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: 200.ms).fade().slideY(begin: 0.2),

                        // This spacer will take only the remaining height (safely bounded by IntrinsicHeight)
                        const Spacer(),

                        Text(
                          'WELCOME !',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate(delay: 400.ms).fade().slideY(begin: 0.2),

                        const SizedBox(height: 35),

                        // Login Button
                        _buildButton(
                          context: context,
                          text: 'Login',
                          textColor: AppColors.black,
                          backgroundColor: AppColors.primary,
                          borderColor: AppColors.primary,
                          fontSize: 16,
                          onTap: () {
                            context.push(AppRoutes.login);
                          },
                        ).animate(delay: 500.ms).fade().slideY(begin: 0.2),

                        const SizedBox(height: 20),

                        // Sign Up Button
                        _buildButton(
                          context: context,
                          text: 'Sign Up',
                          textColor: AppColors.primary,
                          backgroundColor: AppColors.black,
                          borderColor: AppColors.primary,
                          fontSize: 16,
                          onTap: () {
                            context.push(AppRoutes.signup);
                          },
                        ).animate(delay: 600.ms).fade().slideY(begin: 0.2),

                        SizedBox(height: constraints.maxHeight * 0.08),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      // ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 345,
            ),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
