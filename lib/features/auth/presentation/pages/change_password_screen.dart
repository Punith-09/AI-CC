import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================================================================
  // SUBMIT
  // ================================================================

  Future<void> _handleChangePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ---- Client-side validation ----
    if (oldPassword.isEmpty) {
      _showSnackBar('Please enter your current password.', isError: true);
      return;
    }
    if (newPassword.isEmpty) {
      _showSnackBar('Please enter a new password.', isError: true);
      return;
    }
    if (newPassword.length < 6) {
      _showSnackBar('New password must be at least 6 characters.', isError: true);
      return;
    }
    if (confirmPassword.isEmpty) {
      _showSnackBar('Please confirm your new password.', isError: true);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match.', isError: true);
      return;
    }
    if (oldPassword == newPassword) {
      _showSnackBar('New password must be different from the current password.', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmPassword,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Password changed successfully!', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        if (context.canPop()) context.pop();
      }
    } else {
      final err = authProvider.errorMessage ?? '';
      if (err == 'incorrect_old_password' ||
          err.toLowerCase().contains('current password is incorrect') ||
          err.toLowerCase().contains('old password') ||
          err.toLowerCase().contains('incorrect')) {
        _showOldPasswordAlert();
      } else if (err.toLowerCase().contains('confirmation does not match') ||
          err.toLowerCase().contains('do not match')) {
        _showSnackBar('New password confirmation does not match.', isError: true);
      } else {
        _showSnackBar(err.isNotEmpty ? err : 'Failed to change password. Please try again.', isError: true);
      }
    }
  }

  // ================================================================
  // ALERT: Wrong old password
  // ================================================================

  void _showOldPasswordAlert() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primary, width: 0.8),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.redAccent,
            size: 26,
          ),
        ),
        title: Text(
          'Incorrect Password',
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
        ),
        content: Text(
          'The current password you entered is incorrect.\nPlease enter it correctly and try again.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Clear old password field so user can re-enter
              _oldPasswordController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SNACK BAR
  // ================================================================

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.black : const Color(0xFFF4F4F4);
    final titleColor = isDark ? Colors.white : AppColors.lightText;
    final authProvider = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: titleColor,
              size: 20,
            ),
            onPressed: () {
              if (context.canPop()) context.pop();
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
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 32),

                              // ----------------------------------------
                              // LOCK ICON
                              // ----------------------------------------
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              )
                                  .animate()
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    duration: 500.ms,
                                    curve: Curves.easeOutBack,
                                  )
                                  .fadeIn(),

                              const SizedBox(height: 20),

                              // ----------------------------------------
                              // TITLE
                              // ----------------------------------------
                              Text(
                                'Change Password',
                                style: GoogleFonts.sora(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                ),
                              ).animate(delay: 100.ms).fade(duration: 500.ms).slideY(begin: 0.15, end: 0),

                              const SizedBox(height: 8),

                              Text(
                                'Enter your current password and a new one below.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                                ),
                              ).animate(delay: 150.ms).fade(duration: 500.ms),

                              const SizedBox(height: 40),

                              // ----------------------------------------
                              // OLD PASSWORD
                              // ----------------------------------------
                              _buildPasswordField(
                                controller: _oldPasswordController,
                                hintText: 'Current Password',
                                isVisible: _oldPasswordVisible,
                                onToggle: () => setState(
                                  () => _oldPasswordVisible = !_oldPasswordVisible,
                                ),
                                isDark: isDark,
                                textInputAction: TextInputAction.next,
                                animationDelay: 200.ms,
                              ),

                              const SizedBox(height: 16),

                              // ----------------------------------------
                              // NEW PASSWORD
                              // ----------------------------------------
                              _buildPasswordField(
                                controller: _newPasswordController,
                                hintText: 'New Password',
                                isVisible: _newPasswordVisible,
                                onToggle: () => setState(
                                  () => _newPasswordVisible = !_newPasswordVisible,
                                ),
                                isDark: isDark,
                                textInputAction: TextInputAction.next,
                                animationDelay: 300.ms,
                              ),

                              const SizedBox(height: 16),

                              // ----------------------------------------
                              // CONFIRM NEW PASSWORD
                              // ----------------------------------------
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm Password',
                                isVisible: _confirmPasswordVisible,
                                onToggle: () => setState(
                                  () => _confirmPasswordVisible = !_confirmPasswordVisible,
                                ),
                                isDark: isDark,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleChangePassword(),
                                animationDelay: 400.ms,
                              ),

                              const Spacer(),
                              const SizedBox(height: 40),

                              // ----------------------------------------
                              // CHANGE PASSWORD BUTTON
                              // ----------------------------------------
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Change Password',
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ).animate(delay: 500.ms).fade(duration: 600.ms).slideY(begin: 0.1, end: 0),

                              const SizedBox(height: 32),
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

  // ================================================================
  // PASSWORD FIELD BUILDER
  // ================================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
    required bool isDark,
    required TextInputAction textInputAction,
    required Duration animationDelay,
    void Function(String)? onSubmitted,
  }) {
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final hintColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return TextField(
      controller: controller,
      obscureText: !isVisible,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: hintColor,
            size: 19,
          ),
          splashRadius: 20,
          onPressed: onToggle,
        ),
      ),
    ).animate(delay: animationDelay).fade(duration: 500.ms);
  }
}
