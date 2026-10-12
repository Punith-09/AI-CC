import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import '../widgets/steps/profile_form_data.dart';
import '../widgets/steps/step1.dart';
import '../widgets/steps/step2.dart';
import '../widgets/steps/step3.dart';
import '../widgets/steps/step4.dart';
import '../widgets/steps/step5.dart';
import '../widgets/steps/step_ready.dart';

/// Parent screen controlling the 5-step profile completion workflow.
class CompleteProfileScreen extends StatefulWidget {
  final int initialStep;

  const CompleteProfileScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late int _currentStep;
  late final ProfileFormData _formData;
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 4);
    final provider = context.read<ProfileProvider>();
    final initialProfile = provider.currentProfile;
    _formData = ProfileFormData(initialProfile: initialProfile);
    if (provider.completion == null) {
      provider.fetchProfileCompletion();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _formData.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _nextStep() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<ProfileProvider>();
    final payload = _formData.toMapUpToStep(_currentStep);

    try {
      if (payload.isNotEmpty) {
        await provider.updateProfile(payload);
      }
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (_currentStep < 4) {
          _currentStep++;
        }
      });
      _scrollToTop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception:', '').trim(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    } else {
      _popOrGoBack();
    }
  }

  void _jumpToStep(int step) {
    if (step >= 0 && step <= 4) {
      setState(() {
        _currentStep = step;
      });
      _scrollToTop();
    }
  }

  void _popOrGoBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.artistProfile);
    }
  }

  Future<void> _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<ProfileProvider>();
    final payload = _formData.toMap();

    try {
      await provider.updateProfile(payload);
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _currentStep = 5; // Step 5 is celebration/ready view
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception:', '').trim(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return Step1BasicInfo(
          data: _formData,
          onNext: _nextStep,
          isSubmitting: _isSubmitting,
        );
      case 1:
        return Step2ProfessionalProfile(
          data: _formData,
          onNext: _nextStep,
          onPrevious: _previousStep,
          isSubmitting: _isSubmitting,
        );
      case 2:
        return Step3PersonalPhysical(
          data: _formData,
          onNext: _nextStep,
          onPrevious: _previousStep,
          isSubmitting: _isSubmitting,
        );
      case 3:
        return Step4PortfolioExperience(
          data: _formData,
          onNext: _nextStep,
          onPrevious: _previousStep,
          isSubmitting: _isSubmitting,
        );
      case 4:
        return Step5ReviewComplete(
          data: _formData,
          onGenerateProfile: _submitProfile,
          onPrevious: _previousStep,
          onJumpToStep: _jumpToStep,
          isSubmitting: _isSubmitting,
        );
      case 5:
        return StepReadyView(
          onFinished: _popOrGoBack,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor =
        isDark ? Colors.white60 : const Color(0xFF6B7280);
    final isCelebration = _currentStep == 5;

    final profileProvider = context.watch<ProfileProvider>();
    final int completionPercent = profileProvider.completion?.percentage ?? 0;
    final int displayPercent = isCelebration
        ? 100
        : (completionPercent > 0
            ? completionPercent
            : (_currentStep * 20));
    final double progressValue = isCelebration
        ? 1.0
        : (completionPercent > 0
            ? (completionPercent / 100.0).clamp(0.05, 1.0)
            : (_currentStep * 0.2).clamp(0.05, 1.0));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: textColor,
            size: 24,
          ),
          tooltip: 'Cancel',
          onPressed: _popOrGoBack,
        ),
        title: null,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Progress Section ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      isCelebration
                          ? 'Completed Your Profile'
                          : 'Complete Your Profile',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$displayPercent% Complete',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFDC8B20)),
                        minHeight: 5,
                      ),
                    ),
                    if (!isCelebration) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Step ${_currentStep + 1} of 5',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Step Content ────────────────────────────────────────
              Expanded(
                child: isCelebration
                    ? _buildStepBody()
                    : SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildStepBody(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
