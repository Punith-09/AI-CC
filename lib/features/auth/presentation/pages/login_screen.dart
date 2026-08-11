import 'package:aicc/common/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

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

                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      // style: TextStyle(
                      //   color: Colors.white,
                      //   fontSize: 37,
                      //   fontWeight: FontWeight.w900,
                      //   letterSpacing: 1.1,
                      // ),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.white,
                          fontSize: 37,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                      ),
                    )
                        .animate()
                        .fade(duration: 1000.ms)
                        .slideY(begin: -0.5, end: 0),

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

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              context.go(AppRoutes.home);
                            },
                            child: const Text(
                              "Log In to Dashboard →",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1,
                                color:AppColors.purple,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialBtn(Icons.public),
                            _socialBtn(Icons.apple),
                            _socialBtn(Icons.facebook),
                          ],
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
