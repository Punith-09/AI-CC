import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/auth/presentation/providers/auth_provider.dart';
import 'package:aicc/features/otp_auth/data/otp_auth_repository.dart';
import 'package:aicc/features/auth/presentation/pages/signup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final int initialSeconds;
  final bool isLinkMode;

  const OtpScreen({
    super.key,
    required this.phone,
    this.initialSeconds = 60,
    this.isLinkMode = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _repo = sl<OtpAuthRepository>();
  final _pin = TextEditingController();
  final _pinFocusNode = FocusNode();
  Timer? _timer;
  int _left = 0;
  bool _busy = false;
  String? _error;
  bool _agreedToTerms = false;

  /// Masked phone shown as "+91 xxxxx xxxxx"
  String get _masked {
    final p = widget.phone;
    if (p.length == 10) {
      return '+91 ${p.substring(0, 5)} ${p.substring(5)}';
    }
    return '+91 $p';
  }

  @override
  void initState() {
    super.initState();
    _startTimer(widget.initialSeconds);
  }

  void _startTimer(int s) {
    _timer?.cancel();
    setState(() => _left = s);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      if (mounted) setState(() => _left = _left > 0 ? _left - 1 : 0);
    });
  }

  Future<void> _verify(String otp) async {
    if (_busy || otp.length != 6) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (widget.isLinkMode) {
        // Authenticated link/verify flow
        await _repo.verifyLinkOtp(widget.phone, otp);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Phone number linked successfully!',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        return;
      }

      // Normal OTP login flow
      final r = await _repo.verifyOtp(widget.phone, otp);
      if (!mounted) return;

      if (r.needsSignup) {
        // ── Phone NOT registered: show alert, then go to signup ──
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Number Not Registered',
              style: GoogleFonts.sora(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'This mobile number is not linked to any account.\n\nYou\'ll be taken to the sign-up page to create a new account.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.sora(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (!mounted) return;
        // Navigate to full registration screen (Image 2)
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => SignupScreen(initialMobile: widget.phone),
        ));
      } else {
        // ── Phone exists: sync session and go home ───────────────
        final userId = LocalStorage.instance.getUserId();
        if (mounted) {
          context.read<AuthProvider>().syncAfterOtpLogin(userId);
          context.go(AppRoutes.home);
        }
      }
    } on OtpApiException catch (e) {
      setState(() => _error = e.message);
      _pin.clear();
      _pinFocusNode.requestFocus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_left > 0 || _busy) return;
    setState(() => _error = null);
    try {
      final int s;
      if (widget.isLinkMode) {
        s = await _repo.sendLinkOtp(widget.phone);
      } else {
        s = await _repo.resendOtp(widget.phone);
      }
      _pin.clear();
      _startTimer(s);
    } on OtpApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Underline-style pin theme (matches mockup) ────────────────
    final basePinTheme = PinTheme(
      width: 52,
      height: 52,
      textStyle: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white54, width: 2),
        ),
      ),
    );

    final focusedPinTheme = basePinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2.5),
        ),
      ),
    );

    final errorPinTheme = basePinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // ── Logo ─────────────────────────────────────────
                Image.asset(
                  'assets/images/treekologo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => const SizedBox(height: 120),
                ),

                const SizedBox(height: 10),

                // ── Tagline ──────────────────────────────────────
                Text(
                  'ALL KINDS OF FILM INDUSTRY WORKS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 44),

                // ── Enter OTP heading ─────────────────────────────
                Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Sent-to line with Change link ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sent to $_masked  ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Change',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Pinput (4-box underline style) ────────────────
                Pinput(
                  length: 6,
                  controller: _pin,
                  focusNode: _pinFocusNode,
                  autofocus: true,
                  enabled: !_busy,
                  defaultPinTheme: basePinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  forceErrorState: _error != null,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  onCompleted: _verify,
                ),

                const SizedBox(height: 20),

                // ── Error text ────────────────────────────────────
                if (_error != null) ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Resend OTP ────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _left == 0 && !_busy ? _resend : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _left == 0
                          ? 'Resend OTP'
                          : 'Resend OTP in ${_left}s',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Terms & Privacy checkbox ──────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: Colors.black,
                        side: const BorderSide(
                            color: Colors.white38, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white54,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Privacy Policy',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. Producers, Directors & Casting teams can see my number for casting only.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Verify & Continue Button ───────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _verify(_pin.text),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white30,
                      side: BorderSide(
                        color: _busy ? Colors.white24 : AppColors.primary,
                        width: 1.4,
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
                            'Verify & Continue',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
