import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  static const List<String> categories = [
    "All",
    "Actor",
    "Film",
    "Dancer",
    "Singer",
    "Model",
    "Voice Artist",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditionsProvider>().fetchAuditions();
    });
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

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();

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

                    const AuditionSearchBar(),

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
                      const AnalyticsCard(),

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
                      else
                        AuditionCards(auditions: auditionsProvider.auditions),

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

                      NewAuditionCard(onPressed: () {}),

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
