import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:aicc/core/constants/app_colors.dart';

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    context.go(AppRoutes.auditions);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF06233E),
                    side: const BorderSide(
                      color: Color(0xFF1CC8FF),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not Interested",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasApplied
                        ? const [Color(0xFF1B4D3E), Color(0xFF27AE60)]
                        : AppColors.BtnGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  // Disabled when already applied
                  onPressed: hasApplied
                      ? null
                      : onApply ??
                          () {
                            context.push(AppRoutes.applyJob, extra: audition);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasApplied) ...
                        const [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                        ],
                      Text(
                        hasApplied ? "APPLIED" : "APPLY NOW",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}