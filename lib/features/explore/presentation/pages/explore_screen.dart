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
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final popupMenuColor = isDark ? AppColors.darkCard : Colors.white;
    final popupMenuBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── App Bar (Mobile only) ────────────────────────────
        if (!isDesktop) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ExploreAppbar(),
          ),
          const SizedBox(height: 12),
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
              isDark: isDark,
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
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
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
                          Icon(
                            LucideIcons.wifiOff,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No talent found',
                          style: GoogleFonts.poppins(
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
// Local search bar widget
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
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkTextField : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          color: isDark ? AppColors.darkText : AppColors.lightText,
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
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
            size: 20,
          ),
          hintText: 'Search by name, role or skills...',
          hintStyle: GoogleFonts.poppins(
            color: isDark ? AppColors.darkTextSecondary : AppColors.hint,
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
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    this.isDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = category.icon != null && category.title.isEmpty;

    final unselectedBg = isDark ? AppColors.darkCard : Colors.white;
    final unselectedBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final unselectedText = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);
    final unselectedIconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

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
              ? AppColors.buttonPrimary
              : unselectedBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonPrimary
                : unselectedBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.buttonPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: hasIcon
            ? Icon(
                category.icon!,
                color: isSelected ? Colors.white : unselectedIconColor,
                size: 18,
              )
            : Text(
                category.title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : unselectedText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
