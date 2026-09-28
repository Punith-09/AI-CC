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
            isDesktop: isDesktop,
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
              isDesktop: isDesktop,
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
                  color: isDesktop ? const Color(0xFF0F172A) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Consumer<ExploreProvider>(
                builder: (context, provider, _) {
                  return PopupMenuButton<String>(
                    color: isDesktop ? Colors.white : const Color(0xFF1A1A2E),
                    initialValue: provider.selectedLocation,
                    onSelected: (String newValue) {
                      provider.onLocationChanged(newValue);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isDesktop
                          ? const BorderSide(color: Color(0xFFE2E8F0))
                          : BorderSide.none,
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
                              color: isDesktop
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
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
  final bool isDesktop;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDesktop ? Colors.white : const Color(0xFF0D2533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDesktop
              ? const Color(0xFFE2E8F0)
              : AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          color: isDesktop ? const Color(0xFF0F172A) : Colors.white,
          fontSize: 14,
        ),
        cursorColor: isDesktop ? const Color(0xFF8E3CF7) : AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: Icon(
            LucideIcons.search,
            color: isDesktop ? const Color(0xFF94A3B8) : AppColors.hint,
            size: 20,
          ),
          hintText: 'Search by name, role or skills...',
          hintStyle: GoogleFonts.poppins(
            color: isDesktop ? const Color(0xFF94A3B8) : AppColors.hint,
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
  final bool isDesktop;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    this.isDesktop = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = category.icon != null && category.title.isEmpty;

    final unselectedBg = isDesktop
        ? Colors.white
        : Colors.white.withValues(alpha: 0.12);
    final unselectedBorder = isDesktop
        ? const Color(0xFFE2E8F0)
        : Colors.white.withValues(alpha: 0.08);
    final unselectedText = isDesktop
        ? const Color(0xFF475569)
        : Colors.white;

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
              : unselectedBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E3CF7)
                : AppColors.whiteShade,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8E3CF7).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isDesktop
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null),
        ),
        child: hasIcon
            ? Icon(
                category.icon!,
                color: isSelected
                    ? Colors.white
                    : (isDesktop ? const Color(0xFF64748B) : AppColors.hint),
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
