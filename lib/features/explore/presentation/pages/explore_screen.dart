import 'package:aicc/common/widgets/app_background.dart';
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

  void _showSortBottomSheet(BuildContext context) {
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
                    // Drag handle
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

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final provider = context.read<ExploreProvider>();

            // Local state mirrors
            String dept = provider.filterDepartment;
            String gender = provider.filterGender;
            String ageFrom = provider.filterAgeFrom;
            String ageTo = provider.filterAgeTo;
            String state = provider.filterState;
            String city = provider.filterCity;
            String languages = provider.filterLanguages;
            String categories = provider.filterCategories;
            String skills = provider.filterSkills;
            String heightFrom = provider.filterHeightFrom;
            String heightTo = provider.filterHeightTo;
            String role = provider.filterRole;
            String projectType = provider.filterProjectType;

            Widget dropdownField(
              String label,
              String value,
              List<String> options,
              void Function(String) onChanged,
            ) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: borderColor),
                  color: bgColor,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isEmpty ? null : value,
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: hintColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: hintColor),
                    ),
                    dropdownColor: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    items: options.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            opt,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() {
                          onChanged(v);
                        });
                      }
                    },
                    selectedItemBuilder: (context) {
                      return options.map((opt) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              opt,
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              );
            }

            Widget textField(
              String label,
              String value,
              void Function(String) onChanged,
            ) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: borderColor),
                  color: bgColor,
                ),
                child: TextField(
                  controller: TextEditingController(text: value)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    ),
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
                  ),
                  onChanged: onChanged,
                ),
              );
            }

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
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            dropdownField(
                              'Department',
                              dept,
                              ['Acting', 'Dancing', 'Singing', 'Direction', 'Cinematography', 'Editing', 'Music', 'Stunts', 'Makeup', 'Costumes', 'Production'],
                              (v) => dept = v,
                            ),
                            dropdownField(
                              'Gender',
                              gender,
                              ['Male', 'Female', 'Other'],
                              (v) => gender = v,
                            ),
                            textField('From Age', ageFrom, (v) => ageFrom = v),
                            textField('To Age', ageTo, (v) => ageTo = v),
                            dropdownField(
                              'Present State',
                              state,
                              ['Andhra Pradesh', 'Karnataka', 'Maharashtra', 'Tamil Nadu', 'Telangana', 'Delhi', 'Uttar Pradesh', 'Gujarat', 'Rajasthan', 'West Bengal', 'Kerala', 'Odisha', 'Punjab', 'Haryana', 'Bihar', 'Madhya Pradesh'],
                              (v) => state = v,
                            ),
                            dropdownField(
                              'Present City',
                              city,
                              ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Kolkata', 'Ahmedabad', 'Surat', 'Jaipur', 'Ranchi', 'Lucknow', 'Coimbatore', 'Kochi'],
                              (v) => city = v,
                            ),
                            dropdownField(
                              'Languages',
                              languages,
                              ['Hindi', 'English', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Bengali', 'Marathi', 'Gujarati', 'Punjabi', 'Odia', 'Urdu'],
                              (v) => languages = v,
                            ),
                            dropdownField(
                              'Categories',
                              categories,
                              ['Film', 'Television', 'Web Series', 'Short Film', 'Theatre', 'Music Video', 'Advertisement', 'Documentary'],
                              (v) => categories = v,
                            ),
                            dropdownField(
                              'Skills',
                              skills,
                              ['Acting', 'Dancing', 'Singing', 'Martial Arts', 'Horse Riding', 'Swimming', 'Gymnastics', 'Mimicry', 'Comedy'],
                              (v) => skills = v,
                            ),
                            dropdownField(
                              'From Height',
                              heightFrom,
                              ['4.0 ft', '4.5 ft', '5.0 ft', '5.1 ft', '5.2 ft', '5.3 ft', '5.4 ft', '5.5 ft', '5.6 ft', '5.7 ft', '5.8 ft', '5.9 ft', '6.0 ft', '6.1 ft', '6.2 ft'],
                              (v) => heightFrom = v,
                            ),
                            dropdownField(
                              'To Height',
                              heightTo,
                              ['4.0 ft', '4.5 ft', '5.0 ft', '5.1 ft', '5.2 ft', '5.3 ft', '5.4 ft', '5.5 ft', '5.6 ft', '5.7 ft', '5.8 ft', '5.9 ft', '6.0 ft', '6.1 ft', '6.2 ft'],
                              (v) => heightTo = v,
                            ),
                            dropdownField(
                              'Role',
                              role,
                              ['Lead', 'Supporting', 'Character', 'Cameo', 'Extra / Junior Artist'],
                              (v) => role = v,
                            ),
                            dropdownField(
                              'Project Type',
                              projectType,
                              ['Film', 'Short Film', 'Web Series', 'Television', 'Advertisement', 'Music Video', 'Theatre', 'OTT'],
                              (v) => projectType = v,
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
                            provider.filterDepartment = dept;
                            provider.filterGender = gender;
                            provider.filterAgeFrom = ageFrom;
                            provider.filterAgeTo = ageTo;
                            provider.filterState = state;
                            provider.filterCity = city;
                            provider.filterLanguages = languages;
                            provider.filterCategories = categories;
                            provider.filterSkills = skills;
                            provider.filterHeightFrom = heightFrom;
                            provider.filterHeightTo = heightTo;
                            provider.filterRole = role;
                            provider.filterProjectType = projectType;
                            Navigator.pop(sheetContext);
                            provider.fetchExploreUsers();
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
          },
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

        const SizedBox(height: 18),

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

        // ── Bottom Sort / Filter Bar ──────────────────────────
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
