import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../data/models/audition_model.dart';
import 'audition_card.dart';

class AuditionCards extends StatelessWidget {
  final List<AuditionModel>? auditions;

  const AuditionCards({
    super.key,
    this.auditions,
  });

  @override
  Widget build(BuildContext context) {
    final list = auditions ?? [];

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "No auditions found.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final audition = list[index];

        return AuditionCard(
          audition: audition,

          // -----------------------------------------------
          // View details
          // -----------------------------------------------
          onView: () => context.push(
            AppRoutes.auditionDetails,
            extra: audition,
          ),

          // -----------------------------------------------
          // Apply Now (disabled when already applied)
          // -----------------------------------------------
          onApply: () => context.push(
            AppRoutes.applyJob,
            extra: audition,
          ),

          // -----------------------------------------------
          // Edit application — opens ApplyScreen in view-
          // mode with the audition so the user can re-
          // submit / update their cover letter
          // Only shown when audition.applied == true
          // -----------------------------------------------
          onEdit: audition.applied
              ? () => context.push(
                    AppRoutes.applyJob,
                    extra: audition,
                  )
              : null,

          // -----------------------------------------------
          // Delete application — calls DELETE /applications
          // Only shown when audition.applied == true
          // -----------------------------------------------
          onDelete: audition.applied
              ? () => _confirmAndDelete(context, audition)
              : null,
        );
      },
    );
  }

  // ---------------------------------------------------------
  // Show confirmation then call provider delete
  // ---------------------------------------------------------

  Future<void> _confirmAndDelete(
    BuildContext context,
    AuditionModel audition,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0e2730),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xffEB5757),
            width: 1.2,
          ),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xffEB5757),
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              "Withdraw Application",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to withdraw your application for "
          "\"${audition.title}\"? This cannot be undone.",
          style: const TextStyle(
            color: Color(0xffAEB8CC),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xff4ad0fb)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffEB5757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Use the audition ID as the application ID for withdrawal.
    // The backend uses audition.id to look up the application.
    final provider = context.read<ApplyJobProvider>();
    final success = await provider.deleteApplication(
      applicationId: audition.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Application withdrawn successfully."
              : provider.errorMessage ?? "Failed to withdraw application.",
        ),
        backgroundColor:
            success ? const Color(0xFF27AE60) : const Color(0xffEB5757),
      ),
    );
  }
}