import 'package:aicc/common/widgets/custom_bottom_navbar.dart';
import 'package:aicc/common/widgets/video_frame_thumbnail.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/desktop_shell.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:aicc/features/home/data/models/feed_post_model.dart';
import 'package:aicc/features/messages/presentation/providers/messages_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ExploreProfileScreen extends StatefulWidget {
  final String userId;

  const ExploreProfileScreen({super.key, required this.userId});

  @override
  State<ExploreProfileScreen> createState() => _ExploreProfileScreenState();
}

class _ExploreProfileScreenState extends State<ExploreProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile(widget.userId);
    });
  }

  bool _isCurrentUser(ArtistModel? profile) {
    String? currentUserId;
    String? currentUserName;
    String? currentUserEmail;

    try {
      currentUserId = LocalStorage.instance.getUserId();
      currentUserName = LocalStorage.instance.getUserName();
      currentUserEmail = LocalStorage.instance.getUserEmail();
    } catch (_) {}

    if (widget.userId.isNotEmpty && currentUserId != null && currentUserId.isNotEmpty) {
      if (widget.userId == currentUserId) return true;
    }
    if (profile != null && profile.id.isNotEmpty && currentUserId != null && currentUserId.isNotEmpty) {
      if (profile.id == currentUserId) return true;
    }

    if (profile != null && profile.name.isNotEmpty && currentUserName != null && currentUserName.isNotEmpty) {
      if (profile.name.trim().toLowerCase() == currentUserName.trim().toLowerCase()) return true;
    }

    if (profile != null && profile.name.isNotEmpty && currentUserEmail != null && currentUserEmail.isNotEmpty) {
      final emailPrefix = currentUserEmail.split('@').first.trim().toLowerCase();
      if (profile.name.trim().toLowerCase() == emailPrefix) return true;
    }

    try {
      final myProfile = context.read<ProfileProvider>().currentProfile;
      if (myProfile != null) {
        if (widget.userId.isNotEmpty && myProfile.id.isNotEmpty && widget.userId == myProfile.id) return true;
        if (profile != null && profile.id.isNotEmpty && myProfile.id.isNotEmpty && profile.id == myProfile.id) return true;
        if (profile != null && profile.name.isNotEmpty && myProfile.name.isNotEmpty &&
            profile.name.trim().toLowerCase() == myProfile.name.trim().toLowerCase()) {
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  static String _formatLocation(String? city, String? state) {
    final c = (city ?? '').trim();
    final s = (state ?? '').trim();
    if (c.isNotEmpty && s.isNotEmpty) return '$c, $s';
    if (c.isNotEmpty) return '$c, India';
    if (s.isNotEmpty) return '$s, India';
    return 'India';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkScaffold : Colors.white;

    if (isDesktop) {
      return DesktopShell(
        currentLocation: AppRoutes.exploreProfile,
        child: _buildDesktopContent(context, isDark),
      );
    }

    // Mobile view (100% UNCHANGED)
    return Scaffold(
      backgroundColor: scaffoldBg,
      bottomNavigationBar: CustomBottomNavbar(
        currentLocation: AppRoutes.explore,
        backgroundColor: isDark ? null : const Color(0xFFFBEEDB),
        onItemSelected: (route) {
          if (route == AppRoutes.explore) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.explore);
            }
          } else {
            context.go(route);
          }
        },
      ),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
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
                        color: Colors.black26,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context
                            .read<ProfileProvider>()
                            .fetchUserProfile(widget.userId),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = provider.viewedProfile;
            final mediaList = provider.viewedMedia;

            final fullName = profile?.name ?? '';
            final location = _formatLocation(profile?.city, profile?.state);
            final role = profile?.roles.isNotEmpty == true
                ? profile!.roles.first
                : 'Artist';

            final projectsCount = (profile != null && profile.projects > 0)
                ? '${profile.projects}'
                : '${mediaList.length}';
            final followersCount = (profile != null && profile.followers.isNotEmpty)
                ? profile.followers
                : '0';
            final awardsCount = '${profile?.awards ?? 0}';

            final experience = (profile != null && profile.experience.isNotEmpty)
                ? profile.experience
                : '3-4 Years';
            final languages = (profile != null && profile.languages.isNotEmpty)
                ? profile.languages
                : 'Tamil';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Navigation Bar with Back Button ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFE5E7EB),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Scrollable Profile Content ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),

                        // ── Circular Avatar (Centered) ──
                        _CenteredAvatar(
                          imageUrl: profile?.profileImage,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 14),

                        // ── Name ──
                        Text(
                          fullName.isNotEmpty ? fullName : 'Artist',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Location ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Role Pill Badge ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role.isNotEmpty
                                ? role[0].toUpperCase() + role.substring(1)
                                : 'Artist',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Stats Row (3 Box Cards) ──
                        Row(
                          children: [
                            _StatCard(
                              value: projectsCount.padLeft(2, '0'),
                              label: 'Projects',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              value: followersCount.padLeft(2, '0'),
                              label: 'Followers',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              value: awardsCount.padLeft(2, '0'),
                              label: 'Awards',
                              isDark: isDark,
                            ),
                          ],
                        ),

                        // ── Action Buttons Row (Message / Follow) ──
                        if (!_isCurrentUser(profile)) ...[
                          const SizedBox(height: 18),
                          _ActionButtonsRow(
                            userId: widget.userId,
                            profile: profile,
                            provider: provider,
                            isDark: isDark,
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ── Experience & Languages Row ──
                        Row(
                          children: [
                            Expanded(
                              child: _DetailInfoCard(
                                icon: LucideIcons.award,
                                value: experience,
                                label: 'Experience',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DetailInfoCard(
                                icon: LucideIcons.languages,
                                value: languages,
                                label: 'Languages',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Portfolio Header ──
                        Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Portfolio',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── Portfolio Grid/List ──
                        _ArtistPortfolioGrid(
                          mediaList: mediaList,
                          profile: profile,
                          userId: widget.userId,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context, bool isDark) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
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
                    color: Colors.black26,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context
                        .read<ProfileProvider>()
                        .fetchUserProfile(widget.userId),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = provider.viewedProfile;
        final mediaList = provider.viewedMedia;

        final fullName = profile?.name ?? '';
        final location = _formatLocation(profile?.city, profile?.state);
        final role = profile?.roles.isNotEmpty == true
            ? profile!.roles.first
            : 'Artist';

        final projectsCount = (profile != null && profile.projects > 0)
            ? '${profile.projects}'
            : '${mediaList.length}';
        final followersCount = (profile != null && profile.followers.isNotEmpty)
            ? profile.followers
            : '0';
        final awardsCount = '${profile?.awards ?? 0}';

        final experience = (profile != null && profile.experience.isNotEmpty)
            ? profile.experience
            : '3-4 Years';
        final languages = (profile != null && profile.languages.isNotEmpty)
            ? profile.languages
            : 'Tamil';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back to Explore Button ──
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.explore);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2433) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF262D3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back to Explore',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Profile Desktop Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141720) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262D3D) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Centered Avatar ──
                    _CenteredAvatar(
                      imageUrl: profile?.profileImage,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // ── Name ──
                    Text(
                      fullName.isNotEmpty ? fullName : 'Artist',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Location ──
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Role Pill ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.isNotEmpty
                            ? role[0].toUpperCase() + role.substring(1)
                            : 'Artist',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Stats Row ──
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Row(
                        children: [
                          _StatCard(
                            value: projectsCount.padLeft(2, '0'),
                            label: 'Projects',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            value: followersCount.padLeft(2, '0'),
                            label: 'Followers',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            value: awardsCount.padLeft(2, '0'),
                            label: 'Awards',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    // ── Action Buttons Row ──
                    if (!_isCurrentUser(profile)) ...[
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: _ActionButtonsRow(
                          userId: widget.userId,
                          profile: profile,
                          provider: provider,
                          isDark: isDark,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Experience & Languages Row ──
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DetailInfoCard(
                              icon: LucideIcons.award,
                              value: experience,
                              label: 'Experience',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DetailInfoCard(
                              icon: LucideIcons.languages,
                              value: languages,
                              label: 'Languages',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Portfolio Header ──
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Portfolio',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Portfolio Grid ──
                    _ArtistPortfolioGrid(
                      mediaList: mediaList,
                      profile: profile,
                      userId: widget.userId,
                      isDark: isDark,
                      isDesktop: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Centered Circular Avatar
// ──────────────────────────────────────────────────────────────
class _CenteredAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;

  const _CenteredAvatar({this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final formatted = (imageUrl != null && imageUrl!.isNotEmpty)
        ? ApiEndpoints.formatMediaUrl(imageUrl!)
        : '';
    final hasImage = formatted.startsWith('http');

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                formatted,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
      child: Icon(
        Icons.person,
        size: 56,
        color: isDark ? Colors.white38 : Colors.black26,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Individual Stat Card (Projects, Followers, Awards)
// ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Experience / Languages Detail Info Card
// ──────────────────────────────────────────────────────────────
class _DetailInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _DetailInfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Action Buttons Row (Message on Left, Follow on Right)
// ──────────────────────────────────────────────────────────────
class _ActionButtonsRow extends StatefulWidget {
  final String userId;
  final ArtistModel? profile;
  final ProfileProvider provider;
  final bool isDark;

  const _ActionButtonsRow({
    required this.userId,
    this.profile,
    required this.provider,
    required this.isDark,
  });

  @override
  State<_ActionButtonsRow> createState() => _ActionButtonsRowState();
}

class _ActionButtonsRowState extends State<_ActionButtonsRow> {
  bool _isStartingChat = false;

  Future<void> _handleMessageTap() async {
    if (_isStartingChat) return;
    setState(() {
      _isStartingChat = true;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final chat = await context
          .read<MessagesProvider>()
          .startChat(widget.userId);

      if (!mounted) return;

      if (chat != null) {
        final enrichedChat = chat.copyWith(
          participantId: widget.userId,
          participantName: (chat.participantName.isNotEmpty)
              ? chat.participantName
              : (widget.profile?.name ?? ''),
          participantAvatar: (chat.participantAvatar.isNotEmpty)
              ? chat.participantAvatar
              : (widget.profile?.profileImage ?? ''),
          participantRole: (chat.participantRole.isNotEmpty)
              ? chat.participantRole
              : (widget.profile?.roles.isNotEmpty == true
                  ? widget.profile!.roles.first
                  : 'Artist'),
        );
        final chatUri = Uri(
          path: AppRoutes.chat,
          queryParameters: {
            if (enrichedChat.id.isNotEmpty) 'chatId': enrichedChat.id,
            if (enrichedChat.participantId.isNotEmpty) 'userId': enrichedChat.participantId,
            if (enrichedChat.participantName.isNotEmpty) 'name': enrichedChat.participantName,
            if (enrichedChat.participantAvatar.isNotEmpty) 'avatar': enrichedChat.participantAvatar,
            if (enrichedChat.participantRole.isNotEmpty) 'role': enrichedChat.participantRole,
          },
        ).toString();
        router.push(
          chatUri,
          extra: enrichedChat,
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not start chat. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isStartingChat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFollowing = widget.provider.isFollowing(widget.userId);

    return Row(
      children: [
        // ── Message button (Left: Outlined, White background, Orange border) ──
        Expanded(
          child: GestureDetector(
            onTap: _isStartingChat ? null : _handleMessageTap,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: _isStartingChat
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        'Message',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ── Follow button (Right: Solid Orange background, White text) ──
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await widget.provider.toggleFollowUser(
                widget.userId,
                userName: widget.profile?.name,
              );
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isFollowing
                    ? (widget.isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFE5E7EB))
                    : AppColors.primary,
                border: isFollowing
                    ? Border.all(
                        color: widget.isDark
                            ? Colors.white24
                            : const Color(0xFFD1D5DB),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isFollowing
                        ? (widget.isDark ? Colors.white : Colors.black87)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Portfolio Grid / Horizontal List
// ──────────────────────────────────────────────────────────────
class _ArtistPortfolioGrid extends StatelessWidget {
  final List<PortfolioModel> mediaList;
  final ArtistModel? profile;
  final String userId;
  final bool isDark;
  final bool isDesktop;

  const _ArtistPortfolioGrid({
    required this.mediaList,
    this.profile,
    this.userId = '',
    required this.isDark,
    this.isDesktop = false,
  });

  void _openMedia(BuildContext context, PortfolioModel item) {
    final post = item.toFeedPostModel(artist: profile);
    final enrichedPost = post.copyWith(
      creatorId: (post.creatorId != null && post.creatorId!.isNotEmpty)
          ? post.creatorId
          : (profile?.id.isNotEmpty == true
              ? profile!.id
              : (userId.isNotEmpty ? userId : null)),
      creatorName: post.creatorName.isNotEmpty && post.creatorName != 'Creator'
          ? post.creatorName
          : (profile?.name.isNotEmpty == true ? profile!.name : 'Creator'),
      creatorPic: (post.creatorPic != null && post.creatorPic!.isNotEmpty)
          ? post.creatorPic
          : profile?.profileImage,
      creatorCategory: post.creatorCategory ?? (profile?.roles.isNotEmpty == true ? profile!.roles.first : 'Artist'),
    );
    context.push(AppRoutes.watchVideo, extra: enrichedPost);
  }

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.image,
                color: isDark ? Colors.white30 : Colors.black26,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No photos or videos posted yet',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white54 : const Color(0xFF8E8E93),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mediaList.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final item = mediaList[index];
          return _PortfolioItemCard(
            media: item,
            isDark: isDark,
            isDesktop: true,
            onTap: () => _openMedia(context, item),
          );
        },
      );
    }

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = mediaList[index];
          return _PortfolioItemCard(
            media: item,
            isDark: isDark,
            onTap: () => _openMedia(context, item),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Individual Portfolio Thumbnail Card
// ──────────────────────────────────────────────────────────────
class _PortfolioItemCard extends StatelessWidget {
  final PortfolioModel media;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isDesktop;

  const _PortfolioItemCard({
    required this.media,
    this.onTap,
    required this.isDark,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    String? videoThumbnailUrl;
    if (media.isVideo) {
      final rawVideo = (media.videoUrl != null && media.videoUrl!.isNotEmpty)
          ? media.videoUrl!
          : (FeedPostModel.isVideoMediaUrl(media.image) ? media.image : '');
      videoThumbnailUrl = rawVideo.isNotEmpty
          ? ApiEndpoints.formatMediaUrl(rawVideo)
          : null;
    }

    final formatted = ApiEndpoints.formatMediaUrl(media.image);
    final hasImage = formatted.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isDesktop ? double.infinity : 155,
        height: isDesktop ? double.infinity : 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF3F4F6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (media.isVideo)
              videoThumbnailUrl != null
                  ? VideoFrameThumbnail(
                      videoUrl: videoThumbnailUrl,
                      fallback: _emptyThumbnail(),
                    )
                  : _emptyThumbnail()
            else if (hasImage)
              Image.network(
                formatted,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _emptyThumbnail(),
              )
            else
              _emptyThumbnail(),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),

            // Video Play Overlay Badge
            if (media.isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.55),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyThumbnail() {
    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E7EB),
      child: Icon(
        media.isVideo ? LucideIcons.video : LucideIcons.image,
        color: isDark ? Colors.white38 : Colors.black26,
        size: 32,
      ),
    );
  }
}
