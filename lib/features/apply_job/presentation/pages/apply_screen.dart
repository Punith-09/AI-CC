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

class ApplyScreen extends StatefulWidget {
  final AuditionModel? audition;
  final ApplicationModel? application;

  const ApplyScreen({
    super.key,
    this.audition,
    this.application,
  });

  bool get isEditMode =>
      application != null;

  @override
  State<ApplyScreen> createState() =>
      _ApplyScreenState();
}

class _ApplyScreenState
    extends State<ApplyScreen> {
  late final TextEditingController
  _coverLetterController;

  @override
  void initState() {
    super.initState();

    _coverLetterController =
        TextEditingController(
          text:
          widget.application?.coverLetter ??
              '',
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
      title: application != null &&
              application.auditionTitle.isNotEmpty
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
    if (widget.application != null &&
        widget.application!
            .auditionId
            .isNotEmpty) {
      return widget.application!.auditionId;
    }

    return widget.audition?.id ?? '';
  }

  // =========================================================
  // APPLICATION ID
  // =========================================================

  String get _applicationId {
    /*
    IMPORTANT:

    This MUST be:

        application.id

    NOT:

        audition.id
    */

    return widget.application?.id ?? '';
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<void> _submitApplication() async {
    final coverLetter =
    _coverLetterController.text.trim();

    if (_auditionId.isEmpty) {
      _showMessage(
        'Audition ID is missing.',
      );
      return;
    }

    if (coverLetter.length < 20) {
      _showMessage(
        'Cover letter must contain at least 20 characters.',
      );
      return;
    }

    final provider =
    context.read<ApplyJobProvider>();

    final success =
    await provider.submitApplication(
      auditionId: _auditionId,
      coverLetter: coverLetter,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      // Update local audition state immediately so the list/details
      // reflect the applied status without waiting for a server re-fetch.
      if (mounted) {
        context
            .read<AuditionsProvider>()
            .markAuditionApplied(_auditionId);
      }

      _showMessage(
        'Application submitted successfully.',
        isSuccess: true,
      );

      /*
      Return true so the previous screen
      knows that application state changed.
      */

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _showMessage(
        provider.errorMessage ??
            'Failed to submit application.',
      );
    }
  }


  // =========================================================
  // WITHDRAW
  // =========================================================

  Future<void> _withdrawApplication() async {
    if (_applicationId.isEmpty) {
      _showMessage(
        'Application ID is missing.',
      );
      return;
    }

    /*
    Show confirmation first.
    */

    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          AppColors.card,
          title: const Text(
            'Withdraw Application?',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your application will be withdrawn from this audition. The audition itself will not be deleted.',
            style: TextStyle(
              color:
              AppColors.greyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Withdraw',
                style: TextStyle(
                  color:
                  Colors.redAccent,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final provider =
    context.read<ApplyJobProvider>();

    final success =
    await provider.deleteApplication(
      applicationId: _applicationId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      // Immediately reflect withdrawal in the auditions list / details screen.
      if (mounted) {
        context
            .read<AuditionsProvider>()
            .markAuditionUnapplied(_auditionId);
      }

      _showMessage(
        'Application withdrawn successfully.',
        isSuccess: true,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 400,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _showMessage(
        provider.errorMessage ??
            'Failed to withdraw application.',
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

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isSuccess
            ? Colors.green
            : Colors.redAccent,
        duration:
        const Duration(seconds: 3),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: SafeArea(
        child: Consumer<ApplyJobProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Column(
              children: [
                // =================================================
                // APP BAR
                // =================================================

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    10,
                  ),
                  child: ApplyAppBar(
                    title:
                    widget.isEditMode
                        ? 'My Application'
                        : 'Submit Application',

                    /*
                    WITHDRAW BUTTON

                    This withdraws application.
                    It does NOT delete audition.
                    */

                    onDelete:
                    widget.isEditMode
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
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      30,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        // =========================================
                        // AUDITION INFO
                        // =========================================

                        AuditionInfoCard(
                          audition: _audition,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // =========================================
                        // NAME
                        // =========================================

                        Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) {
                            final profile = profileProvider.currentProfile;

                            // Resolve name: prefer profile, then application, then empty
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

                            return Column(
                              children: [
                                _buildReadOnlyField(
                                  title: 'Your Full Name',
                                  value: profileProvider.isLoading && profile == null
                                      ? 'Loading...'
                                      : displayName,
                                  icon: Icons.person_outline,
                                ),

                                const SizedBox(height: 25),

                                // =========================================
                                // CATEGORY
                                // =========================================

                                _buildReadOnlyField(
                                  title: 'Your Bio Category',
                                  value: profileProvider.isLoading && profile == null
                                      ? 'Loading...'
                                      : displayCategory,
                                  icon: Icons.person_outline,
                                ),
                              ],
                            );
                          },
                        ),

                        // =========================================
                        // COVER LETTER
                        // =========================================

                        CoverLetterField(
                          controller: _coverLetterController,
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // =========================================
                        // BUTTON
                        // =========================================

                        if (!widget.isEditMode)
                          SubmitButton(
                            onPressed:
                            _submitApplication,
                            isLoading:
                            provider.isLoading,
                            label:
                            'Submit Application',
                          ),

                        if (widget.isEditMode)
                          _buildViewOnlyHint(),
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
  // READ ONLY FIELD
  // =========================================================

  Widget _buildReadOnlyField({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(
                    colors: [
                      Color(0xff20D5FF),
                      Color(0xffCC3EFF),
                    ],
                  ).createShader(bounds),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                title,
                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration:
          BoxDecoration(
            color:
            AppColors.card,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color:
              AppColors.border,
            ),
          ),
          child: Text(
            value,
            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
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
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
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
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}