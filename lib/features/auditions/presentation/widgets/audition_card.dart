import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  /// Called when the user taps the Delete icon.
  /// Only shown when [audition.applied] is true.
  final VoidCallback? onDelete;

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
    this.onDelete,
  });

  String get displayTitle => audition?.title ?? title ?? '';
  String get displayCategory => audition?.category ?? category ?? 'Film';
  String get displayRole => audition?.role ?? '';
  String get displayLocation => audition?.location ?? location ?? '';
  String get displayDeadline => audition?.deadline ?? deadline ?? '';
  String get displayPayout => audition?.pay ?? payout ?? '';
  String get displayLanguage => audition?.language ?? '';
  String get displayDescription => audition?.description ?? description ?? '';

  /// Show edit+delete row only if the user has already applied
  bool get _hasApplied => audition?.applied ?? false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    const goldColor = Color(0xFFE5A844);
    const dateColor = Color(0xFFA37D42);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row: Category Pill on left, Calendar + Deadline on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1A10) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: goldColor.withValues(alpha: isDark ? 0.25 : 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  displayCategory,
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Deadline with Calendar icon
              if (displayDeadline.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 13,
                      color: dateColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      displayDeadline,
                      style: const TextStyle(
                        color: dateColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          /// Title
          Text(
            displayTitle,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),

          const SizedBox(height: 12),

          /// Meta Data Chips Row (Location, Pay, Language)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (displayLocation.isNotEmpty)
                _buildMetaChip(
                  icon: LucideIcons.mapPin,
                  label: displayLocation,
                  isDark: isDark,
                ),
              if (displayPayout.isNotEmpty)
                _buildMetaChip(
                  icon: LucideIcons.banknote,
                  label: displayPayout,
                  isDark: isDark,
                ),
              if (displayLanguage.isNotEmpty && displayLanguage != 'N/A')
                _buildMetaChip(
                  icon: LucideIcons.languages,
                  label: displayLanguage,
                  isDark: isDark,
                ),
            ],
          ),

          /// Description
          if (displayDescription.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              displayDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF4B5563),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],

          /// Applied action row (if user has applied)
          if (_hasApplied) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF27AE60), width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Color(0xFF27AE60)),
                      SizedBox(width: 4),
                      Text(
                        "Application Submitted",
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                    onPressed: onDelete,
                    tooltip: 'Withdraw Application',
                  ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          /// Action Buttons: View Details + Apply Now
          Row(
            children: [
              // 1. View Details Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1B1B1D) : const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "View Details",
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Apply Now Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _hasApplied ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasApplied
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE59424),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF2A2A2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _hasApplied ? "Applied" : "Apply Now",
                      style: TextStyle(
                        color: _hasApplied ? Colors.white60 : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFFFF9500),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}