import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/features/otp_auth/data/otp_auth_repository.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  /// When [isLinkMode] is true, the screen calls link/send instead of send,
  /// and OtpScreen calls link/verify (authenticated) instead of verify.
  final bool isLinkMode;

  const PhoneScreen({super.key, this.isLinkMode = false});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _repo = sl<OtpAuthRepository>();
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _valid => RegExp(r'^[6-9]\d{9}$').hasMatch(_controller.text);

  Future<void> _send() async {
    if (!_valid || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final int seconds;
      if (widget.isLinkMode) {
        seconds = await _repo.sendLinkOtp(_controller.text);
      } else {
        seconds = await _repo.sendOtp(_controller.text);
      }
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: _controller.text,
          initialSeconds: seconds,
          isLinkMode: widget.isLinkMode,
        ),
      ));
    } on OtpApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
        backgroundColor: Colors.black,
        // No AppBar – full-screen design matching the mockup
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

                // ── Welcome heading ──────────────────────────────
                Text(
                  'WELCOME BACK !',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter your mobile number to login or create an accounts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Mobile number field ───────────────────────────
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Mobile number',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                    prefixText: '+91  ',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    errorText: _error,
                    errorStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        width: 1.2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // ── Get OTP Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _valid && !_loading ? _send : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white30,
                      side: BorderSide(
                        color:
                            _valid ? AppColors.primary : Colors.white24,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
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
                            'Get OTP',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _valid
                                  ? AppColors.primary
                                  : Colors.white30,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
