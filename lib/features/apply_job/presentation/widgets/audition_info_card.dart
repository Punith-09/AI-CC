import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../apply_job/data/models/application_model.dart';
import '../../../auditions/data/models/audition_model.dart';

class AuditionInfoCard extends StatelessWidget {
  final AuditionModel audition;

  /// The user's application for this audition.
  ///
  /// IMPORTANT:
  /// application.id = APPLICATION ID
  /// audition.id = AUDITION ID
  final ApplicationModel? application;

  /// Called when user taps edit.
  final VoidCallback? onEdit;

  /// Called when user taps withdraw/delete.
  final VoidCallback? onWithdraw;

  /// Optional callback when user wants to apply.
  final VoidCallback? onApply;

  /// Optional callback for details.
  final VoidCallback? onViewDetails;

  const AuditionInfoCard({
    super.key,
    required this.audition,
    this.application,
    this.onEdit,
    this.onWithdraw,
    this.onApply,
    this.onViewDetails,
  });

  bool get hasApplied {
    return application != null &&
        application!.id.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.background.withValues(
          alpha: 0.55,
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.5,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================================================
          // TOP ROW
          // =====================================================

          Row(
            children: [
              // CATEGORY
              if (audition.category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.15,
                    ),

                    borderRadius:
                    BorderRadius.circular(8),

                    border: Border.all(
                      color: AppColors.primary
                          .withValues(alpha: 0.5),
                    ),
                  ),

                  child: Text(
                    audition.category,

                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // ROLE
              if (audition.role.isNotEmpty)
                Expanded(
                  child: Text(
                    audition.role,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // DEADLINE
              if (audition.deadline.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.amber,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      audition.deadline,

                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 18),

          // =====================================================
          // TITLE
          // =====================================================

          Text(
            audition.title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // INFORMATION CHIPS
          // =====================================================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: [
                if (audition.location.isNotEmpty)
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    text: audition.location,
                  ),

                if (audition.location.isNotEmpty)
                  const SizedBox(width: 10),

                if (audition.pay.isNotEmpty)
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    text: audition.pay,
                  ),

                if (audition.pay.isNotEmpty)
                  const SizedBox(width: 10),

                if (audition.language.isNotEmpty)
                  _InfoChip(
                    icon: Icons.translate,
                    text: audition.language,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =====================================================
          // DESCRIPTION
          // =====================================================

          Text(
            audition.description.isNotEmpty
                ? audition.description
                : "No further description provided.",

            maxLines: 3,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // APPLICATION STATUS
          // =====================================================

          if (hasApplied)
            _buildAppliedSection()
          else
            _buildNotAppliedSection(),
        ],
      ),
    );
  }

  // ===========================================================
  // APPLIED SECTION
  // ===========================================================

  Widget _buildAppliedSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: const Color(0xff073F36),

            borderRadius:
            BorderRadius.circular(18),

            border: Border.all(
              color: Colors.green.withValues(
                alpha: 0.45,
              ),
            ),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "You've applied · Manage your application",

                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // =================================================
              // EDIT
              // =================================================

              if (onEdit != null)
                _ActionButton(
                  icon: Icons.edit_outlined,

                  gradient: const [
                    Color(0xff20D5FF),
                    Color(0xffCC3EFF),
                  ],

                  onTap: onEdit!,
                ),

              if (onEdit != null &&
                  onWithdraw != null)
                const SizedBox(width: 8),

              // =================================================
              // WITHDRAW
              // =================================================

              if (onWithdraw != null)
                _ActionButton(
                  icon: Icons.delete_outline_rounded,

                  gradient: const [
                    Color(0xffEB5757),
                    Color(0xffFF8C42),
                  ],

                  onTap: onWithdraw!,
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // =====================================================
        // DETAILS + APPLIED
        // =====================================================

        Row(
          children: [
            if (onViewDetails != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,

                  style: OutlinedButton.styleFrom(
                    minimumSize:
                    const Size(0, 58),

                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Text(
                        "View details",

                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 10),

                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(width: 16),

            Expanded(
              child: Container(
                height: 58,

                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      Color(0xff1E754D),
                      Color(0xff20B45A),
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(18),
                ),

                child: const Center(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "APPLIED",

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================
  // NOT APPLIED SECTION
  // ===========================================================

  Widget _buildNotAppliedSection() {
    return Row(
      children: [
        if (onViewDetails != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onViewDetails,

              style: OutlinedButton.styleFrom(
                minimumSize:
                const Size(0, 58),

                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),

              child: const Text(
                "View details",

                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (onViewDetails != null)
          const SizedBox(width: 16),

        if (onApply != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,

              style: ElevatedButton.styleFrom(
                minimumSize:
                const Size(0, 58),

                backgroundColor:
                AppColors.primary,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),

              child: const Text(
                "APPLY",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================
// INFO CHIP
// =============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.card.withValues(
          alpha: 0.8,
        ),

        borderRadius:
        BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),

          const SizedBox(width: 8),

          Text(
            text,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// ACTION BUTTON
// =============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 52,
        height: 52,

        decoration: BoxDecoration(
          gradient:
          LinearGradient(colors: gradient),

          borderRadius:
          BorderRadius.circular(15),

          boxShadow: [
            BoxShadow(
              color:
              gradient.last.withValues(
                alpha: 0.30,
              ),

              blurRadius: 10,

              spreadRadius: -2,
            ),
          ],
        ),

        child: Icon(
          icon,

          color: Colors.white,

          size: 25,
        ),
      ),
    );
  }
}