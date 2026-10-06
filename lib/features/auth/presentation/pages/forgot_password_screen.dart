import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? token;
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.token, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _identifierController;
  late final TextEditingController _otpController;
  late final TextEditingController _passwordController;

  bool _isPasswordVisible = false;
  bool _isSuccess = false;
  bool _isOtpSent = false;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(text: widget.initialEmail ?? '');
    _otpController = TextEditingController(text: widget.token ?? '');
    _passwordController = TextEditingController();

    if (widget.token != null && widget.token!.isNotEmpty) {
      _isOtpSent = true;
    }

    _otpController.addListener(_onOtpChanged);
  }

  void _onOtpChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _identifierController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Step 1: Check database and send OTP / link
  Future<void> _handleSendOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      _showSnackBar('Please enter your Email / Phone Number / TRK ID.', true);
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(identifier);

    if (!mounted) return;

    setState(() {
      _isSendingOtp = false;
    });

    if (success) {
      setState(() {
        _isOtpSent = true;
      });
      _showSnackBar(
        'A password reset OTP / link has been sent to your email. Please check your inbox.',
        false,
      );
    } else {
      final errorMsg = authProvider.errorMessage ??
          'Email ID not found in database. Please check your email or sign up.';
      _showAlertDialog(
        title: 'Account Not Found',
        message: errorMsg,
      );
    }
  }

  // Step 2: Verify OTP and reset password in database
  Future<void> _handleResetPassword() async {
    final identifier = _identifierController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text;

    if (identifier.isEmpty) {
      _showSnackBar('Please enter your Email / Phone Number / TRK ID.', true);
      return;
    }

    if (otp.isEmpty) {
      _showSnackBar('Please enter the OTP sent to your email.', true);
      return;
    }

    if (newPassword.isEmpty) {
      _showSnackBar('Please enter a new password.', true);
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters long.', true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      otp,
      newPassword,
      email: identifier,
      otp: otp,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSuccess = true;
      });
    } else {
      _showSnackBar(
        authProvider.errorMessage ??
            'Failed to reset password. OTP might be invalid or expired.',
        true,
      );
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? AppColors.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAlertDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 0.8),
        ),
        title: Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.login);
              }
            },
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppBar().preferredSize.height,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 0,
                        ),
                        child: IntrinsicHeight(
                          child: _isSuccess
                              ? _buildSuccessView()
                              : _buildFormView(authProvider),
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

  Widget _buildFormView(AuthProvider authProvider) {
    final isOtpEntered = _otpController.text.trim().isNotEmpty;
    final isNewPasswordEnabled = isOtpEntered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ----------------------------------------------------
        // LOGO
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

        const SizedBox(height: 40),

        // ----------------------------------------------------
        // TITLE: Forgot Password
        // ----------------------------------------------------
        Text(
          'Forgot Password',
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

        const SizedBox(height: 32),

        // ----------------------------------------------------
        // 1. IDENTIFIER INPUT (Email / Phone / TRK ID)
        // ----------------------------------------------------
        TextField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Email / Phone Number / TRK ID',
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.hint,
            ),
            filled: true,
            fillColor: AppColors.black,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            suffixIcon: _isSendingOtp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: authProvider.isLoading || _isSendingOtp
                        ? null
                        : _handleSendOtp,
                    child: Text(
                      _isOtpSent ? 'Resend' : 'Send OTP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
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
        // 2. OTP INPUT
        // ----------------------------------------------------
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          decoration: InputDecoration(
            hintText: 'OTP',
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.hint,
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
            .animate(delay: 500.ms)
            .fade(duration: 600.ms),

        const SizedBox(height: 16),

        // ----------------------------------------------------
        // 3. NEW PASSWORD INPUT (Disabled until OTP is entered)
        // ----------------------------------------------------
        GestureDetector(
          onTap: () {
            if (!isNewPasswordEnabled) {
              if (!_isOtpSent) {
                _showSnackBar('Please enter your email and click "Send OTP" first.', true);
              } else {
                _showSnackBar('Please enter the OTP sent to your email to unlock password field.', true);
              }
            }
          },
          child: AbsorbPointer(
            absorbing: !isNewPasswordEnabled,
            child: TextField(
              controller: _passwordController,
              enabled: isNewPasswordEnabled,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => isOtpEntered ? _handleResetPassword() : _handleSendOtp(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isNewPasswordEnabled ? AppColors.white : AppColors.hint,
              ),
              decoration: InputDecoration(
                hintText: isNewPasswordEnabled ? 'New Password' : 'New Password (enter OTP first)',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isNewPasswordEnabled ? AppColors.hint : AppColors.hint.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: isNewPasswordEnabled ? AppColors.black : AppColors.black.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isNewPasswordEnabled
                        ? const Color(0xFF94A3B8)
                        : AppColors.hint.withValues(alpha: 0.3),
                    size: 18,
                  ),
                  splashRadius: 18,
                  onPressed: isNewPasswordEnabled
                      ? () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        }
                      : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isNewPasswordEnabled
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isNewPasswordEnabled
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.white.withValues(alpha: 0.2),
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
            ),
          ),
        )
            .animate(delay: 550.ms)
            .fade(duration: 600.ms),

        const Spacer(),
        const SizedBox(height: 60),

        // ----------------------------------------------------
        // RESET PASSWORD / SEND OTP BUTTON
        // ----------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: authProvider.isLoading || _isSendingOtp
                ? null
                : () {
                    if (isOtpEntered) {
                      _handleResetPassword();
                    } else {
                      _handleSendOtp();
                    }
                  },
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
            child: authProvider.isLoading || _isSendingOtp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    isOtpEntered ? 'Reset Password' : 'Send OTP',
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

        const SizedBox(height: 24),
      ],
    );
  }

  // View shown after successfully resetting password
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: AppColors.primary,
            size: 56,
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
        const SizedBox(height: 24),
        Text(
          'Password Reset Successful',
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            context.go(AppRoutes.login);
          },
          child: Text.rich(
            TextSpan(
              text: 'Click to ',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.hint,
              ),
              children: [
                TextSpan(
                  text: 'login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),
        const Spacer(),
      ],
    );
  }
}
