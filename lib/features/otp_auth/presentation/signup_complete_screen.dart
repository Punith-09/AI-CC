import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/auth/presentation/providers/auth_provider.dart';
import 'package:aicc/features/otp_auth/data/otp_auth_repository.dart';

class SignupCompleteScreen extends StatefulWidget {
  final String signupToken;

  const SignupCompleteScreen({super.key, required this.signupToken});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  final _repo = sl<OtpAuthRepository>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  bool get _valid =>
      RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(_username.text.trim());

  Future<void> _submit() async {
    final username = _username.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Please enter a username');
      return;
    }
    if (!_valid) {
      setState(() => _error =
          'Username must be 3-30 characters (letters, numbers, _, .)');
      return;
    }
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.otpSignup(
        signupToken: widget.signupToken,
        username: username,
        email: _email.text.trim(),
        fullName: _name.text.trim(),
      );
      if (!mounted) return;
      final userId = LocalStorage.instance.getUserId();
      context.read<AuthProvider>().syncAfterOtpLogin(userId);
      context.go(AppRoutes.home);
    } on OtpApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.phoneLogin);
              }
            },
          ),
          title: Text(
            'Complete your profile',
            style: GoogleFonts.sora(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Almost there!',
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    'Pick a username to complete sign-up.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.hint,
                    ),
                  ).animate(delay: 100.ms).fade(duration: 400.ms),

                  const SizedBox(height: 28),

                  _buildField(_username, 'Username *', delay: 200),
                  const SizedBox(height: 16),
                  _buildField(_name, 'Full name (optional)', delay: 300),
                  const SizedBox(height: 16),
                  _buildField(
                    _email,
                    'Email (optional)',
                    delay: 400,
                    keyboard: TextInputType.emailAddress,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.danger),
                    ).animate().shake(hz: 3),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _submit,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        side: BorderSide(
                          color: _valid ? AppColors.primary : const Color(0xFF3E4347),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            )
                          : Text(
                              'Create account',
                              style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint, {
    int delay = 0,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      onChanged: (_) => setState(() => _error = null),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.hint),
        filled: true,
        fillColor: AppColors.black,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppColors.hint, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppColors.hint, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fade(duration: 500.ms);
  }
}

