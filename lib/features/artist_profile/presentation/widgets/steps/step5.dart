import 'package:flutter/material.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'profile_form_data.dart';
import 'step_common_widgets.dart';

class Step5ReviewComplete extends StatefulWidget {
  final ProfileFormData data;
  final VoidCallback onGenerateProfile;
  final VoidCallback onPrevious;
  final void Function(int step) onJumpToStep;
  final bool isSubmitting;

  const Step5ReviewComplete({
    super.key,
    required this.data,
    required this.onGenerateProfile,
    required this.onPrevious,
    required this.onJumpToStep,
    required this.isSubmitting,
  });

  @override
  State<Step5ReviewComplete> createState() => _Step5ReviewCompleteState();
}

class _Step5ReviewCompleteState extends State<Step5ReviewComplete> {
  void _submit() {
    if (!widget.data.agreeTerms || !widget.data.agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please accept both the Terms & Conditions and Privacy Policy.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    widget.onGenerateProfile();
  }

  Widget _buildReviewCard({
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final borderColor =
        isDark ? Colors.white24 : const Color(0xFFD1D5DB);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF9FAFB),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepSectionHeader(
          title: 'Review & Complete',
        ),

        const StepFieldLabel(
          title: 'Review all Entered Information',
          topPadding: 8,
        ),
        const SizedBox(height: 6),

        _buildReviewCard(
          title: 'Basic Information',
          onTap: () => widget.onJumpToStep(0),
        ),
        _buildReviewCard(
          title: 'Professional Profile',
          onTap: () => widget.onJumpToStep(1),
        ),
        _buildReviewCard(
          title: 'Persona & Physical Details',
          onTap: () => widget.onJumpToStep(2),
        ),
        _buildReviewCard(
          title: 'Portfolio and Experience',
          onTap: () => widget.onJumpToStep(3),
        ),

        const StepFieldLabel(
          title: 'Accept Terms & Conditions',
          topPadding: 20,
        ),
        const SizedBox(height: 4),

        StepCheckboxItem(
          title: 'I agree to the Terms & Conditions',
          isSelected: widget.data.agreeTerms,
          onTap: () =>
              setState(() => widget.data.agreeTerms = !widget.data.agreeTerms),
        ),
        StepCheckboxItem(
          title: 'I agree to the Privacy Policy',
          isSelected: widget.data.agreePrivacy,
          onTap: () => setState(
              () => widget.data.agreePrivacy = !widget.data.agreePrivacy),
        ),

        const SizedBox(height: 32),

        // Generate Profile button (Orange pill button matching screenshot)
        Center(
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC8B20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: widget.isSubmitting ? null : _submit,
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Generate Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: TextButton(
            onPressed: widget.onPrevious,
            child: Text(
              'Back to Previous Step',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
