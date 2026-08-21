import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../data/models/audition_model.dart';
import '../../presentation/providers/auditions_provider.dart';
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

    final provider = context.read<ApplyJobProvider>();

    // If applications haven't been fetched yet, fetch them first so we can
    // resolve the actual application ID (which is different from audition.id).
    if (provider.applications.isEmpty) {
      await provider.fetchMyApplications();
    }

    if (!context.mounted) return;

    // Look up the application for this audition.
    // The backend requires the APPLICATION ID, not the audition ID.
    final application = provider.getApplicationForAudition(audition.id);

    if (application == null || application.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not find your application. Please try again."),
          backgroundColor: Color(0xffEB5757),
        ),
      );
      return;
    }

    final success = await provider.deleteApplication(
      applicationId: application.id,
    );

    if (!context.mounted) return;

    if (success) {
      // Immediately update the applied flag in the auditions list so the card
      // flips from APPLIED → APPLY NOW without waiting for a server re-fetch.
      context
          .read<AuditionsProvider>()
          .markAuditionUnapplied(audition.id);
    }

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