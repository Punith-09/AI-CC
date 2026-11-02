import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../data/models/audition_model.dart';
import '../providers/auditions_provider.dart';
import '../widgets/audition_cards.dart';

class AuditionScreen extends StatefulWidget {
  const AuditionScreen({super.key});

  @override
  State<AuditionScreen> createState() => _AuditionScreenState();
}

class _AuditionScreenState extends State<AuditionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AuditionsProvider>().fetchAuditions();
      context.read<AuditionsProvider>().fetchMyPostedAuditions();
      await context.read<ApplyJobProvider>().fetchMyApplications();
      if (!mounted) return;
      // Sync application statuses into audition cards so Shortlisted/Rejected
      // badges appear immediately on load.
      final applications = context.read<ApplyJobProvider>().applications;
      final auditionsProvider = context.read<AuditionsProvider>();
      for (final app in applications) {
        if (app.auditionId.isNotEmpty && app.status.isNotEmpty) {
          auditionsProvider.markAuditionApplicationStatus(
            app.auditionId,
            app.status,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Splits auditions into active (deadline in future) and past (expired).
  (List<AuditionModel>, List<AuditionModel>) _splitAuditions(
      List<AuditionModel> all) {
    final active = <AuditionModel>[];
    final past = <AuditionModel>[];

    for (final a in all) {
      final daysLeft = _daysLeft(a.deadline);
      if (daysLeft >= 0) {
        active.add(a);
      } else {
        past.add(a);
      }
    }
    return (active, past);
  }

  int _daysLeft(String deadline) {
    if (deadline.isEmpty) return 999;
    try {
      DateTime? dt = DateTime.tryParse(deadline.trim());
      if (dt == null) {
        final parts = deadline.trim().split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            dt = DateTime(int.parse(parts[0]), int.parse(parts[1]),
                int.parse(parts[2]));
          } else {
            dt = DateTime(int.parse(parts[2]), int.parse(parts[1]),
                int.parse(parts[0]));
          }
        }
      }
      if (dt == null) return 999;
      final today = DateTime(now.year, now.month, now.day);
      return dt.difference(today).inDays;
    } catch (_) {
      return 999;
    }
  }

  DateTime get now => DateTime.now();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    context.watch<ApplyJobProvider>(); // watch for apply state changes
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (activeAuditions, pastAuditions) =
        _splitAuditions(auditionsProvider.auditions);

    final body = RefreshIndicator(
      color: const Color(0xFFE59424),
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      onRefresh: () async {
        await Future.wait([
          context.read<AuditionsProvider>().fetchAuditions(),
          context.read<AuditionsProvider>().fetchMyPostedAuditions(),
          context.read<ApplyJobProvider>().fetchMyApplications(),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Title ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 26, bottom: 14),
              child: Text(
                'Auditions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1C1C1C),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          // ── Active / Past Auditions Tab Bar ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabBar(isDark),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Content Switcher ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildTabContent(
              isDark: isDark,
              activeAuditions: activeAuditions,
              pastAuditions: pastAuditions,
              isLoading: auditionsProvider.isLoading,
              errorMessage: auditionsProvider.errorMessage,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(backgroundColor: Colors.transparent, body: body);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: body,
        ),
      ),
    );
  }

  // ── Tab Bar (pill style like the mockup) ──────────────────────────────────

  Widget _buildTabBar(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0);
    const activeColor = Color(0xFFE59424);
    final inactiveColor =
        isDark ? Colors.white54 : const Color(0xFF888888);

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final tab = _tabController.index;
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              _buildTabPill(
                label: 'Active',
                isSelected: tab == 0,
                onTap: () => _tabController.animateTo(0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                isDark: isDark,
              ),
              _buildTabPill(
                label: 'Past Auditions',
                isSelected: tab == 1,
                onTap: () => _tabController.animateTo(1),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : inactiveColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Content ────────────────────────────────────────────────────────────

  Widget _buildTabContent({
    required bool isDark,
    required List<AuditionModel> activeAuditions,
    required List<AuditionModel> pastAuditions,
    required bool isLoading,
    String? errorMessage,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFE59424)),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Color(0xFFE59424)),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE59424),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () =>
                    context.read<AuditionsProvider>().fetchAuditions(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isActive = _tabController.index == 0;
        final list = isActive ? activeAuditions : pastAuditions;

        if (list.isEmpty) {
          return _buildEmptyState(
            isDark: isDark,
            message: isActive
                ? 'No active auditions right now.\nPull down to refresh.'
                : 'No past auditions found.',
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AuditionCards(
            auditions: list,
            isPast: !isActive,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required bool isDark, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 52,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF888888),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
