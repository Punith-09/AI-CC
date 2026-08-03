import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F5A6A),
            Color(0xFF123B4A),
            Color(0xFF0B1F2A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Top Section
            const SizedBox( height:1),
            Column(
              children: [

                /// Icon Circle
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(45)
                  ),
                  child: const Icon(
                    Icons.movie_creation_outlined,
                    size: 65,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                const Text(
                  "AICC",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 53,
                      fontWeight: FontWeight.w900,
                      letterSpacing:-3
                  ),
                ),

                const SizedBox(height: 2),

                /// Subtitle
                const Text(
                  "AI-MATCHED AUDITIONS",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900
                  ),
                ),

                const SizedBox(height: 10),

                /// Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Connecting India's top talent with visionary casting directors.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),

            /// Bottom Section
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 42),
              child: Column(
                children: [

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFF0B1F2A),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        context.go("/signup");
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Terms Text
                  const Text(
                    "By continuing, you agree to AICC's Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
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
    );
  }
}
