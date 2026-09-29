import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../apply_job/presentation/providers/apply_job_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auditions_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/audition_cards.dart';
import '../widgets/audition_chips.dart';
import '../widgets/audition_search_bar.dart';
import '../widgets/new_audition_card.dart';
import '../../data/models/audition_model.dart';

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
    "Film",
    "Ad",
    "Dancer",
    "TV",
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
    context.read<AuditionsProvider>().fetchAuditions(
          category: selectedCategory == 'All' ? null : selectedCategory,
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

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    final applyJobProvider = context.watch<ApplyJobProvider>();
    final appliedCount = applyJobProvider.applications.length;
    final displayedAuditions = _filterAuditions(auditionsProvider.auditions);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final sectionTitleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    final content = Column(
      children: [
        /// Top Section (Non-Scrollable)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Auditions",
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      context.push(AppRoutes.post);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            "Post",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              AuditionSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),

              const SizedBox(height: 18),

              AuditionChips(
                categories: categories,
                selectedIndex: selectedIndex,
                onSelected: _onCategorySelected,
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),

        /// Scrollable Content Below
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AnalyticsCard(appliedCount: appliedCount),

                const SizedBox(height: 24),

                // =======================================================
                // MY POSTED AUDITIONS
                // =======================================================
                if (auditionsProvider.isMyPostedLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (auditionsProvider.myPostedAuditions.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Posted Auditions",
                        style: TextStyle(
                          color: sectionTitleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${auditionsProvider.myPostedAuditions.length}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...auditionsProvider.myPostedAuditions.map((audition) {
                    final applicantsCount = audition.applicantsCount;
                    final loc = audition.location.isNotEmpty ? audition.location : 'Location N/A';
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cardBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
                  }),
                  const SizedBox(height: 20),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top Matches for You",
                      style: TextStyle(
                        color: sectionTitleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (auditionsProvider.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (auditionsProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        auditionsProvider.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                  )
                else if (_searchQuery.trim().isNotEmpty && displayedAuditions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No auditions matching \"$_searchQuery\"",
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text(
                              "Clear search",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AuditionCards(auditions: displayedAuditions),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New Auditions",
                      style: TextStyle(
                        color: sectionTitleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                NewAuditionCard(
                  onPressed: () {
                    context.push(AppRoutes.post);
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: content,
        ),
      ),
    );
  }
}
