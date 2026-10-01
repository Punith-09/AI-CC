import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../apply_job/data/models/application_model.dart';
import '../../../auditions/data/models/audition_model.dart';

class AuditionInfoCard extends StatelessWidget {
  final AuditionModel audition;

  /// The user's application for this audition.
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
    return application != null && application!.id.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2A2E),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // TOP ROW: Category & Deadline
          // =====================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CATEGORY PILL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF261D13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  audition.category.isNotEmpty ? audition.category : 'Film',
                  style: const TextStyle(
                    color: Color(0xFFDC8B20),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // DEADLINE
              if (audition.deadline.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: Color(0xFFDC8B20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      audition.deadline,
                      style: const TextStyle(
                        color: Color(0xFFDC8B20),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // =====================================================
          // TITLE
          // =====================================================
          Text(
            audition.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // =====================================================
          // INFORMATION CHIPS
          // =====================================================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (audition.location.isNotEmpty) ...[
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    text: audition.location,
                  ),
                  const SizedBox(width: 8),
                ],
                if (audition.pay.isNotEmpty) ...[
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    text: audition.pay,
                  ),
                  const SizedBox(width: 8),
                ],
                if (audition.language.isNotEmpty)
                  _InfoChip(
                    icon: Icons.translate,
                    text: audition.language,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

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
              color: Color(0xFF8E8E93),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          // =====================================================
          // APPLICATION STATUS
          // =====================================================
          if (hasApplied) ...[
            const SizedBox(height: 16),
            _buildAppliedSection(),
          ] else if (onViewDetails != null || onApply != null) ...[
            const SizedBox(height: 16),
            _buildNotAppliedSection(),
          ],
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "You've applied · Manage your application",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onEdit != null)
                _ActionButton(
                  icon: Icons.edit_outlined,
                  gradient: const [
                    Color(0xff20D5FF),
                    Color(0xffCC3EFF),
                  ],
                  onTap: onEdit!,
                ),
              if (onEdit != null && onWithdraw != null)
                const SizedBox(width: 8),
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
                minimumSize: const Size(0, 48),
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "View details",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (onViewDetails != null && onApply != null)
          const SizedBox(width: 12),
        if (onApply != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "APPLY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFDC8B20),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD1D1D6),
              fontSize: 12,
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}