import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../providers/auditions_provider.dart';
import '../../data/models/audition_model.dart';

class BottomActionBar extends StatefulWidget {
  final AuditionModel? audition;
  final VoidCallback? onApply;

  const BottomActionBar({
    super.key,
    this.audition,
    this.onApply,
  });

  @override
  State<BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  bool _isSubmitting = false;

  Future<void> _applyDirectly() async {
    final audition = widget.audition;
    if (audition == null || audition.id.isEmpty) return;

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final applyProvider = context.read<ApplyJobProvider>();

    final success = await applyProvider.submitApplication(
      auditionId: audition.id,
      coverLetter: ' ',
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      context.read<AuditionsProvider>().markAuditionApplied(audition.id);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
    } else {
      final err = applyProvider.errorMessage ?? 'Failed to submit application.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch ApplyJobProvider so the button reacts immediately after apply/withdraw
    final applyProvider = context.watch<ApplyJobProvider>();
    final hasApplied = (widget.audition?.applied ?? false) ||
        (widget.audition != null &&
            applyProvider.getApplicationForAudition(widget.audition!.id) != null);

    const primaryColor = Color(0xFFDC8B20);
    const appliedColor = Color(0xFF27AE60);

    final bool isLoading = _isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (hasApplied || isLoading)
            ? null
            : () {
                // TODO: Re-enable subscription canApplyAudition check when ready
                // final subProvider = context.read<SubscriptionProvider>();
                // if (!subProvider.canApplyAudition) {
                //   LimitUpgradeDialog.show(
                //     context,
                //     type: LimitType.auditionApplication,
                //   );
                //   return;
                // }
                if (widget.onApply != null) {
                  widget.onApply!();
                } else {
                  _applyDirectly();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: hasApplied ? appliedColor : primaryColor,
          disabledBackgroundColor: hasApplied ? appliedColor : primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasApplied) ...[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    hasApplied ? "Applied" : "Apply Now",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}