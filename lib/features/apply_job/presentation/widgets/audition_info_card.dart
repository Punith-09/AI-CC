import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auditions/data/models/audition_model.dart';

class AuditionInfoCard extends StatelessWidget {
  final AuditionModel? audition;

  const AuditionInfoCard({
    super.key,
    this.audition,
  });

  @override
  Widget build(BuildContext context) {
    final title = audition?.title.isNotEmpty == true
        ? audition!.title
        : "Music Video Backup Dancer";
    final seekingRole = audition?.role.isNotEmpty == true
        ? audition!.role
        : (audition?.category.isNotEmpty == true
            ? audition!.category
            : "Hip Hop Choreography Crew");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (audition?.category.isNotEmpty == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    audition!.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (audition?.deadline.isNotEmpty == true)
                Text(
                  "Deadline: ${audition!.deadline}",
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Seeking: ",
                  style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: seekingRole,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (audition?.location.isNotEmpty == true || audition?.pay.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (audition?.location.isNotEmpty == true) ...[
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    audition!.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                ],
                if (audition?.pay.isNotEmpty == true) ...[
                  const Icon(Icons.payments_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    audition!.pay,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}