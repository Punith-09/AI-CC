import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apply_job/presentation/providers/apply_job_provider.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1F5A6A),
              Color(0xFF123B4A),
              Color(0xFF0B1F2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
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
                        const Text(
                          "AI Recommendations",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 20,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Top Matches for You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "View All",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (auditionsProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
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
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: Colors.white38,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No auditions matching \"$_searchQuery\"",
                                  style: const TextStyle(
                                    color: Colors.white70,
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
                                      color: Color(0xFF4AD0FB),
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
                        children: const [
                          Text(
                            "New Auditions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "View All",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
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
          ),
        ),
      ),
    );
  }
}
