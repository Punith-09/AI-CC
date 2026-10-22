import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/live_stats_provider.dart';
import '../../data/models/live_stats_model.dart';

class LiveStatsScreen extends StatefulWidget {
  const LiveStatsScreen({super.key});

  @override
  State<LiveStatsScreen> createState() => _LiveStatsScreenState();
}

class _LiveStatsScreenState extends State<LiveStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveStatsProvider>().fetchStats();
    });
  }

  // ─── Number formatter ─────────────────────────────────────────────────────

  String _fmt(int n) {
    // Simple thousands separator (e.g. 18306 → 18,306)
    final str = n.abs().toString();
    final buf = StringBuffer();
    final start = str.length % 3;
    if (start > 0) buf.write(str.substring(0, start));
    for (int i = start; i < str.length; i += 3) {
      if (buf.isNotEmpty) buf.write(',');
      buf.write(str.substring(i, i + 3));
    }
    return n < 0 ? '-${buf.toString()}' : buf.toString();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkScaffold : const Color(0xFFF4F6FA);
    final titleColor = isDark ? Colors.white : AppColors.lightText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkScaffold : Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black12,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: titleColor,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Live Stats',
            style: GoogleFonts.sora(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Consumer<LiveStatsProvider>(
              builder: (_, p, __) => IconButton(
                icon: Icon(Icons.refresh_rounded, color: titleColor, size: 22),
                onPressed: p.isLoading ? null : () => p.fetchStats(),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        body: Consumer<LiveStatsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.stats == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7C3AED),
                  strokeWidth: 2.5,
                ),
              );
            }

            if (provider.error != null && provider.stats == null) {
              return _ErrorView(
                message: provider.error!,
                onRetry: () => provider.fetchStats(),
              );
            }

            final stats = provider.stats;
            if (stats == null) {
              return const Center(child: Text('No data available.'));
            }

            return RefreshIndicator(
              color: const Color(0xFF7C3AED),
              onRefresh: () => provider.fetchStats(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
                children: [
                  // ── Users Overview ──────────────────────────────────────
                  _SectionHeader(
                    label: 'Users',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _TwoColumnGrid(children: [
                    _StatCard(
                      value: _fmt(stats.users.total),
                      label: 'Total Users',
                      description: 'All registered users on the platform.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.users.artists),
                      label: 'Artists',
                      description: 'Users registered as artists.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.users.audience),
                      label: 'Audience / Guest',
                      description: 'Users registered as audience / guests.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.users.byGender.male),
                      label: 'Male',
                      description: 'Male users across all roles.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.users.byGender.female),
                      label: 'Female',
                      description: 'Female users across all roles.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.users.byGender.other +
                          stats.users.byGender.unspecified),
                      label: 'Other / Unspecified',
                      description: 'Other or unspecified gender profiles.',
                      isDark: isDark,
                    ),
                  ]),

                  // ── By Craft ────────────────────────────────────────────
                  if (stats.users.byCraft.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(label: 'Users by Craft', isDark: isDark),
                    const SizedBox(height: 10),
                    _TwoColumnGrid(
                      children: stats.users.byCraft
                          .map((nc) => _StatCard(
                                value: _fmt(nc.count),
                                label: nc.name,
                                description:
                                    'Artists registered under ${nc.name}.',
                                isDark: isDark,
                              ))
                          .toList(),
                    ),
                  ],

                  // ── By State ────────────────────────────────────────────
                  if (stats.users.byState.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(label: 'Users by State', isDark: isDark),
                    const SizedBox(height: 10),
                    _TwoColumnGrid(
                      children: stats.users.byState
                          .map((nc) => _StatCard(
                                value: _fmt(nc.count),
                                label: nc.name,
                                description:
                                    'Profiles with present state ${nc.name}.',
                                isDark: isDark,
                              ))
                          .toList(),
                    ),
                  ],

                  // ── Auditions ───────────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'Auditions', isDark: isDark),
                  const SizedBox(height: 10),
                  _TwoColumnGrid(children: [
                    _StatCard(
                      value: _fmt(stats.auditions.total),
                      label: 'Total Auditions',
                      description: 'All auditions posted on the platform.',
                      isDark: isDark,
                    ),
                    if (stats.auditions.live != null)
                      _StatCard(
                        value: _fmt(stats.auditions.live!),
                        label: 'Live Auditions',
                        description: 'Currently live / open auditions.',
                        isDark: isDark,
                      ),
                    if (stats.auditions.closed != null)
                      _StatCard(
                        value: _fmt(stats.auditions.closed!),
                        label: 'Closed Auditions',
                        description: 'Closed auditions.',
                        isDark: isDark,
                      ),
                    ...stats.auditions.byCraft.expand((nc) => [
                          _StatCard(
                            value: _fmt(nc.count),
                            label: '${nc.name}',
                            description:
                                'Auditions in the ${nc.name} category.',
                            isDark: isDark,
                          ),
                        ]),
                  ]),

                  // ── Applications ────────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'Applications', isDark: isDark),
                  const SizedBox(height: 10),
                  _TwoColumnGrid(children: [
                    _StatCard(
                      value: _fmt(stats.applications.total),
                      label: 'Total Applications',
                      description: 'All submitted applications.',
                      isDark: isDark,
                    ),
                  ]),

                  // ── Content ─────────────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'Content', isDark: isDark),
                  const SizedBox(height: 10),
                  _TwoColumnGrid(children: [
                    _StatCard(
                      value: _fmt(stats.content.totalMediaPosts),
                      label: 'Total Media Posts',
                      description: 'All published photos and videos.',
                      isDark: isDark,
                    ),
                    if (stats.content.imagePosts != null)
                      _StatCard(
                        value: _fmt(stats.content.imagePosts!),
                        label: 'Image Posts',
                        description: 'Total image posts.',
                        isDark: isDark,
                      ),
                    if (stats.content.videoPosts != null)
                      _StatCard(
                        value: _fmt(stats.content.videoPosts!),
                        label: 'Video Posts',
                        description: 'Total video posts.',
                        isDark: isDark,
                      ),
                    _StatCard(
                      value: _fmt(stats.content.stories),
                      label: 'Total Stories',
                      description: 'All stories posted.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.content.activeStories),
                      label: 'Active Stories',
                      description: 'Currently live stories.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.content.videoViews),
                      label: 'Video Views',
                      description: 'Total views across all videos.',
                      isDark: isDark,
                    ),
                    _StatCard(
                      value: _fmt(stats.content.storyViews),
                      label: 'Story Views',
                      description: 'Total views across all stories.',
                      isDark: isDark,
                    ),
                    if (stats.content.reach != null)
                      _StatCard(
                        value: _fmt(stats.content.reach!),
                        label: 'Reach',
                        description: 'Total content reach.',
                        isDark: isDark,
                      ),
                    if (stats.content.profileViews != null)
                      _StatCard(
                        value: _fmt(stats.content.profileViews!),
                        label: 'Profile Views',
                        description: 'Total profile views.',
                        isDark: isDark,
                      ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.lightText,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── 2-Column Grid helper ─────────────────────────────────────────────────────

class _TwoColumnGrid extends StatelessWidget {
  final List<Widget> children;

  const _TwoColumnGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    // Build rows of 2
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : const SizedBox();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 10),
            Expanded(child: right),
          ],
        ),
      );
      if (i + 2 < children.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String description;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final labelColor = isDark ? Colors.white : const Color(0xFF111827);
    final descColor = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Value
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7C3AED),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: descColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 56,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load stats',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.sora(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
