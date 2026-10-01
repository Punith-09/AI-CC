import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../data/models/audition_model.dart';
import '../providers/auditions_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/audition_cards.dart';
import '../widgets/audition_chips.dart';
import '../widgets/audition_search_bar.dart';
import '../widgets/new_audition_card.dart';

class AuditionScreen extends StatefulWidget {
  const AuditionScreen({super.key});

  @override
  State<AuditionScreen> createState() => _AuditionScreenState();
}

class _AuditionScreenState extends State<AuditionScreen> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> categories = [
    "All",
    "Films",
    "Dance",
    "Ads",
    "TV Shows",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditionsProvider>().fetchAuditions();
      context.read<AuditionsProvider>().fetchMyPostedAuditions();
      context.read<ApplyJobProvider>().fetchMyApplications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    final selectedCategory = categories[index];
    String? backendCategory;
    if (selectedCategory == 'Films') {
      backendCategory = 'Film';
    } else if (selectedCategory == 'Dance') {
      backendCategory = 'Dancer';
    } else if (selectedCategory == 'Ads') {
      backendCategory = 'Ad';
    } else if (selectedCategory == 'TV Shows') {
      backendCategory = 'TV';
    }

    context.read<AuditionsProvider>().fetchAuditions(
          category: backendCategory,
        );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<AuditionModel> _filterAuditions(List<AuditionModel> list) {
    if (_searchQuery.trim().isEmpty) {
      return list;
    }
    final q = _searchQuery.toLowerCase().trim();
    return list.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.role.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q) ||
          a.language.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.effectiveContact.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildSectionHeader(String title, Color titleColor, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    final applyJobProvider = context.watch<ApplyJobProvider>();
    final appliedCount = applyJobProvider.applications.length;
    final displayedAuditions = _filterAuditions(auditionsProvider.auditions);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.lightText;
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final subtitleColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    // Build the scrollable content using CustomScrollView for reliable layout
    final scrollView = RefreshIndicator(
      color: const Color(0xFFFF9500),
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
          // ── Fixed Header (title + search + chips) ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Auditions",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Search Bar
                  AuditionSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),

                  const SizedBox(height: 14),

                  // Category Tabs
                  AuditionChips(
                    categories: categories,
                    selectedIndex: selectedIndex,
                    onSelected: _onCategorySelected,
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          // ── Audition Analysis Card ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AnalyticsCard(appliedCount: appliedCount),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── My Posted Auditions ────────────────────────────────────────
          if (auditionsProvider.isMyPostedLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF9500),
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (auditionsProvider.myPostedAuditions.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  "My Posted Auditions",
                  titleColor,
                  trailing: Text(
                    "${auditionsProvider.myPostedAuditions.length}",
                    style: const TextStyle(
                      color: Color(0xFFFF9500),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final audition = auditionsProvider.myPostedAuditions[index];
                    final applicantsCount = audition.applicantsCount;
                    final loc = audition.location.isNotEmpty
                        ? audition.location
                        : 'Location N/A';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.push(
                            AppRoutes.auditionDetails,
                            extra: audition,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audition.title,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "$applicantsCount applicant(s) · $loc",
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: auditionsProvider.myPostedAuditions.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
          ],

          // ── Top Matches Section Header ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader("Top Matches for You", titleColor),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── Top Matches Content ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: auditionsProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF9500),
                        ),
                      ),
                    )
                  : auditionsProvider.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              auditionsProvider.errorMessage!,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 14),
                            ),
                          ),
                        )
                      : _searchQuery.trim().isNotEmpty &&
                              displayedAuditions.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.search_off_rounded,
                                      size: 46,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No auditions matching \"$_searchQuery\"",
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _clearSearch,
                                      child: const Text(
                                        "Clear search",
                                        style: TextStyle(
                                          color: Color(0xFFFF9500),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : AuditionCards(auditions: displayedAuditions),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── New Auditions Section ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader("New Auditions", titleColor),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: NewAuditionCard(
                onPressed: () {
                  context.push(AppRoutes.post);
                },
              ),
            ),
          ),

          // Bottom spacing (accounts for bottom nav bar)
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: scrollView,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: scrollView,
        ),
      ),
    );
  }
}
