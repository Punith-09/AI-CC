import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../../features/auditions/presentation/providers/auditions_provider.dart';

class DesktopRightPanel extends StatelessWidget {
  const DesktopRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.only(left: 20, right: 24, top: 20, bottom: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Live Stats Card (India Casting Club style) ────────
            // _LiveStatsCard(),
            //
            // const SizedBox(height: 20),

            // ── Open Auditions / Recommendations ──────────────────
            _TrendingAuditionsCard(),

            const SizedBox(height: 24),

            // ── Quick Links Footer ────────────────────────────────
            // _FooterLinks(),
          ],
        ),
      ),
    );
  }
}

class _LiveStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Stats",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => context.go(AppRoutes.explore),
                child: Text(
                  "View stats",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8E3CF7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x3 Metrics Grid
          Row(
            children: const [
              Expanded(
                child: _StatTile(value: "53K", label: "Registered Users"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(value: "1.6K", label: "Total Auditions"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _StatTile(value: "38K", label: "Artist"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(value: "13K", label: "Model"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _StatTile(value: "3.5K", label: "Influencers"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(value: "3.2K", label: "Director"),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Center(
            child: Text(
              "Stats refreshed weekly",
              style: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF8E3CF7),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingAuditionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final titleColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final tileBg = isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC);
    final tileBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Consumer<AuditionsProvider>(
      builder: (context, provider, _) {
        final auditions = provider.auditions.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Auditions",
                    style: GoogleFonts.poppins(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go(AppRoutes.auditions),
                    child: Text(
                      "See all",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8E3CF7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (auditions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Discover new casting calls and auditions daily.",
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                ...auditions.map((audition) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        context.push(
                          AppRoutes.auditionDetails,
                          extra: audition,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tileBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: tileBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E3CF7).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFF8E3CF7),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audition.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: titleColor,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${audition.role.isNotEmpty ? audition.role : audition.category} • ${audition.location.isNotEmpty ? audition.location : 'India'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: subtitleColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: subtitleColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _linkItem(context, "About"),
              _bullet(),
              _linkItem(context, "Live Stats"),
              _bullet(),
              _linkItem(context, "Pricing"),
              _bullet(),
              _linkItem(context, "Privacy"),
              _bullet(),
              _linkItem(context, "Terms"),
              _bullet(),
              _linkItem(context, "Refund Policy"),
              _bullet(),
              _linkItem(context, "Child Safety"),
              _bullet(),
              _linkItem(context, "Contact"),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "© 2026 India Casting Club / Treeko. All rights reserved.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkItem(BuildContext context, String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF64748B),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _bullet() {
    return Text(
      "•",
      style: GoogleFonts.poppins(
        color: const Color(0xFFCBD5E1),
        fontSize: 11,
      ),
    );
  }
}
