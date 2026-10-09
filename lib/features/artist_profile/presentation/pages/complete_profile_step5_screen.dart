import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';

class CompleteProfileStep5Screen extends StatefulWidget {
  const CompleteProfileStep5Screen({super.key});

  @override
  State<CompleteProfileStep5Screen> createState() =>
      _CompleteProfileStep5ScreenState();
}

class _CompleteProfileStep5ScreenState
    extends State<CompleteProfileStep5Screen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _imdController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _agreeToTerms = false;
  bool _willAllowContact = true;

  @override
  void dispose() {
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    _imdController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions to continue.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final provider = context.read<ProfileProvider>();

    final data = <String, dynamic>{
      'instagram': _instagramController.text.trim(),
      'youtube': _youtubeController.text.trim(),
      'facebook': _facebookController.text.trim(),
      'twitter': _twitterController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'imdbLink': _imdController.text.trim(),
      'website': _websiteController.text.trim(),
      'bio': _bioController.text.trim(),
      'allowContact': _willAllowContact,
      'profileComplete': true,
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC8B20), Color(0xFFF1D3B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Complete!',
                style: TextStyle(
                  color: AppColors.getText(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your profile has been successfully set up. You can now start exploring auditions and opportunities!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Navigate to artist profile and clear the stack
                    context.go(AppRoutes.artistProfile);
                  },
                  child: const Text(
                    'Go to My Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title, {bool isMandatory = false}) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 10.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (isMandatory)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
  }) {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      keyboardType: keyboardType ?? TextInputType.url,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 48, minHeight: 48),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color:
                AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: iconColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBioField() {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: _bioController,
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText:
            'Tell casting directors about yourself, your experience, and what makes you unique...',
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterStyle: TextStyle(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final textColor = AppColors.getText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────
                        Center(
                          child: Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            '80% Complete',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.8,
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Step 5 of 5',
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'Social Links & Bio',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Add your social media profiles to increase your visibility to casting directors.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        // ── Social Media Links ───────────────────────────
                        _buildLabel('Social Media Profiles'),
                        _buildSocialField(
                          controller: _instagramController,
                          hint: 'Instagram profile URL',
                          icon: Icons.camera_alt_rounded,
                          iconColor: const Color(0xFFE1306C),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialField(
                          controller: _youtubeController,
                          hint: 'YouTube channel URL',
                          icon: Icons.play_circle_rounded,
                          iconColor: const Color(0xFFFF0000),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialField(
                          controller: _facebookController,
                          hint: 'Facebook profile URL',
                          icon: Icons.facebook_rounded,
                          iconColor: const Color(0xFF1877F2),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialField(
                          controller: _twitterController,
                          hint: 'Twitter / X profile URL',
                          icon: Icons.alternate_email_rounded,
                          iconColor: const Color(0xFF1DA1F2),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialField(
                          controller: _linkedinController,
                          hint: 'LinkedIn profile URL',
                          icon: Icons.work_rounded,
                          iconColor: const Color(0xFF0A66C2),
                        ),

                        // ── Professional Links ───────────────────────────
                        _buildLabel('Professional Links'),
                        _buildSocialField(
                          controller: _imdController,
                          hint: 'IMDb profile URL',
                          icon: Icons.movie_creation_rounded,
                          iconColor: const Color(0xFFF5C518),
                        ),
                        const SizedBox(height: 12),
                        _buildSocialField(
                          controller: _websiteController,
                          hint: 'Personal website URL',
                          icon: Icons.language_rounded,
                          iconColor: AppColors.primary,
                        ),

                        // ── Bio ──────────────────────────────────────────
                        _buildLabel('About Me / Bio', isMandatory: false),
                        _buildBioField(),

                        // ── Preferences ──────────────────────────────────
                        _buildLabel('Contact Preferences'),
                        _buildToggleRow(
                          title: 'Allow casting directors to contact me',
                          subtitle:
                              'Directors can send you direct messages about roles',
                          value: _willAllowContact,
                          onChanged: (v) =>
                              setState(() => _willAllowContact = v),
                        ),

                        // ── Terms ────────────────────────────────────────
                        const SizedBox(height: 24),
                        _buildTermsCheckbox(),

                        const SizedBox(height: 36),

                        // ── Navigation Buttons ────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1D3B5),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => context.pop(),
                                child: const Text(
                                  'Previous',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _completeProfile,
                                child: const Text(
                                  'Complete',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final textColor = AppColors.getText(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    final textColor = AppColors.getText(context);
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _agreeToTerms
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                width: 2,
              ),
              color: _agreeToTerms ? AppColors.primary : Colors.transparent,
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(color: textColor, fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(color: textColor, fontSize: 13),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' of AI Casting Call.',
                    style: TextStyle(color: textColor, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
