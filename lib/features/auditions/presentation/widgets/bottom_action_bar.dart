import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../data/models/audition_model.dart';

class BottomActionBar extends StatelessWidget {
  final AuditionModel? audition;
  final VoidCallback? onApply;

  const BottomActionBar({
    super.key,
    this.audition,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    // Watch ApplyJobProvider so the button reacts immediately after apply/withdraw
    final applyProvider = context.watch<ApplyJobProvider>();
    final hasApplied = (audition?.applied ?? false) ||
        (audition != null &&
            applyProvider.getApplicationForAudition(audition!.id) != null);

    const primaryColor = Color(0xFFDC8B20);
    const appliedColor = Color(0xFF27AE60);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: hasApplied
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
                if (onApply != null) {
                  onApply!();
                } else {
                  context.push(AppRoutes.applyJob, extra: audition);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: hasApplied ? appliedColor : primaryColor,
          disabledBackgroundColor: appliedColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
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