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

  const   AuditionInfoCard({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    const goldColor = Color(0xFFDC8B20);
    final dateColor = isDark ? const Color(0xFFA37D42) : const Color(0xFF92400E);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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
                  color: isDark ? const Color(0xFF1F1A10) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goldColor.withValues(alpha: isDark ? 0.3 : 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  audition.category.isNotEmpty ? audition.category : 'Film',
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // DEADLINE
              if (audition.deadline.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: dateColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      audition.deadline,
                      style: TextStyle(
                        color: dateColor,
                        fontSize: 12.5,
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
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
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
            style: TextStyle(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF4B5563),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          // =====================================================
          // APPLICATION STATUS
          // =====================================================
          if (hasApplied) ...[
            const SizedBox(height: 16),
            _buildAppliedSection(context),
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

  Widget _buildAppliedSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff073F36) : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withValues(alpha: isDark ? 0.45 : 0.3),
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
              Expanded(
                child: Text(
                  "You've applied · Manage your application",
                  style: TextStyle(
                    color: isDark ? Colors.green : const Color(0xFF065F46),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFFDC8B20),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF475569),
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