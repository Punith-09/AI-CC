import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  // ================================================================
  // HANDLE DELETE
  // ================================================================

  Future<void> _handleDeleteAccount() async {
    // Show a final confirmation dialog before actually deleting
    final confirmed = await _showFinalConfirmDialog();
    if (confirmed != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    final success = await authProvider.deleteAccount();

    if (!mounted) return;

    if (success) {
      // Account deleted — navigate to login and clear the stack
      router.go(AppRoutes.login);
    } else {
      final err = authProvider.errorMessage ?? 'Failed to delete account. Please try again.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              err,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }

  // ================================================================
  // FINAL CONFIRMATION DIALOG
  // ================================================================

  Future<bool?> _showFinalConfirmDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 28,
          ),
        ),
        title: Text(
          'Are you sure?',
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. Your account and all associated data will be permanently removed.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : AppColors.lightText,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Yes, Delete',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
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
    final bodyColor = isDark ? Colors.white70 : AppColors.lightTextSecondary;
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 36),

                              // ----------------------------------------
                              // WARNING TRIANGLE ICON
                              // ----------------------------------------
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 36,
                                ),
                              )
                                  .animate()
                                  .scale(
                                    begin: const Offset(0.7, 0.7),
                                    duration: 500.ms,
                                    curve: Curves.easeOutBack,
                                  )
                                  .fadeIn(),

                              const SizedBox(height: 24),

                              // ----------------------------------------
                              // TITLE
                              // ----------------------------------------
                              Text(
                                'Delete Account',
                                style: GoogleFonts.sora(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                ),
                              ).animate(delay: 100.ms).fade(duration: 500.ms).slideY(begin: 0.15, end: 0),

                              const SizedBox(height: 16),

                              // ----------------------------------------
                              // WARNING MESSAGE
                              // ----------------------------------------
                              Text(
                                'Deleting your account is permanent. You will lose access to your profile, auditions, messages, and saved data. This action cannot be undone.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: bodyColor,
                                  height: 1.65,
                                ),
                              ).animate(delay: 150.ms).fade(duration: 500.ms),

                              const SizedBox(height: 20),

                              // ----------------------------------------
                              // SIGN OUT HINT
                              // ----------------------------------------
                              GestureDetector(
                                onTap: () {
                                  if (context.canPop()) context.pop();
                                },
                                child: Text(
                                  'If you only want to sign out, use Sign Out instead.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ).animate(delay: 200.ms).fade(duration: 500.ms),

                              const Spacer(),
                              const SizedBox(height: 40),

                              // ----------------------------------------
                              // DELETE MY ACCOUNT BUTTON
                              // ----------------------------------------
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleDeleteAccount,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    disabledBackgroundColor:
                                        Colors.redAccent.withValues(alpha: 0.6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                          'Delete My Account',
                                          style: GoogleFonts.sora(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ).animate(delay: 300.ms).fade(duration: 600.ms).slideY(begin: 0.1, end: 0),

                              const SizedBox(height: 16),

                              // ----------------------------------------
                              // CANCEL LINK
                              // ----------------------------------------
                              GestureDetector(
                                onTap: () {
                                  if (context.canPop()) context.pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                              ).animate(delay: 400.ms).fade(duration: 500.ms),

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
}
