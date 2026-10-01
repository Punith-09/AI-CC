import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

import '../../data/models/application_model.dart';
import '../providers/apply_job_provider.dart';

import '../widgets/apply_appbar.dart';
import '../widgets/audition_info_card.dart';
import '../widgets/cover_letter_field.dart';
import '../widgets/submit_button.dart';

import '../../../auditions/data/models/audition_model.dart';
import '../../../auditions/presentation/providers/auditions_provider.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/limit_upgrade_dialog.dart';

class ApplyScreen extends StatefulWidget {
  final AuditionModel? audition;
  final ApplicationModel? application;

  const ApplyScreen({
    super.key,
    this.audition,
    this.application,
  });

  bool get isEditMode => application != null;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  late final TextEditingController _coverLetterController;
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();

    _coverLetterController = TextEditingController(
      text: widget.application?.coverLetter ?? '',
    );
    _nameController = TextEditingController(
      text: widget.application?.applicantName ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.application?.applicantCategory ?? '',
    );

    // Fetch logged-in user profile if not yet loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.currentProfile == null && !profileProvider.isLoading) {
        profileProvider.fetchMyProfile();
      }
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // =========================================================
  // AUDITION
  // =========================================================

  AuditionModel get _audition {
    final nested = widget.application?.audition;
    if (nested != null) {
      return nested;
    }

    if (widget.audition != null) {
      return widget.audition!;
    }

    final application = widget.application;

    return AuditionModel(
      id: application?.auditionId ?? '',
      title: application != null && application.auditionTitle.isNotEmpty
          ? application.auditionTitle
          : 'Audition',
      category: application?.applicantCategory ?? '',
      role: application?.role ?? '',
      language: '',
      pay: '',
      location: '',
      deadline: application?.deadline ?? '',
      description: application?.details ?? '',
    );
  }

  // =========================================================
  // AUDITION ID
  // =========================================================

  String get _auditionId {
    if (widget.application != null && widget.application!.auditionId.isNotEmpty) {
      return widget.application!.auditionId;
    }

    return widget.audition?.id ?? '';
  }

  // =========================================================
  // APPLICATION ID
  // =========================================================

  String get _applicationId {
    return widget.application?.id ?? '';
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<void> _submitApplication() async {
    final coverLetter = _coverLetterController.text.trim();

    if (_auditionId.isEmpty) {
      _showMessage('Audition ID is missing.');
      return;
    }

    if (coverLetter.length < 20) {
      _showMessage('Cover letter must contain at least 20 characters.');
      return;
    }

    final subProvider = context.read<SubscriptionProvider>();
    if (!subProvider.canApplyAudition) {
      LimitUpgradeDialog.show(
        context,
        type: LimitType.auditionApplication,
      );
      return;
    }

    final provider = context.read<ApplyJobProvider>();

    final success = await provider.submitApplication(
      auditionId: _auditionId,
      coverLetter: coverLetter,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      // Decrement audition applications counter
      try {
        context.read<SubscriptionProvider>().recordAuditionApplied();
      } catch (_) {}

      // Update local audition state immediately so the list/details
      // reflect the applied status without waiting for a server re-fetch.
      if (mounted) {
        context.read<AuditionsProvider>().markAuditionApplied(_auditionId);
      }

      _showMessage(
        'Application submitted successfully.',
        isSuccess: true,
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      final err = (provider.errorMessage ?? '').toLowerCase();
      if (err.contains('limit') ||
          err.contains('quota') ||
          err.contains('upgrade') ||
          err.contains('plan') ||
          err.contains('reached')) {
        try {
          context.read<SubscriptionProvider>().markLimitReached(LimitType.auditionApplication);
        } catch (_) {}
        LimitUpgradeDialog.show(
          context,
          type: LimitType.auditionApplication,
          customMessage: provider.errorMessage,
        );
      } else {
        _showMessage(
          provider.errorMessage ?? 'Failed to submit application.',
        );
      }
    }
  }

  // =========================================================
  // WITHDRAW
  // =========================================================

  Future<void> _withdrawApplication() async {
    if (_applicationId.isEmpty) {
      _showMessage('Application ID is missing.');
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E22),
          title: const Text(
            'Withdraw Application?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your application will be withdrawn from this audition. The audition itself will not be deleted.',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Withdraw',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider = context.read<ApplyJobProvider>();

    final success = await provider.deleteApplication(
      applicationId: _applicationId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      if (mounted) {
        context.read<AuditionsProvider>().markAuditionUnapplied(_auditionId);
        try {
          context.read<SubscriptionProvider>().revertAuditionApplied();
        } catch (_) {}
      }

      _showMessage(
        'Application withdrawn successfully.',
        isSuccess: true,
      );

      await Future.delayed(
        const Duration(milliseconds: 400),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _showMessage(
        provider.errorMessage ?? 'Failed to withdraw application.',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(
    String message, {
    bool isSuccess = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<ApplyJobProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // =================================================
                // APP BAR
                // =================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: ApplyAppBar(
                    title: widget.isEditMode ? 'My Application' : 'Application',
                    onDelete: widget.isEditMode
                        ? provider.isDeleting
                            ? null
                            : _withdrawApplication
                        : null,
                  ),
                ),

                // =================================================
                // CONTENT
                // =================================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================================
                        // AUDITION INFO
                        // =========================================
                        AuditionInfoCard(
                          audition: _audition,
                        ),

                        const SizedBox(height: 16),

                        // =========================================
                        // NAME & CATEGORY FIELDS
                        // =========================================
                        Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) {
                            final profile = profileProvider.currentProfile;

                            // Resolve name: prefer profile, then application
                            final displayName = profile?.name.isNotEmpty == true
                                ? profile!.name
                                : (widget.application?.applicantName.isNotEmpty == true
                                    ? widget.application!.applicantName
                                    : '');

                            // Resolve category: prefer profile roles, then application, then audition
                            final displayCategory = profile?.roles.isNotEmpty == true
                                ? profile!.roles.join(', ')
                                : (widget.application?.applicantCategory.isNotEmpty == true
                                    ? widget.application!.applicantCategory
                                    : (_audition.category.isNotEmpty
                                        ? _audition.category
                                        : ''));

                            if (_nameController.text.isEmpty && displayName.isNotEmpty) {
                              _nameController.text = displayName;
                            }
                            if (_categoryController.text.isEmpty && displayCategory.isNotEmpty) {
                              _categoryController.text = displayCategory;
                            }

                            return Column(
                              children: [
                                _buildInputField(
                                  controller: _nameController,
                                  hintText: 'Your Full Name',
                                ),
                                const SizedBox(height: 14),
                                _buildInputField(
                                  controller: _categoryController,
                                  hintText: 'Your Bio Category',
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // =========================================
                        // COVER LETTER / MESSAGE
                        // =========================================
                        CoverLetterField(
                          controller: _coverLetterController,
                        ),

                        const SizedBox(height: 24),

                        // =========================================
                        // APPLY NOW BUTTON
                        // =========================================
                        if (!widget.isEditMode)
                          SubmitButton(
                            onPressed: _submitApplication,
                            isLoading: provider.isLoading,
                            label: 'Apply Now',
                          ),

                        if (widget.isEditMode) _buildViewOnlyHint(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // INPUT FIELD (FIGMA OUTLINED STYLE)
  // =========================================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // VIEW-ONLY HINT
  // =========================================================

  Widget _buildViewOnlyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your application has been submitted successfully.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}