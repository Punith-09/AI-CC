import 'package:flutter/material.dart';

import '../../data/models/audition_model.dart';

class AuditionCard extends StatelessWidget {
  final AuditionModel audition;
  final VoidCallback onView;
  final VoidCallback onApply;
  final VoidCallback? onDelete;

  /// If true, this audition is in "Past Auditions" tab – show "Audition Closed" button.
  final bool isPast;

  const AuditionCard({
    super.key,
    required this.audition,
    required this.onView,
    required this.onApply,
    this.onDelete,
    this.isPast = false,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  static const _primaryOrange = Color(0xFFE59424);
  static const _tileBg = Color(0xFFFAF3E8);
  static const _tileLabel = Color(0xFF999999);
  static const _tileValue = Color(0xFF1C1C1C);
  static const _darkTileBg = Color(0xFF1E1A14);
  static const _darkTileLabel = Color(0xFF888888);
  static const _darkTileValue = Color(0xFFEEEEEE);

  /// Returns a human-readable "X days/hours ago" string from an ISO-8601 createdAt.
  String _timeAgo(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(createdAt);
      if (dt == null) return '';
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
      if (diff.inHours > 0) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  /// Returns days left until deadline. Negative = expired.
  int _daysLeft(String deadline) {
    if (deadline.isEmpty) return 0;
    try {
      // Try ISO parse first
      DateTime? dt = DateTime.tryParse(deadline.trim());
      if (dt == null) {
        // Try dd-MM-yyyy or dd/MM/yyyy
        final parts = deadline.trim().split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      }
      if (dt == null) return 0;
      final now = DateTime.now();
      return dt.difference(DateTime(now.year, now.month, now.day)).inDays;
    } catch (_) {
      return 0;
    }
  }

  String _formatDeadline(String deadline) {
    if (deadline.isEmpty) return '';
    try {
      DateTime? dt = DateTime.tryParse(deadline.trim());
      if (dt == null) {
        final parts = deadline.trim().split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      }
      if (dt == null) return deadline;
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return deadline;
    }
  }

  String _deriveGender() {
    if (audition.roleGender.isNotEmpty) return audition.roleGender;
    if (audition.gender.isNotEmpty) return audition.gender;
    final text = '${audition.role} ${audition.title} ${audition.description}'.toLowerCase();
    if (text.contains('female') || text.contains('actress')) return 'Female';
    if (text.contains('male') || text.contains('actor')) return 'Male';
    return 'Male and Female';
  }

  String _deriveAge() {
    if (audition.age.isNotEmpty) return audition.age;
    final min = audition.roleAgeMin;
    final max = audition.roleAgeMax;
    if (min != null && max != null) return '$min - $max Yrs';
    if (min != null) return '$min+ Yrs';
    return 'Any Age';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE8E8E8);

    final daysLeft = _daysLeft(audition.deadline);
    final timeAgo = _timeAgo(audition.createdAt);
    final formattedDeadline = _formatDeadline(audition.deadline);
    final gender = _deriveGender();
    final age = _deriveAge();

    final producerName = audition.producer.isNotEmpty ? audition.producer : 'Confidential';
    final directorName = audition.director.isNotEmpty ? audition.director : 'Confidential';

    return GestureDetector(
      onTap: onView,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ─────────────────────────────────────────────────────
            _buildBanner(isDark),

            // ── Card Body ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Chip + Title + "New" badge
                  _buildTitleRow(isDark),
                  const SizedBox(height: 12),

                  // Producer / Director
                  _buildProducerDirectorRow(isDark, producerName, directorName),
                  const SizedBox(height: 12),

                  // Role label
                  Center(
                    child: Text(
                      'Role - ${audition.role.isNotEmpty ? audition.role : 'Artists'}',
                      style: const TextStyle(
                        color: Color(0xFF1C1C1C),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Tiles Grid
                  _buildInfoGrid(isDark, gender, age),
                  const SizedBox(height: 14),

                  // Footer: time, views, applications + deadline + days left
                  _buildFooter(isDark, timeAgo, formattedDeadline, daysLeft),
                  const SizedBox(height: 14),

                  // Apply Button
                  _buildApplyButton(isDark, daysLeft),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildBanner(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          // Background image from assets (same audition.png used in analytics card)
          SizedBox(
            width: double.infinity,
            height: 180,
            child: Image.asset(
              'assets/images/audition.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stack) => Container(
                height: 180,
                color: const Color(0xFF1C1309),
              ),
            ),
          ),

          // Gradient overlay for legibility
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Category badge (top-center)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: _primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  audition.category.isNotEmpty ? audition.category : 'Audition',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(bool isDark) {
    final isNew = audition.createdAt.isNotEmpty &&
        DateTime.now().difference(DateTime.tryParse(audition.createdAt) ?? DateTime(2000)).inDays < 7;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Short ID badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: _primaryOrange, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            shortIdFrom(audition.id),
            style: const TextStyle(
              color: _primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            audition.title.isNotEmpty ? audition.title : 'Audition',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1C1C1C),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isNew) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1),
            ),
            child: const Text(
              'New',
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String shortIdFrom(String id) {
    if (id.isEmpty) return 'RD0000';
    if (id.length >= 6) return id.substring(0, 6).toUpperCase();
    return id.toUpperCase();
  }

  Widget _buildProducerDirectorRow(bool isDark, String producer, String director) {
    final labelColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);
    final valueColor = isDark ? Colors.white : const Color(0xFF1C1C1C);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PRODUCER',
                  style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(producer,
                  style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DIRECTOR',
                  style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(director,
                  style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(bool isDark, String gender, String age) {
    final tileBg = isDark ? _darkTileBg : _tileBg;
    final labelColor = isDark ? _darkTileLabel : _tileLabel;
    final valueColor = isDark ? _darkTileValue : _tileValue;

    final positionStr = audition.positionsAvailable > 0
        ? audition.positionsAvailable.toString()
        : '—';
    final budget = audition.pay.isNotEmpty ? audition.pay : 'Based on profile';
    final languages = audition.language.isNotEmpty ? audition.language : 'Any Language';
    final location = audition.location.isNotEmpty ? audition.location : 'Any Location';

    // Build a 2-column grid of info tiles
    final tiles = <_InfoTileData>[
      _InfoTileData(label: 'GENDER', value: gender),
      _InfoTileData(label: 'AGE', value: age),
      _InfoTileData(label: 'BUDGET', value: budget),
      _InfoTileData(label: 'POSITION', value: positionStr),
      _InfoTileData(label: 'LANGUAGES', value: languages),
      _InfoTileData(label: 'LOCATION', value: location),
    ];

    // Pair tiles into rows of 2
    final rows = <List<_InfoTileData>>[];
    for (int i = 0; i < tiles.length; i += 2) {
      rows.add([
        tiles[i],
        if (i + 1 < tiles.length) tiles[i + 1],
      ]);
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (int i = 0; i < row.length; i++) ...[
                Expanded(
                  child: _buildInfoTile(
                    label: row[i].label,
                    value: row[i].value,
                    tileBg: tileBg,
                    labelColor: labelColor,
                    valueColor: valueColor,
                  ),
                ),
                if (i < row.length - 1) const SizedBox(width: 8),
              ],
              // Fill remaining space if only 1 tile in last row
              if (row.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required Color tileBg,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark, String timeAgo, String formattedDeadline, int daysLeft) {
    final subtitleColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF888888);
    final textColor = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444);

    final viewsCount = audition.viewCount;
    final applicantsCount = audition.applicantsCount;

    // Days-left chip color
    Color chipColor;
    String chipLabel;
    if (daysLeft <= 0) {
      chipColor = const Color(0xFF333333);
      chipLabel = 'Closing today';
    } else if (daysLeft <= 3) {
      chipColor = const Color(0xFFE53935);
      chipLabel = '$daysLeft day${daysLeft == 1 ? '' : 's'} left';
    } else {
      chipColor = const Color(0xFF2D2D2D);
      chipLabel = '$daysLeft days left';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time ago · Views · Applications
        Row(
          children: [
            if (timeAgo.isNotEmpty) ...[
              Icon(Icons.access_time_rounded, size: 13, color: subtitleColor),
              const SizedBox(width: 4),
              Text(timeAgo, style: TextStyle(color: subtitleColor, fontSize: 12)),
              const SizedBox(width: 14),
            ],
            if (viewsCount > 0) ...[
              Icon(Icons.remove_red_eye_outlined, size: 13, color: subtitleColor),
              const SizedBox(width: 4),
              Text(viewsCount.toString(), style: TextStyle(color: subtitleColor, fontSize: 12)),
              const SizedBox(width: 14),
            ],
            if (applicantsCount > 0) ...[
              Text(
                'Applications ($applicantsCount)',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Deadline + days left chip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (formattedDeadline.isNotEmpty)
              Text(
                'Apply before $formattedDeadline',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (daysLeft >= 0 || daysLeft == 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chipLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplyButton(bool isDark, int daysLeft) {
    final isClosed = isPast || daysLeft < 0;
    final isApplied = audition.applied;
    final status = audition.applicationStatus.toUpperCase();

    Color btnColor;
    String btnLabel;
    VoidCallback? btnAction;
    IconData? btnIcon;

    if (isClosed) {
      btnColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFF888888);
      btnLabel = 'Audition Closed';
      btnAction = null;
      btnIcon = null;
    } else if (isApplied && status == 'SHORTLISTED') {
      btnColor = const Color(0xFF27AE60);
      btnLabel = 'Shortlisted';
      btnIcon = Icons.star_rounded;
      btnAction = null;
    } else if (isApplied && status == 'REJECTED') {
      btnColor = const Color(0xFFE53935);
      btnLabel = 'Rejected';
      btnIcon = Icons.cancel_rounded;
      btnAction = null;
    } else if (isApplied) {
      btnColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFF888888);
      btnLabel = 'Applied';
      btnIcon = null;
      btnAction = null;
    } else {
      btnColor = _primaryOrange;
      btnLabel = 'Apply Now';
      btnIcon = null;
      btnAction = onApply;
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: btnAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          disabledBackgroundColor: btnColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (btnIcon != null) ...[
              Icon(btnIcon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              btnLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTileData {
  final String label;
  final String value;
  const _InfoTileData({required this.label, required this.value});
}