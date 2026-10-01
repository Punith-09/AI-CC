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

  const ForgotPasswordScreen({super.key, this.token});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSuccess = false; // To show the success UI

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final authProvider = context.read<AuthProvider>();
    
    if (widget.token == null) {
      // Step 1: Request Reset Link
      final identifier = _identifierController.text.trim();
      if (identifier.isEmpty) {
        _showSnackBar('Please enter your email, phone, or TRK ID.', true);
        return;
      }
      
      final success = await authProvider.forgotPassword(identifier);
      if (success) {
        _showSnackBar('A password reset link has been sent. Please check your inbox.', false);
      } else {
        _showSnackBar(authProvider.errorMessage ?? 'Failed to send reset link.', true);
      }
    } else {
      // Step 2: Reset Database Password
      final newPassword = _passwordController.text;
      if (newPassword.isEmpty) {
        _showSnackBar('Please enter a new password.', true);
        return;
      }
      
      final success = await authProvider.resetPassword(widget.token!, newPassword);
      if (success) {
        setState(() {
          _isSuccess = true;
        });
      } else {
        _showSnackBar(authProvider.errorMessage ?? 'Failed to reset password.', true);
      }
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // For styling consistent with Login screen
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
                          child: _isSuccess ? _buildSuccessView() : _buildFormView(authProvider),
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
    bool hasToken = widget.token != null && widget.token!.isNotEmpty;

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

        const SizedBox(height: 48),

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

        const SizedBox(height: 36),

        // ----------------------------------------------------
        // IDENTIFIER INPUT
        // ----------------------------------------------------
        TextField(
          controller: _identifierController,
          enabled: !hasToken, // Disable if using token
          keyboardType: TextInputType.text,
          textInputAction: hasToken ? TextInputAction.next : TextInputAction.done,
          onSubmitted: hasToken ? null : (_) => _handleSubmit(),
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
              backgroundColor: AppColors.black
            ),
            filled: true,
            fillColor: !hasToken ? AppColors.black : AppColors.black.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: !hasToken ? AppColors.white : AppColors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: !hasToken ? AppColors.white : AppColors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColors.white.withValues(alpha: 0.3),
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
        // NEW PASSWORD INPUT
        // ----------------------------------------------------
        TextField(
          controller: _passwordController,
          enabled: hasToken, // Disable if not using token
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: hasToken ? (_) => _handleSubmit() : null,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          decoration: InputDecoration(
            hintText: 'New Password',
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.hint,
              backgroundColor: AppColors.black
            ),
            filled: true,
            fillColor: hasToken ? Colors.black : AppColors.black.withValues(alpha: 0.5),
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
              onPressed: hasToken ? () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              } : null,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: hasToken ? AppColors.white : AppColors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: hasToken ? AppColors.white : AppColors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColors.white.withValues(alpha: 0.3),
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

        const Spacer(),
        const SizedBox(height: 100),

        // ----------------------------------------------------
        // RESET BUTTON
        // ----------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: authProvider.isLoading ? null : _handleSubmit,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    'Reset Password',
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
        Spacer(),
        const Icon(
          Icons.verified, 
          color: AppColors.primary, 
          size: 64,
        ).animate().scale(delay: 200.ms, duration: 400.ms).fadeIn(),
        const SizedBox(height: 24),
        Text(
          'Password Reset Successful',
          style: GoogleFonts.inter(
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
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),
        Spacer(),
      ],
    );
  }
}
