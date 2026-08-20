import 'package:aicc/common/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/social_buttons.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: AppBackground(child:SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome ',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.white,
                              fontSize: 37,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: 'Back!',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFB16CFF),
                              fontSize: 37,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fade(duration: 1000.ms)
                        .slideY(
                      begin: -0.5,
                      end: 0,
                    ),

                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Log in to continue your journey with\nAICC AI-Matched Auditions",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.whiteShade,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fade(duration: 1000.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),


              Align(
                alignment: AlignmentGeometry.directional(0.2,0.3 ),
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 80),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30, 35, 30, 35),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "EMAIL OR HCC ID",
                          style: TextStyle(
                            color: AppColors.whiteShade,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: "name@example.com",
                            hintStyle: const TextStyle(color: AppColors.whiteShade),
                            prefixIcon:
                            const Icon(Icons.email, color: AppColors.whiteShade),
                            filled: true,
                            fillColor: const Color(0xFF2A2A3D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),


                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PASSWORD",
                              style: TextStyle(
                                color:AppColors.whiteShade,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColors.whiteShade,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: AppColors.whiteShade),
                            prefixIcon:
                            const Icon(Icons.lock, color: AppColors.whiteShade),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.whiteShade,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2A3D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.authBtnGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: const Color(0xFFB66AF5),
                                width: 0.6,
                              ),
                              boxShadow: [
                                const BoxShadow(
                                  color:  Color(0x889B3FE4),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(9),
                                onTap: authProvider.isLoading
                                    ? null
                                    : () async {
                                        final email = _emailController.text;
                                        final password = _passwordController.text;
                                        if (email.isEmpty || password.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please enter email and password.'),
                                            ),
                                          );
                                          return;
                                        }
                                        final success = await context.read<AuthProvider>().login(email, password);
                                        if (success) {
                                          if (context.mounted) {
                                            context.go(AppRoutes.home);
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(context.read<AuthProvider>().errorMessage ?? 'Login failed'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: authProvider.isLoading
                                        ? [
                                            const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          ]
                                        : [
                                            const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// OR CONTINUE WITH
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// SOCIAL BUTTONS

                        SocialButtons(
                          onGoogleTap: () {
                            // Google login
                          },
                          onAppleTap: () {
                            // Apple login
                          },
                          onFacebookTap: () {
                            // Facebook login
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              Align(
                alignment: AlignmentGeometry.directional(0,0.9 ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      children: [
                        const TextSpan(
                          text: "Don't have an account yet? ",
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              context.go(AppRoutes.signup);
                            },
                            child: const Text(
                              "Sign Up Now",
                              style: TextStyle(
                                color: AppColors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ),

      ),
    );
  }

  Widget _socialBtn(IconData icon) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.white),
      ),
      child: Icon(icon, color: AppColors.white),
    );
  }
}
