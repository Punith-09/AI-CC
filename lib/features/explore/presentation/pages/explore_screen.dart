import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/explore/data/datasource/category_data.dart';
import 'package:aicc/features/explore/presentation/providers/explore_provider.dart';
import 'package:aicc/features/explore/presentation/widgets/explore_appbar.dart';
import 'package:aicc/features/explore/presentation/widgets/talent_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 1; // 0 = filter icon, 1 = All, 2..n = categories

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().fetchExploreUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(int index) {
    setState(() => _selectedCategoryIndex = index);
    final provider = context.read<ExploreProvider>();
    if (index <= 1) {
      // All
      provider.onCategoryChanged('');
    } else {
      provider.onCategoryChanged(categories[index].title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar ──────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ExploreAppbar(),
              ),

              const SizedBox(height: 12),

              // ── Search bar ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: (q) =>
                      context.read<ExploreProvider>().onSearchChanged(q),
                ),
              ),

              const SizedBox(height: 16),

              // ── Category chips ───────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (_, i) => _CategoryChip(
                    category: categories[i],
                    isSelected: _selectedCategoryIndex == i,
                    onTap: () => _onCategoryTap(i),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Section Header: TOP MATCHES NEAR YOU  📍 Mumbai ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOP MATCHES NEAR YOU',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Consumer<ExploreProvider>(
                      builder: (context, provider, _) {
                        return PopupMenuButton<String>(
                          color: const Color(0xFF1A1A2E), // Dark background for the popup menu
                          initialValue: provider.selectedLocation,
                          onSelected: (String newValue) {
                            provider.onLocationChanged(newValue);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (BuildContext context) {
                            return <String>[
                              'Anywhere',
                              'Mumbai',
                              'Delhi',
                              'Bangalore',
                              'Hyderabad',
                              'Chennai',
                              'Pune',
                              'Kolkata',
                              'Ahmedabad',
                              'Surat',
                              'Jaipur',
                              'Ranchi',
                            ].map<PopupMenuItem<String>>((String value) {
                              return PopupMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                color: AppColors.primary,
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                provider.selectedLocation.isEmpty ? 'Anywhere' : provider.selectedLocation,
                                style: GoogleFonts.poppins(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Grid ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<ExploreProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.wifiOff,
                                  color: Colors.white38,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => provider.fetchExploreUsers(),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (provider.talents.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.users,
                                color: Colors.white24,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No talent found',
                                style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return TalentGrid(talents: provider.talents);
                    },
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

// ──────────────────────────────────────────────────────────────────────────────
// Local search bar widget
// ──────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Icon(
            LucideIcons.search,
            color: AppColors.hint,
            size: 20,
          ),
          hintText: 'Search by name, role or skills...',
          hintStyle: GoogleFonts.poppins(
            color: AppColors.hint,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category chip
// ──────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final ExploreCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = category.icon != null && category.title.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: hasIcon ? 12 : 20,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8E3CF7)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E3CF7)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8E3CF7).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: hasIcon
            ? Icon(
                category.icon!,
                color: isSelected ? Colors.white : AppColors.hint,
                size: 18,
              )
            : Text(
                category.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
