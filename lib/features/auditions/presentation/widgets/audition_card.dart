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
  String get displayRole => audition?.role ?? '';
  String get displayLocation => audition?.location ?? location ?? '';
  String get displayDeadline => audition?.deadline ?? deadline ?? '';
  String get displayPayout => audition?.pay ?? payout ?? '';
  String get displayLanguage => audition?.language ?? '';
  String get displayDescription => audition?.description ?? description ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF14323D),
            Color(0xFF0D232C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row: Category Pill + Role Tag + Deadline Pill
          Row(
            children: [
              if (displayCategory.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    displayCategory,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (displayRole.isNotEmpty)
                Expanded(
                  child: Text(
                    displayRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (displayDeadline.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      displayDeadline,
                      style: TextStyle(
                        color: Colors.amber.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          /// Title
          Text(
            displayTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 14),

          /// Meta Data Grid Chips (Location, Pay, Language, Applicants)
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              if (displayLocation.isNotEmpty)
                _buildMetaChip(Icons.location_on_outlined, displayLocation),
              if (displayPayout.isNotEmpty)
                _buildMetaChip(Icons.payments_outlined, displayPayout),
              if (displayLanguage.isNotEmpty && displayLanguage != 'N/A')
                _buildMetaChip(Icons.translate_outlined, displayLanguage),
              if (applicants != null && applicants != 'N/A')
                _buildMetaChip(Icons.people_alt_outlined, applicants!),
            ],
          ),

          if (displayDescription.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              displayDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 20),

          /// Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF091F28),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View details",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: AppColors.BtnGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradient.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "APPLY NOW",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}