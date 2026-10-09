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
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSuccess = false;
  bool _isSendingRequest = false;

  bool get _isTokenPresent => widget.token != null && widget.token!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter your Email / Phone Number / TRK ID.', true);
      return;
    }

    setState(() {
      _isSendingRequest = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(email);

    if (!mounted) return;

    setState(() {
      _isSendingRequest = false;
    });

    if (success) {
      _showSnackBar(
        'If an account exists with this email address, a password reset link has been sent.',
        false,
      );
    } else {
      final errorMsg = authProvider.errorMessage ??
          'Failed to send reset link. Please try again.';
      _showAlertDialog(
        title: 'Notice',
        message: errorMsg,
      );
    }
  }

  Future<void> _handleUpdatePassword() async {
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all password fields.', true);
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters long.', true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Passwords do not match.', true);
      return;
    }

    setState(() {
      _isSendingRequest = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      widget.token!,
      newPassword,
      otp: widget.token,
    );

    if (!mounted) return;

    setState(() {
      _isSendingRequest = false;
    });

    if (success) {
      setState(() {
        _isSuccess = true;
      });
    } else {
      _showSnackBar(
        authProvider.errorMessage ??
            'Failed to reset password. The link might be invalid or expired.',
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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
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
        // TITLE: Forgot Password / Reset Password
        // ----------------------------------------------------
        Text(
          _isTokenPresent ? 'Reset Password' : 'Forgot Password',
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
        // INITIAL STEP: ENTER EMAIL
        // ----------------------------------------------------
        if (!_isTokenPresent) ...[
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSendResetLink(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Email / Phone Number / TRK ID',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.hint,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.hint,
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

          const SizedBox(height: 20),
          
          Text(
            'We will send a password reset link to your registered email address.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.text,
            ),
          ).animate(delay: 500.ms).fade(duration: 600.ms),
        ],

        // ----------------------------------------------------
        // SECOND STEP: ENTER NEW PASSWORD & CONFIRM
        // ----------------------------------------------------
        if (_isTokenPresent) ...[
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: 'New Password',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.black,
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
                  color: AppColors.hint,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.hint,
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
          ).animate(delay: 450.ms).fade(duration: 600.ms),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleUpdatePassword(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm New Password',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.black,
                  size: 18,
                ),
                splashRadius: 18,
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.hint,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.hint,
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
          ).animate(delay: 550.ms).fade(duration: 600.ms),
        ],

        const Spacer(),
        const SizedBox(height: 60),

        // ----------------------------------------------------
        // PRIMARY BUTTON
        // ----------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: authProvider.isLoading || _isSendingRequest
                ? null
                : () {
                    if (_isTokenPresent) {
                      _handleUpdatePassword();
                    } else {
                      _handleSendResetLink();
                    }
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.white,
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
            child: authProvider.isLoading || _isSendingRequest
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
                    _isTokenPresent ? 'Update Password' : 'Send Reset Link',
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
          'Your password has been reset successfully.',
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
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
