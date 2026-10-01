import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/core/theme/theme_provider.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/portfolio_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../presentation/providers/profile_provider.dart';
import 'package:aicc/core/api/api_endpoints.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String? userId;
  const ArtistProfileScreen({super.key, this.userId});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        context.read<ProfileProvider>().fetchUserProfile(widget.userId!);
      } else {
        context.read<ProfileProvider>().fetchMyProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    // Capture everything from context BEFORE any await
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final router = GoRouter.of(context);

    // ── Confirmation dialog ─────────────────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final bgColor =
            isDark ? const Color(0xFF1A1A1A) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subColor =
            isDark ? Colors.white60 : Colors.black54;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.5 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.redAccent
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: subColor, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext)
                                .pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFD1D5DB),
                          ),
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logout confirm
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext)
                                .pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    // ── Perform logout ──────────────────────────────────────
    try {
      await authProvider.logout();
      profileProvider.clear();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      if (mounted) {
        router.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    final content = Consumer2<ProfileProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (provider.error != null) {
          return _buildErrorState(provider, isDark);
        }

        final profile = widget.userId != null
            ? provider.viewedProfile
            : provider.currentProfile;
        final mediaList =
            widget.userId != null ? provider.viewedMedia : provider.myMedia;

        return _buildProfileContent(
          context: context,
          profile: profile,
          mediaList: mediaList,
          isDark: isDark,
          themeProvider: themeProvider,
        );
      },
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: content,
          ),
        ),
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

  Widget _buildProfileContent({
    required BuildContext context,
    required ArtistModel? profile,
    required List<PortfolioModel> mediaList,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    // Build name parts
    final fullName = profile?.name ?? '';

    // Location
    String location = '';
    if (profile?.city != null && profile!.city.isNotEmpty) {
      location = profile.city;
      if (profile.state.isNotEmpty) location += ', ${profile.state}';
    } else if (profile?.state != null && profile!.state.isNotEmpty) {
      location = profile.state;
    }
    if (location.isEmpty) location = 'India';

    // Role
    final role = profile?.roles.isNotEmpty == true
        ? profile!.roles.first
        : 'audience';

    // Stats
    final postsCount = profile?.projects ?? 0;
    final followersCount = profile?.followers ?? '0';
    const shortlistCount = '00';
    const viewsCount = '43';

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Container(
            color: bgColor,
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Theme toggle switch
                      _ThemeToggleSwitch(
                        isDark: isDark,
                        onToggle: () => themeProvider.toggleTheme(),
                      ),
                    ],
                  ),
                ),

                // ── Profile Info Row ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Avatar
                      _ProfileAvatar(
                        profileImage: profile?.profileImage,
                        name: profile?.name,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      // Name + badge + location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'User',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Role badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                role.toLowerCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Location
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: subTextColor),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Share / profile icon
                      Icon(
                        Icons.share_outlined,
                        color: subTextColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Stats Row ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatBox(
                          value: postsCount.toString().padLeft(2, '0'),
                          label: 'Posts',
                          isDark: isDark),
                      const SizedBox(width: 8),
                      _StatBox(
                          value: followersCount.padLeft(2, '0'),
                          label: 'Followers',
                          isDark: isDark),
                      const SizedBox(width: 8),
                      _StatBox(
                          value: shortlistCount,
                          label: 'Shortlist',
                          isDark: isDark),
                      const SizedBox(width: 8),
                      _StatBox(
                          value: viewsCount,
                          label: 'Views',
                          isDark: isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Bar ───────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: subTextColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  dividerColor: dividerColor,
                  tabs: const [
                    Tab(text: 'Gallery'),
                    Tab(text: 'Bio Data'),
                    Tab(text: 'Projects'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      body: Container(
        color: bgColor,
        child: TabBarView(
          controller: _tabController,
          children: [
            // ── Gallery Tab ──────────────────────────────────────
            _GalleryTab(
              mediaList: mediaList,
              profile: profile,
              isDark: isDark,
            ),

            // ── Bio Data Tab ─────────────────────────────────────
            _BioDataTab(
              profile: profile,
              isDark: isDark,
              onLogout: _logout,
              onEditProfile: () => context.push(AppRoutes.editArtistProfile),
            ),

            // ── Projects Tab ─────────────────────────────────────
            _ProjectsTab(isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ProfileProvider provider, bool isDark) {
    final textColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded,
                color: Colors.redAccent, size: 44),
          ),
          const SizedBox(height: 18),
          Text(
            'Unable to Load Profile',
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: subColor, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Log Out'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (widget.userId != null) {
                      context
                          .read<ProfileProvider>()
                          .fetchUserProfile(widget.userId!);
                    } else {
                      context.read<ProfileProvider>().fetchMyProfile();
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Toggle Switch Widget ──────────────────────────────────────────────────────
class _ThemeToggleSwitch extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggleSwitch({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? AppColors.primary : const Color(0xFFE5E7EB),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment:
                  isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 13,
                  color: isDark ? AppColors.primary : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Avatar ────────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final String? profileImage;
  final String? name;
  final bool isDark;

  const _ProfileAvatar(
      {this.profileImage, this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = profileImage != null
        ? ApiEndpoints.formatMediaUrl(profileImage!)
        : '';
    final isNetwork =
        cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    final cleanName = name?.trim() ?? '';
    final initial =
        cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'U';

    Widget buildFallback() => Container(
          color: const Color(0xFF1A1A1A),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: isNetwork
            ? Image.network(cleanUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => buildFallback())
            : buildFallback(),
      ),
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatBox(
      {required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white60 : Colors.black54;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gallery Tab ───────────────────────────────────────────────────────────────
class _GalleryTab extends StatelessWidget {
  final List<PortfolioModel> mediaList;
  final ArtistModel? profile;
  final bool isDark;

  const _GalleryTab(
      {required this.mediaList,
      this.profile,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'No posts yet',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = mediaList[index];
        return PortfolioCard(
          item: item,
          onTap: () {
            final post = item.toFeedPostModel(artist: profile);
            final enrichedPost = post.copyWith(
              creatorId: (post.creatorId != null && post.creatorId!.isNotEmpty)
                  ? post.creatorId
                  : profile?.id,
              creatorName:
                  post.creatorName.isNotEmpty && post.creatorName != 'Creator'
                      ? post.creatorName
                      : (profile?.name.isNotEmpty == true
                          ? profile!.name
                          : 'Creator'),
              creatorPic: (post.creatorPic != null && post.creatorPic!.isNotEmpty)
                  ? post.creatorPic
                  : profile?.profileImage,
              creatorCategory: post.creatorCategory ??
                  (profile?.roles.isNotEmpty == true
                      ? profile!.roles.first
                      : 'Artist'),
            );
            context.push(AppRoutes.watchVideo, extra: enrichedPost);
          },
        );
      },
    );
  }
}

// ── Bio Data Tab ──────────────────────────────────────────────────────────────
class _BioDataTab extends StatelessWidget {
  final ArtistModel? profile;
  final bool isDark;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;

  const _BioDataTab({
    this.profile,
    required this.isDark,
    required this.onLogout,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F8);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    // Build surname from name parts
    final fullName = profile?.name ?? '';
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final surname =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final fields = <_BioField>[
      _BioField('Name', firstName.isNotEmpty ? firstName : '—'),
      _BioField('Surname', surname.isNotEmpty ? surname : '—'),
      _BioField(
          'Email', profile?.email.isNotEmpty == true ? profile!.email : '—'),
      _BioField(
          'Mobile Number',
          profile?.mobile.isNotEmpty == true ? profile!.mobile : '—'),
      _BioField(
          'Gender',
          profile?.gender.isNotEmpty == true
              ? _capitalize(profile!.gender)
              : '—'),
      _BioField(
          'Present State',
          profile?.state.isNotEmpty == true ? profile!.state : '—'),
      _BioField(
          'Present City',
          profile?.city.isNotEmpty == true ? profile!.city : '—'),
      _BioField(
          'Languages',
          profile?.languages.isNotEmpty == true ? profile!.languages : '—'),
      _BioField(
          'Qualification',
          profile?.experience.isNotEmpty == true ? profile!.experience : '—'),
      _BioField('Passport', '—'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Personal Details Card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Details',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Edit button
                      GestureDetector(
                        onTap: onEditProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 13, color: subColor),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style:
                                    TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),
                // Fields
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF121212)
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: fields.map((field) {
                      final isLast = fields.last == field;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    field.label,
                                    style: TextStyle(
                                      color: subColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  ':',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    field.value,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                                height: 1,
                                color: borderColor,
                                indent: 16,
                                endIndent: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                foregroundColor: textColor,
              ),
              icon: Icon(Icons.logout, size: 18, color: textColor),
              label: Text(
                'Logout',
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _BioField {
  final String label;
  final String value;
  const _BioField(this.label, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BioField && label == other.label && value == other.value;

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}

// ── Projects Tab ──────────────────────────────────────────────────────────────
class _ProjectsTab extends StatelessWidget {
  final bool isDark;
  const _ProjectsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Column(
      children: [
        // Add New Project button
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                '+ Add New Project',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'No projects added yet.',
              style: TextStyle(color: subColor, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
