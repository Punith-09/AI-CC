import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/craft_constants.dart';
import 'package:aicc/features/explore/presentation/providers/explore_provider.dart';
import 'package:aicc/features/explore/presentation/widgets/explore_appbar.dart';
import 'package:aicc/features/explore/presentation/widgets/talent_card.dart';
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

  // ── Sort: bottom sheet on mobile, popup dialog on desktop ──────────────────
  void _showSortBottomSheet(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    if (isDesktop) {
      _showSortPopup(context);
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final dividerColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer<ExploreProvider>(
          builder: (ctx, provider, _) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sort By',
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: dividerColor, height: 1),
                    ..._buildSortOption(
                      context,
                      sheetContext,
                      provider,
                      label: 'First to Last',
                      option: ExploreSortOption.firstToLast,
                      isDark: isDark,
                      textColor: textColor,
                      dividerColor: dividerColor,
                    ),
                    ..._buildSortOption(
                      context,
                      sheetContext,
                      provider,
                      label: 'Last to First',
                      option: ExploreSortOption.lastToFirst,
                      isDark: isDark,
                      textColor: textColor,
                      dividerColor: dividerColor,
                    ),
                    ..._buildSortOption(
                      context,
                      sheetContext,
                      provider,
                      label: 'Name (A to Z)',
                      option: ExploreSortOption.nameAtoZ,
                      isDark: isDark,
                      textColor: textColor,
                      dividerColor: dividerColor,
                    ),
                    ..._buildSortOption(
                      context,
                      sheetContext,
                      provider,
                      label: 'Name (Z to A)',
                      option: ExploreSortOption.nameZtoA,
                      isDark: isDark,
                      textColor: textColor,
                      dividerColor: dividerColor,
                      isLast: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Desktop-only: compact centered dialog for Sort
  void _showSortPopup(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final dividerColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E8F0);
    final provider = context.read<ExploreProvider>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void selectOption(ExploreSortOption option) {
              provider.onSortChanged(option);
              setDialogState(() {});
              Navigator.pop(dialogCtx);
            }

            Widget optionRow(String label, ExploreSortOption option) {
              final isSelected = provider.sortOption == option;
              return InkWell(
                onTap: () => selectOption(option),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: isSelected ? AppColors.primary : textColor,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? Colors.white38 : Colors.black26),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 340,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort By',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogCtx),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: isDark ? Colors.white70 : AppColors.lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: dividerColor, height: 1),
                    optionRow('First to Last', ExploreSortOption.firstToLast),
                    Divider(color: dividerColor, height: 1, indent: 20, endIndent: 20),
                    optionRow('Last to First', ExploreSortOption.lastToFirst),
                    Divider(color: dividerColor, height: 1, indent: 20, endIndent: 20),
                    optionRow('Name (A to Z)', ExploreSortOption.nameAtoZ),
                    Divider(color: dividerColor, height: 1, indent: 20, endIndent: 20),
                    optionRow('Name (Z to A)', ExploreSortOption.nameZtoA),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSortOption(
    BuildContext context,
    BuildContext sheetContext,
    ExploreProvider provider, {
    required String label,
    required ExploreSortOption option,
    required bool isDark,
    required Color textColor,
    required Color dividerColor,
    bool isLast = false,
  }) {
    final isSelected = provider.sortOption == option;
    return [
      InkWell(
        onTap: () {
          provider.onSortChanged(option);
          Navigator.pop(sheetContext);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white38 : Colors.black26),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
      if (!isLast) Divider(color: dividerColor, height: 1, indent: 24, endIndent: 24),
    ];
  }

  // ── Filter: bottom sheet on mobile, dialog on desktop ───────────────────────
  void _showFilterBottomSheet(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    if (isDesktop) {
      _showFilterDialog(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _FilterBottomSheet(
          provider: context.read<ExploreProvider>(),
        );
      },
    );
  }

  /// Desktop-only: full-featured filter dialog in a centered popup
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogCtx) {
        return _FilterDialog(
          provider: context.read<ExploreProvider>(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;

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

        // ── Active Filters Row ───────────────────────────────
        Consumer<ExploreProvider>(
          builder: (context, provider, _) {
            if (!provider.hasActiveFilters) {
              return const SizedBox(height: 18);
            }

            final chips = <Widget>[];

            void addChip(String label, VoidCallback onRemove) {
              chips.add(
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.filterDepartment.isNotEmpty) {
              addChip('Dept: ${provider.filterDepartment}', () {
                provider.filterDepartment = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterGender.isNotEmpty) {
              addChip(provider.filterGender, () {
                provider.filterGender = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterAgeFrom.isNotEmpty || provider.filterAgeTo.isNotEmpty) {
              final ageLabel =
                  'Age: ${provider.filterAgeFrom.isNotEmpty ? provider.filterAgeFrom : '0'}-${provider.filterAgeTo.isNotEmpty ? provider.filterAgeTo : 'Any'}';
              addChip(ageLabel, () {
                provider.filterAgeFrom = '';
                provider.filterAgeTo = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterState.isNotEmpty) {
              addChip(provider.filterState, () {
                provider.filterState = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterCity.isNotEmpty) {
              addChip(provider.filterCity, () {
                provider.filterCity = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterLanguages.isNotEmpty) {
              addChip(provider.filterLanguages, () {
                provider.filterLanguages = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterCategories.isNotEmpty) {
              addChip(provider.filterCategories, () {
                provider.filterCategories = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterSkills.isNotEmpty) {
              addChip(provider.filterSkills, () {
                provider.filterSkills = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterHeightFrom.isNotEmpty || provider.filterHeightTo.isNotEmpty) {
              final htLabel =
                  'Height: ${provider.filterHeightFrom.isNotEmpty ? provider.filterHeightFrom : 'Any'}-${provider.filterHeightTo.isNotEmpty ? provider.filterHeightTo : 'Any'}';
              addChip(htLabel, () {
                provider.filterHeightFrom = '';
                provider.filterHeightTo = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterRole.isNotEmpty) {
              addChip('Role: ${provider.filterRole}', () {
                provider.filterRole = '';
                provider.fetchExploreUsers();
              });
            }
            if (provider.filterProjectType.isNotEmpty) {
              addChip(provider.filterProjectType, () {
                provider.filterProjectType = '';
                provider.fetchExploreUsers();
              });
            }

            chips.add(
              GestureDetector(
                onTap: () => provider.clearFilters(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: chips),
              ),
            );
          },
        ),

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
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sort & Filter buttons – desktop only, inline with header
                      if (isDesktop) ...[
                        _DesktopHeaderButton(
                          label: 'Sort',
                          icon: LucideIcons.arrowUpDown,
                          isDark: isDark,
                          onTap: () => _showSortBottomSheet(context),
                        ),
                        const SizedBox(width: 8),
                        _DesktopHeaderButton(
                          label: provider.hasActiveFilters ? 'Filter ✓' : 'Filter',
                          icon: LucideIcons.slidersHorizontal,
                          isDark: isDark,
                          isActive: provider.hasActiveFilters,
                          onTap: () => _showFilterBottomSheet(context),
                        ),
                        const SizedBox(width: 12),
                      ],
                      PopupMenuButton<String>(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        initialValue: provider.selectedLocation,
                        onSelected: (String newValue) {
                          provider.onLocationChanged(newValue);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFE2E8F0),
                          ),
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
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
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
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── List / Grid ───────────────────────────────────────
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

                // Desktop: 3-column grid
                if (isDesktop) {
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: provider.talents.length,
                    itemBuilder: (context, index) {
                      return TalentCard(talent: provider.talents[index]);
                    },
                  );
                }

                // Mobile: original list
                return ListView.builder(
                  itemCount: provider.talents.length,
                  itemBuilder: (context, index) {
                    return TalentCard(talent: provider.talents[index]);
                  },
                );
              },
            ),
          ),
        ),

        // ── Bottom Sort / Filter Bar (mobile only) ────────────
        if (!isDesktop)
          Consumer<ExploreProvider>(
            builder: (context, provider, _) {
              final hasFilters = provider.hasActiveFilters;
              final borderTop = isDark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFE5E7EB);
              final barBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

              return Container(
                decoration: BoxDecoration(
                  color: barBg,
                  border: Border(
                    top: BorderSide(color: borderTop, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Sort button
                    Expanded(
                      child: InkWell(
                        onTap: () => _showSortBottomSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              'Sort',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white70 : AppColors.lightText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 1,
                      height: 32,
                      color: borderTop,
                    ),
                    // Filter button
                    Expanded(
                      child: InkWell(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              hasFilters ? 'Filter ✓' : 'Filter',
                              style: GoogleFonts.poppins(
                                color: hasFilters
                                    ? AppColors.primary
                                    : (isDark ? Colors.white70 : AppColors.lightText),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
// Desktop header sort/filter button (inline pill button)
// ──────────────────────────────────────────────────────────────────────────────
class _DesktopHeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;

  const _DesktopHeaderButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? AppColors.primary.withValues(alpha: 0.12)
        : (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9));
    final border = isActive
        ? AppColors.primary.withValues(alpha: 0.5)
        : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E8F0));
    final textColor = isActive
        ? AppColors.primary
        : (isDark ? Colors.white70 : AppColors.lightText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Desktop Filter Dialog (Popup)
// ──────────────────────────────────────────────────────────────────────────────
class _FilterDialog extends StatefulWidget {
  final ExploreProvider provider;

  const _FilterDialog({required this.provider});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _dept;
  late String _gender;
  late final TextEditingController _ageFromCtrl;
  late final TextEditingController _ageToCtrl;
  late String _state;
  late String _city;
  late String _languages;
  late String _categories;
  late String _skills;
  late String _heightFrom;
  late String _heightTo;
  late String _role;
  late String _projectType;

  // Options
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _stateOptions = [
    'Andhra Pradesh',
    'Karnataka',
    'Maharashtra',
    'Tamil Nadu',
    'Telangana',
    'Delhi',
    'Uttar Pradesh',
    'Gujarat',
    'Rajasthan',
    'West Bengal',
    'Kerala',
    'Odisha',
    'Punjab',
    'Haryana',
    'Bihar',
    'Madhya Pradesh',
  ];
  static const List<String> _cityOptions = [
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
    'Lucknow',
    'Coimbatore',
    'Kochi',
  ];
  static const List<String> _languageOptions = [
    'Hindi',
    'English',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Odia',
    'Urdu',
  ];
  static const List<String> _categoryOptions = [
    'Film',
    'Television',
    'Web Series',
    'Short Film',
    'Theatre',
    'Music Video',
    'Advertisement',
    'Documentary',
  ];
  static const List<String> _skillOptions = [
    'Acting',
    'Dancing',
    'Singing',
    'Martial Arts',
    'Horse Riding',
    'Swimming',
    'Gymnastics',
    'Mimicry',
    'Comedy',
  ];
  static const List<String> _heightOptions = [
    '4.0 ft',
    '4.5 ft',
    '5.0 ft',
    '5.1 ft',
    '5.2 ft',
    '5.3 ft',
    '5.4 ft',
    '5.5 ft',
    '5.6 ft',
    '5.7 ft',
    '5.8 ft',
    '5.9 ft',
    '6.0 ft',
    '6.1 ft',
    '6.2 ft',
  ];
  static const List<String> _roleOptions = [
    'Lead',
    'Supporting',
    'Character',
    'Cameo',
    'Extra / Junior Artist',
  ];
  static const List<String> _projectTypeOptions = [
    'Film',
    'Short Film',
    'Web Series',
    'Television',
    'Advertisement',
    'Music Video',
    'Theatre',
    'OTT',
  ];

  @override
  void initState() {
    super.initState();
    _dept = widget.provider.filterDepartment;
    _gender = widget.provider.filterGender;
    _ageFromCtrl = TextEditingController(text: widget.provider.filterAgeFrom);
    _ageToCtrl = TextEditingController(text: widget.provider.filterAgeTo);
    _state = widget.provider.filterState;
    _city = widget.provider.filterCity;
    _languages = widget.provider.filterLanguages;
    _categories = widget.provider.filterCategories;
    _skills = widget.provider.filterSkills;
    _heightFrom = widget.provider.filterHeightFrom;
    _heightTo = widget.provider.filterHeightTo;
    _role = widget.provider.filterRole;
    _projectType = widget.provider.filterProjectType;
  }

  @override
  void dispose() {
    _ageFromCtrl.dispose();
    _ageToCtrl.dispose();
    super.dispose();
  }

  bool get _hasAnyFilter =>
      _dept.isNotEmpty ||
      _gender.isNotEmpty ||
      _ageFromCtrl.text.isNotEmpty ||
      _ageToCtrl.text.isNotEmpty ||
      _state.isNotEmpty ||
      _city.isNotEmpty ||
      _languages.isNotEmpty ||
      _categories.isNotEmpty ||
      _skills.isNotEmpty ||
      _heightFrom.isNotEmpty ||
      _heightTo.isNotEmpty ||
      _role.isNotEmpty ||
      _projectType.isNotEmpty;

  void _resetLocalFilters() {
    setState(() {
      _dept = '';
      _gender = '';
      _ageFromCtrl.clear();
      _ageToCtrl.clear();
      _state = '';
      _city = '';
      _languages = '';
      _categories = '';
      _skills = '';
      _heightFrom = '';
      _heightTo = '';
      _role = '';
      _projectType = '';
    });
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    final hasValue = value.isNotEmpty && options.contains(value);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? AppColors.primary.withValues(alpha: 0.7) : borderColor,
          width: hasValue ? 1.5 : 1.0,
        ),
        color: bgColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: hasValue ? value : null,
                hint: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: hintColor,
                    fontSize: 13.5,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hintColor,
                  size: 20,
                ),
                dropdownColor: bgColor,
                borderRadius: BorderRadius.circular(12),
                items: options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight:
                            opt == value ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (hasValue)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(null),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: hintColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        color: bgColor,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(color: textColor, fontSize: 13.5),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            color: hintColor,
            fontSize: 13.5,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, val, _) {
              if (val.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded, size: 16, color: hintColor),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final inputBgColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final hintColor = isDark ? Colors.white38 : Colors.black45;
    final dividerColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 620,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Dialog Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 14),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_hasAnyFilter)
                    GestureDetector(
                      onTap: _resetLocalFilters,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isDark ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: dividerColor, height: 1),

            // ── Dialog Scrollable Form (Two Column Grid) ─────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                child: Column(
                  children: [
                    // Row 1: Department & Gender
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Department',
                            value: _dept,
                            options: kFilmCrafts,
                            onChanged: (v) => setState(() => _dept = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Gender',
                            value: _gender,
                            options: _genderOptions,
                            onChanged: (v) => setState(() => _gender = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: From Age & To Age
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'From Age',
                            controller: _ageFromCtrl,
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildTextField(
                            label: 'To Age',
                            controller: _ageToCtrl,
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Present State & Present City
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Present State',
                            value: _state,
                            options: _stateOptions,
                            onChanged: (v) => setState(() => _state = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Present City',
                            value: _city,
                            options: _cityOptions,
                            onChanged: (v) => setState(() => _city = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 4: Languages & Categories
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Languages',
                            value: _languages,
                            options: _languageOptions,
                            onChanged: (v) => setState(() => _languages = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Categories',
                            value: _categories,
                            options: _categoryOptions,
                            onChanged: (v) => setState(() => _categories = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 5: Skills & Role
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Skills',
                            value: _skills,
                            options: _skillOptions,
                            onChanged: (v) => setState(() => _skills = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Role',
                            value: _role,
                            options: _roleOptions,
                            onChanged: (v) => setState(() => _role = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 6: From Height & To Height
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'From Height',
                            value: _heightFrom,
                            options: _heightOptions,
                            onChanged: (v) => setState(() => _heightFrom = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'To Height',
                            value: _heightTo,
                            options: _heightOptions,
                            onChanged: (v) => setState(() => _heightTo = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 7: Project Type
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Project Type',
                            value: _projectType,
                            options: _projectTypeOptions,
                            onChanged: (v) => setState(() => _projectType = v ?? ''),
                            bgColor: inputBgColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            hintColor: hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: dividerColor, height: 1),

            // ── Dialog Footer Action Buttons ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.provider.filterDepartment = _dept;
                        widget.provider.filterGender = _gender;
                        widget.provider.filterAgeFrom = _ageFromCtrl.text.trim();
                        widget.provider.filterAgeTo = _ageToCtrl.text.trim();
                        widget.provider.filterState = _state;
                        widget.provider.filterCity = _city;
                        widget.provider.filterLanguages = _languages;
                        widget.provider.filterCategories = _categories;
                        widget.provider.filterSkills = _skills;
                        widget.provider.filterHeightFrom = _heightFrom;
                        widget.provider.filterHeightTo = _heightTo;
                        widget.provider.filterRole = _role;
                        widget.provider.filterProjectType = _projectType;
                        Navigator.pop(context);
                        widget.provider.fetchExploreUsers();
                      },
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Filter bottom sheet
// ──────────────────────────────────────────────────────────────────────────────
class _FilterBottomSheet extends StatefulWidget {
  final ExploreProvider provider;

  const _FilterBottomSheet({required this.provider});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _dept;
  late String _gender;
  late final TextEditingController _ageFromCtrl;
  late final TextEditingController _ageToCtrl;
  late String _state;
  late String _city;
  late String _languages;
  late String _categories;
  late String _skills;
  late String _heightFrom;
  late String _heightTo;
  late String _role;
  late String _projectType;

  // Options
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _stateOptions = [
    'Andhra Pradesh',
    'Karnataka',
    'Maharashtra',
    'Tamil Nadu',
    'Telangana',
    'Delhi',
    'Uttar Pradesh',
    'Gujarat',
    'Rajasthan',
    'West Bengal',
    'Kerala',
    'Odisha',
    'Punjab',
    'Haryana',
    'Bihar',
    'Madhya Pradesh',
  ];
  static const List<String> _cityOptions = [
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
    'Lucknow',
    'Coimbatore',
    'Kochi',
  ];
  static const List<String> _languageOptions = [
    'Hindi',
    'English',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Odia',
    'Urdu',
  ];
  static const List<String> _categoryOptions = [
    'Film',
    'Television',
    'Web Series',
    'Short Film',
    'Theatre',
    'Music Video',
    'Advertisement',
    'Documentary',
  ];
  static const List<String> _skillOptions = [
    'Acting',
    'Dancing',
    'Singing',
    'Martial Arts',
    'Horse Riding',
    'Swimming',
    'Gymnastics',
    'Mimicry',
    'Comedy',
  ];
  static const List<String> _heightOptions = [
    '4.0 ft',
    '4.5 ft',
    '5.0 ft',
    '5.1 ft',
    '5.2 ft',
    '5.3 ft',
    '5.4 ft',
    '5.5 ft',
    '5.6 ft',
    '5.7 ft',
    '5.8 ft',
    '5.9 ft',
    '6.0 ft',
    '6.1 ft',
    '6.2 ft',
  ];
  static const List<String> _roleOptions = [
    'Lead',
    'Supporting',
    'Character',
    'Cameo',
    'Extra / Junior Artist',
  ];
  static const List<String> _projectTypeOptions = [
    'Film',
    'Short Film',
    'Web Series',
    'Television',
    'Advertisement',
    'Music Video',
    'Theatre',
    'OTT',
  ];

  @override
  void initState() {
    super.initState();
    _dept = widget.provider.filterDepartment;
    _gender = widget.provider.filterGender;
    _ageFromCtrl = TextEditingController(text: widget.provider.filterAgeFrom);
    _ageToCtrl = TextEditingController(text: widget.provider.filterAgeTo);
    _state = widget.provider.filterState;
    _city = widget.provider.filterCity;
    _languages = widget.provider.filterLanguages;
    _categories = widget.provider.filterCategories;
    _skills = widget.provider.filterSkills;
    _heightFrom = widget.provider.filterHeightFrom;
    _heightTo = widget.provider.filterHeightTo;
    _role = widget.provider.filterRole;
    _projectType = widget.provider.filterProjectType;
  }

  @override
  void dispose() {
    _ageFromCtrl.dispose();
    _ageToCtrl.dispose();
    super.dispose();
  }

  bool get _hasAnyFilter =>
      _dept.isNotEmpty ||
      _gender.isNotEmpty ||
      _ageFromCtrl.text.isNotEmpty ||
      _ageToCtrl.text.isNotEmpty ||
      _state.isNotEmpty ||
      _city.isNotEmpty ||
      _languages.isNotEmpty ||
      _categories.isNotEmpty ||
      _skills.isNotEmpty ||
      _heightFrom.isNotEmpty ||
      _heightTo.isNotEmpty ||
      _role.isNotEmpty ||
      _projectType.isNotEmpty;

  void _resetLocalFilters() {
    setState(() {
      _dept = '';
      _gender = '';
      _ageFromCtrl.clear();
      _ageToCtrl.clear();
      _state = '';
      _city = '';
      _languages = '';
      _categories = '';
      _skills = '';
      _heightFrom = '';
      _heightTo = '';
      _role = '';
      _projectType = '';
    });
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    final hasValue = value.isNotEmpty && options.contains(value);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: hasValue ? AppColors.primary.withValues(alpha: 0.7) : borderColor,
          width: hasValue ? 1.5 : 1.0,
        ),
        color: bgColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: hasValue ? value : null,
                hint: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: hintColor,
                    fontSize: 14,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hintColor,
                ),
                dropdownColor: bgColor,
                borderRadius: BorderRadius.circular(16),
                items: options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 14,
                        fontWeight:
                            opt == value ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (hasValue)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(null),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: hintColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor),
        color: bgColor,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(color: textColor, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            color: hintColor,
            fontSize: 14,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, val, _) {
              if (val.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.close_rounded, size: 18, color: hintColor),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_hasAnyFilter)
                    GestureDetector(
                      onTap: _resetLocalFilters,
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDropdownField(
                      label: 'Department',
                      value: _dept,
                      options: kFilmCrafts,
                      onChanged: (v) => setState(() => _dept = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Gender',
                      value: _gender,
                      options: _genderOptions,
                      onChanged: (v) => setState(() => _gender = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildTextField(
                      label: 'From Age',
                      controller: _ageFromCtrl,
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildTextField(
                      label: 'To Age',
                      controller: _ageToCtrl,
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Present State',
                      value: _state,
                      options: _stateOptions,
                      onChanged: (v) => setState(() => _state = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Present City',
                      value: _city,
                      options: _cityOptions,
                      onChanged: (v) => setState(() => _city = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Languages',
                      value: _languages,
                      options: _languageOptions,
                      onChanged: (v) => setState(() => _languages = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Categories',
                      value: _categories,
                      options: _categoryOptions,
                      onChanged: (v) => setState(() => _categories = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Skills',
                      value: _skills,
                      options: _skillOptions,
                      onChanged: (v) => setState(() => _skills = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'From Height',
                      value: _heightFrom,
                      options: _heightOptions,
                      onChanged: (v) => setState(() => _heightFrom = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'To Height',
                      value: _heightTo,
                      options: _heightOptions,
                      onChanged: (v) => setState(() => _heightTo = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Role',
                      value: _role,
                      options: _roleOptions,
                      onChanged: (v) => setState(() => _role = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    _buildDropdownField(
                      label: 'Project Type',
                      value: _projectType,
                      options: _projectTypeOptions,
                      onChanged: (v) => setState(() => _projectType = v ?? ''),
                      bgColor: bgColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: hintColor,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.provider.filterDepartment = _dept;
                    widget.provider.filterGender = _gender;
                    widget.provider.filterAgeFrom = _ageFromCtrl.text.trim();
                    widget.provider.filterAgeTo = _ageToCtrl.text.trim();
                    widget.provider.filterState = _state;
                    widget.provider.filterCity = _city;
                    widget.provider.filterLanguages = _languages;
                    widget.provider.filterCategories = _categories;
                    widget.provider.filterSkills = _skills;
                    widget.provider.filterHeightFrom = _heightFrom;
                    widget.provider.filterHeightTo = _heightTo;
                    widget.provider.filterRole = _role;
                    widget.provider.filterProjectType = _projectType;
                    Navigator.pop(context);
                    widget.provider.fetchExploreUsers();
                  },
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
