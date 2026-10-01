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
import '../../../../core/responsive/responsive_breakpoints.dart';

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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final popupMenuColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final popupMenuBorder = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E8F0);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── App Bar (Mobile only) ────────────────────────────
        if (!isDesktop) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ExploreAppbar(),
          ),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 16),

        // ── Search bar ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchBar(
            controller: _searchController,
            isDark: isDark,
            onChanged: (q) =>
                context.read<ExploreProvider>().onSearchChanged(q),
          ),
        ),

        const SizedBox(height: 18),

        // ── Category tabs (text-based, underline for selected) ──
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 24),
            itemBuilder: (_, i) {
              // Skip the filter icon (index 0) — we hide it to match the mockup
              if (i == 0) return const SizedBox.shrink();
              return _CategoryTab(
                category: categories[i],
                isSelected: _selectedCategoryIndex == i,
                isDark: isDark,
                onTap: () => _onCategoryTap(i),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── Section Header: Top Matches Near You  📍 Select Location ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Matches Near You',
                style: GoogleFonts.poppins(
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              Consumer<ExploreProvider>(
                builder: (context, provider, _) {
                  return PopupMenuButton<String>(
                    color: popupMenuColor,
                    initialValue: provider.selectedLocation,
                    onSelected: (String newValue) {
                      provider.onLocationChanged(newValue);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: popupMenuBorder),
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
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.selectedLocation.isEmpty
                              ? 'Select Location'
                              : provider.selectedLocation,
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 12,
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

        // ── List ─────────────────────────────────────────────
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
                          Icon(
                            LucideIcons.wifiOff,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF94A3B8),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF64748B),
                            ),
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
                        Icon(
                          LucideIcons.users,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No talent found',
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF64748B),
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
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: content,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Search bar
// ──────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E8F0);
    final iconColor = isDark ? const Color(0xFF8A8A8E) : const Color(0xFF94A3B8);
    final hintColor = isDark ? const Color(0xFF8A8A8E) : const Color(0xFF9CA3AF);
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 14,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: Icon(
            LucideIcons.search,
            color: iconColor,
            size: 20,
          ),
          hintText: 'Search by name, role, skills....',
          hintStyle: GoogleFonts.poppins(
            color: hintColor,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category tab (text + underline indicator)
// ──────────────────────────────────────────────────────────────────────────────
class _CategoryTab extends StatelessWidget {
  final ExploreCategory category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.isSelected,
    this.isDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.primary;
    final unselectedColor = isDark ? const Color(0xFF8A8A8E) : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.title,
            style: GoogleFonts.poppins(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
