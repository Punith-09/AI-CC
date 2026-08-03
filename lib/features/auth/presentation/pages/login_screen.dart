import 'signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Stack(
            children: [
              /// 🔝 Top Text
              Align(
                child: Column(
                  children: const [
                    SizedBox(height: 100),
                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 37,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                
                    SizedBox(height: 5),
                
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Log in to continue your journey with\nAICC AI-Matched Auditions",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 100),
                  child: Container(
                    height: 480,
                    padding: const EdgeInsets.fromLTRB(30, 45, 30, 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(30), // full rounded
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// EMAIL
                        const Text(
                          "EMAIL OR HCC ID",
                          style: TextStyle(color: Colors.white70, fontSize: 15,fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "name@example.com",
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.email, color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF2A2A3D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "PASSWORD",
                              style: TextStyle(color: Colors.white70, fontSize: 15,fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white70, fontSize: 14,fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          obscureText: !isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white54,
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
                              context.go('/home');

                            },
                            child: const Text(
                              "Log In to Dashboard →",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,letterSpacing: 1,color: Colors.black54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// OR CONTINUE WITH
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(color: Colors.white54, fontSize: 14),
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
              /// Bottom Text (Outside Container)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpWizardPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up Now",
                              style: TextStyle(
                                color: Color(0xFFE91E63),
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
        ),
      ),
    );
  }

  /// 🔘 Social Button
  Widget _socialBtn(IconData icon) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
