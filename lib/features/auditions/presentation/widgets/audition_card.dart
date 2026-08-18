import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/audition_model.dart';

class AuditionCard extends StatelessWidget {
  final AuditionModel? audition;
  final String? title;
  final String? category;
  final String? location;
  final String? deadline;
  final String? payout;
  final String? applicants;
  final String? description;

  final VoidCallback onView;
  final VoidCallback onApply;

  const AuditionCard({
    super.key,
    this.audition,
    this.title,
    this.category,
    this.location,
    this.deadline,
    this.payout,
    this.applicants,
    this.description,
    required this.onView,
    required this.onApply,
  });

  String get displayTitle => audition?.title ?? title ?? '';
  String get displayCategory => audition?.category ?? category ?? '';
  String get displayLocation => audition?.location ?? location ?? '';
  String get displayDeadline => audition?.deadline ?? deadline ?? '';
  String get displayPayout => audition?.pay ?? payout ?? '';
  String get displayApplicants => applicants ?? 'N/A';
  String get displayDescription => audition?.description ?? description ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2730),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Deadline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Deadline",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayDeadline,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 14),

          /// Category
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayCategory,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _info(Icons.groups_2, displayCategory),
              _info(Icons.location_on_outlined, displayLocation),
              _info(Icons.currency_rupee, displayPayout),
              _info(Icons.people_alt_outlined, displayApplicants),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            displayDescription,
            style: const TextStyle(
              color: AppColors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF06233E),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View details",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.gradient,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "APPLY NOW",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.white),
        ),
      ],
    );
  }
}