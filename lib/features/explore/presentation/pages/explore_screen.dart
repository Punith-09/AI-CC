import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/explore/data/datasource/talents_data.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:aicc/features/explore/presentation/widgets/category_chips.dart';
import 'package:aicc/features/explore/presentation/widgets/explore_appbar.dart';
import 'package:aicc/features/explore/presentation/widgets/explore_search_bar.dart';
import 'package:aicc/features/explore/presentation/widgets/floating_filter_bar.dart';
import 'package:aicc/features/explore/presentation/widgets/section_header.dart';
import 'package:aicc/features/explore/presentation/widgets/talent_grid.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int selectedCategory = 1;

  List<TalentModel> get filteredTalents {
    switch (selectedCategory) {
      case 1:
        return talents;

      case 2:
        return talents
            .where((e) => e.role.toLowerCase() == "actor")
            .toList();

      case 3:
        return talents
            .where((e) => e.role.toLowerCase() == "model")
            .toList();

      case 4:
        return talents
            .where((e) => e.role.toLowerCase() == "singer")
            .toList();

      default:
        return talents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const ExploreAppbar(),

                    const SizedBox(height: 20),

                    const ExploreSearchBar(),

                    const SizedBox(height: 20),

                    CategoryChips(
                      selectedIndex: selectedCategory,
                      onSelected: (index) {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const SectionHeader(),

                    const SizedBox(height: 20),

                    Expanded(
                      child: TalentGrid(
                        talents: filteredTalents,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const FloatingFilterBar(),
        ],
      ),
    );
  }
}
