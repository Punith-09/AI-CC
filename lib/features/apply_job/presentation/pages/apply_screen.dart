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

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _isEditing = !widget.isEditMode;

    _coverLetterController =
        TextEditingController(
          text:
          widget.application?.coverLetter ??
              '',
        );
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
  // UPDATE
  // =========================================================

  Future<void> _updateApplication() async {
    if (_applicationId.isEmpty) {
      _showMessage(
        'Application ID is missing.',
      );
      return;
    }

    final coverLetter =
    _coverLetterController.text.trim();

    if (coverLetter.length < 20) {
      _showMessage(
        'Cover letter must contain at least 20 characters.',
      );
      return;
    }

    final provider =
    context.read<ApplyJobProvider>();

    final success =
    await provider.updateApplicationCoverLetter(
      applicationId: _applicationId,
      coverLetter: coverLetter,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _isEditing = false;
      });

      _showMessage(
        'Application updated successfully.',
        isSuccess: true,
      );
    } else {
      _showMessage(
        provider.errorMessage ??
            'Failed to update application.',
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
  // EDIT
  // =========================================================

  void _startEditing() {
    if (_applicationId.isEmpty) {
      _showMessage(
        'Application ID is missing.',
      );
      return;
    }

    setState(() {
      _isEditing = true;
    });
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
                    EDIT BUTTON
                    */

                    onEdit:
                    widget.isEditMode
                        ? _startEditing
                        : null,

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

                        _buildReadOnlyField(
                          title:
                          'Your Full Name',
                          value:
                          widget.application
                              ?.applicantName
                              .isNotEmpty ==
                              true
                              ? widget
                              .application!
                              .applicantName
                              : 'Lokesh',
                          icon:
                          Icons.person_outline,
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // =========================================
                        // CATEGORY
                        // =========================================

                        _buildReadOnlyField(
                          title:
                          'Your Bio Category',
                          value:
                          widget.application
                              ?.applicantCategory
                              .isNotEmpty ==
                              true
                              ? widget
                              .application!
                              .applicantCategory
                              : _audition
                              .category.isNotEmpty
                              ? _audition.category
                              : 'Film',
                          icon:
                          Icons.person_outline,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // =========================================
                        // COVER LETTER
                        // =========================================

                        AbsorbPointer(
                          absorbing:
                          widget.isEditMode &&
                              !_isEditing,
                          child:
                          CoverLetterField(
                            controller:
                            _coverLetterController,
                          ),
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

                        if (widget.isEditMode &&
                            _isEditing)
                          SubmitButton(
                            onPressed:
                            _updateApplication,
                            isLoading:
                            provider.isUpdating,
                            label:
                            'Update Application',
                          ),

                        if (widget.isEditMode &&
                            !_isEditing)
                          _buildEditingHint(),
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
  // EDITING HINT
  // =========================================================

  Widget _buildEditingHint() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(14),
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
              'Your application has been submitted. Tap the edit icon to modify your cover letter.',
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