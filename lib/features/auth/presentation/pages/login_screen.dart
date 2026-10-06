import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;



  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter both email / phone / TRK ID and password.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final success = await context.read<AuthProvider>().login(identifier, password);
    if (success) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } else {
      if (mounted) {
        final errorMsg = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg ?? 'Invalid email / phone / TRK ID or password.',
              style: const TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),

                              // ----------------------------------------------------
                              // LOGO (TREE EMBLEM + TREEKO BRAND + TAGLINE)
                              // ----------------------------------------------------
                              Image.asset(
                                'assets/images/treekologo.png',
                                width: 126,
                                height: 117,
                                fit: BoxFit.contain,
                              )
                                  .animate()
                                  .fade(duration: 600.ms)
                                  .scale(
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1, 1),
                                    duration: 600.ms,
                                    curve: Curves.easeOutBack,
                                  ),

                              // const SizedBox(height: 6),

                              Image.asset(
                                'assets/images/TreeKo.png',
                                width: 191,
                                height: 63,
                                fit: BoxFit.contain,
                              )
                                  .animate(delay: 150.ms)
                                  .fade(duration: 600.ms),

                              const SizedBox(height: 10),

                              Text(
                                'ALL KINDS OF FILM INDUSTRY WORKS',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                  color: AppColors.text,
                                ),
                              )
                                  .animate(delay: 250.ms)
                                  .fade(duration: 600.ms),

                              const SizedBox(height: 48),

                              // ----------------------------------------------------
                              // TITLE: WELCOME BACK !
                              // ----------------------------------------------------
                              Text(
                                'WELCOME BACK !',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  letterSpacing: 0,
                                  height: 1.0,
                                ),
                              )
                                  .animate(delay: 350.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(begin: 0.15, end: 0),

                              const SizedBox(height: 36),

                              // ----------------------------------------------------
                              // EMAIL / PHONE / TRK ID INPUT
                              // ----------------------------------------------------
                              TextField(
                                controller: _identifierController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:AppColors.white,

                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email / Phone Number / TRK ID',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hint,
                                    backgroundColor: AppColors.black

                                  ),
                                  filled: true,
                                  fillColor: AppColors.black,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.white,
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.white,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(delay: 450.ms)
                                  .fade(duration: 600.ms),

                              const SizedBox(height: 16),

                              // ----------------------------------------------------
                              // PASSWORD INPUT
                              // ----------------------------------------------------
                              TextField(

                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleLogin(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hint,
                                    backgroundColor: AppColors.black
                                  ),
                                  filled: true,
                                  fillColor: Colors.black,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 14,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF94A3B8),
                                      size: 18,
                                    ),
                                    splashRadius: 18,
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.white,
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.white,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(delay: 550.ms)
                                  .fade(duration: 600.ms),

                              const SizedBox(height: 16),

                              // ----------------------------------------------------
                              // FORGOT PASSWORD?
                              // ----------------------------------------------------
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(AppRoutes.forgotPassword);
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFD39A4A),
                                        letterSpacing: 0,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .animate(delay: 600.ms)
                                  .fade(duration: 600.ms),

                              // Push Login button towards bottom
                              const Spacer(),
                              const SizedBox(height: 100),

                              // ----------------------------------------------------
                              // LOGIN BUTTON
                              // ----------------------------------------------------
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.black,
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                ),
                              )
                                  .animate(delay: 700.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(begin: 0.1, end: 0),

                              const SizedBox(height: 14),

                              // ----------------------------------------------------
                              // SIGN UP LINK
                              // ----------------------------------------------------
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.signup),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hint.withValues(alpha: 0.75),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign Up',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  .animate(delay: 750.ms)
                                  .fade(duration: 600.ms),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
