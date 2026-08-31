import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
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
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              final profile = provider.viewedProfile;
              final mediaList = provider.viewedMedia;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ──────────────────────────────────────
                  // Top App Bar (< Back)
                  // ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Back',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────
                  // Scrollable Profile Content
                  // ──────────────────────────────────────
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : provider.error != null
                            ? Center(
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
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 16),

                                    // ── Avatar with Green Verification Checkmark ──
                                    _ProfileAvatar(
                                      imageUrl: profile?.profileImage,
                                    ),

                                    const SizedBox(height: 16),

                                    // ── Artist Name ──
                                    Text(
                                      profile?.name.isNotEmpty == true
                                          ? profile!.name
                                          : 'Unknown Artist',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    // ── Location ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          LucideIcons.mapPin,
                                          size: 14,
                                          color: AppColors.greyText,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatLocation(
                                            profile?.city,
                                            profile?.state,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // ── Category / Role Pill Tag ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8E3CF7),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8E3CF7)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        profile?.roles.isNotEmpty == true
                                            ? profile!.roles.first.toLowerCase()
                                            : 'artist',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // ── Stats Row: Projects | Followers | Awards ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D2533),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _StatItem(
                                            icon: LucideIcons.briefcase,
                                            iconColor: const Color(0xFFC084FC),
                                            value: '${profile?.projects ?? 0}',
                                            label: 'Projects',
                                          ),
                                          _StatDivider(),
                                          _StatItem(
                                            icon: LucideIcons.users,
                                            iconColor: const Color(0xFFF43F5E),
                                            value: profile?.followers
                                                        .isNotEmpty ==
                                                    true
                                                ? profile!.followers
                                                : '0',
                                            label: 'Followers',
                                          ),
                                          _StatDivider(),
                                          _StatItem(
                                            icon: LucideIcons.trophy,
                                            iconColor: const Color(0xFF22D3EE),
                                            value: '${profile?.awards ?? 0}',
                                            label: 'Awards',
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // ── Experience & Languages Cards ──
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _InfoTile(
                                            icon: LucideIcons.award,
                                            iconColor:
                                                const Color(0xFFC084FC),
                                            title: 'Experience',
                                            value: profile?.experience
                                                        .isNotEmpty ==
                                                    true
                                                ? profile!.experience
                                                : '5–10 Years',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _InfoTile(
                                            icon: LucideIcons.globe,
                                            iconColor:
                                                const Color(0xFF22D3EE),
                                            title: 'Languages',
                                            value: profile?.languages
                                                        .isNotEmpty ==
                                                    true
                                                ? profile!.languages
                                                : 'English',
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Follow & Message Buttons ──
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ActionButton(
                                            label: _isFollowing
                                                ? 'Following'
                                                : 'Follow',
                                            isPrimary: true,
                                            isActive: _isFollowing,
                                            onTap: () async {
                                              setState(() {
                                                _isFollowing = !_isFollowing;
                                              });
                                              await provider
                                                  .followUser(widget.userId);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ActionButton(
                                            label: 'Message',
                                            isPrimary: false,
                                            onTap: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              final router = GoRouter.of(context);
                                              final chat = await context
                                                  .read<MessagesProvider>()
                                                  .startChat(widget.userId);
                                              if (chat != null) {
                                                final enrichedChat = chat.copyWith(
                                                  participantId: widget.userId,
                                                  participantName: (chat.participantName.isNotEmpty)
                                                      ? chat.participantName
                                                      : (profile?.name ?? ''),
                                                  participantAvatar: (chat.participantAvatar.isNotEmpty)
                                                      ? chat.participantAvatar
                                                      : (profile?.profileImage ?? ''),
                                                  participantRole: (chat.participantRole.isNotEmpty)
                                                      ? chat.participantRole
                                                      : (profile?.roles.isNotEmpty == true
                                                          ? profile!.roles.first
                                                          : 'Artist'),
                                                );
                                                router.push(
                                                  AppRoutes.chat,
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
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 28),

                                    // ── Portfolio Header ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Portfolio',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (mediaList.isNotEmpty)
                                          Text(
                                            'View All',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // ── Photos and Videos Posted by that Artist ──
                                    _ArtistPortfolioGrid(
                                      mediaList: mediaList,
                                      fallbackImage: profile?.profileImage,
                                    ),

                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _formatLocation(String? city, String? state) {
    final c = (city ?? '').trim();
    final s = (state ?? '').trim();
    if (c.isNotEmpty && s.isNotEmpty) return '$c, $s';
    if (c.isNotEmpty) return c;
    if (s.isNotEmpty) return s;
    return 'Other, Other';
  }
}

// ──────────────────────────────────────────────────────────────
// Profile Avatar with Verification Badge
// ──────────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final formatted = (imageUrl != null && imageUrl!.isNotEmpty)
        ? ApiEndpoints.formatMediaUrl(imageUrl!)
        : '';
    final hasImage = formatted.startsWith('http');

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.65),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
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
        ),
        // Green Verified Tick Badge
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0B1F2A), width: 2),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 13,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF0F2D3A),
      child: const Icon(
        Icons.person,
        size: 52,
        color: Colors.white70,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stat Item
// ──────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Experience / Languages Tile
// ──────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2533),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Action Button (Follow / Message)
// ──────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isActive
                ? null
                : const LinearGradient(
                    colors: AppColors.BtnGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isActive ? const Color(0xFF0D2533) : null,
            border: isActive
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                : null,
            boxShadow: isActive
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0D2533),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Photos & Videos Posted by that Artist
// ──────────────────────────────────────────────────────────────
class _ArtistPortfolioGrid extends StatelessWidget {
  final List<PortfolioModel> mediaList;
  final String? fallbackImage;

  const _ArtistPortfolioGrid({
    required this.mediaList,
    this.fallbackImage,
  });

  @override
  Widget build(BuildContext context) {
    // If no media is found, show friendly empty state
    if (mediaList.isEmpty) {
      if (fallbackImage != null && fallbackImage!.isNotEmpty) {
        // Show the artist's profile picture as portfolio preview if no media posts yet
        return SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _PortfolioItemCard(
                media: PortfolioModel(
                  image: fallbackImage!,
                  isVideo: false,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2533),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                LucideIcons.image,
                color: Colors.white30,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No photos or videos posted yet',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = mediaList[index];
          return _PortfolioItemCard(media: item);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Individual Portfolio Thumbnail Card (Photo / Video)
// ──────────────────────────────────────────────────────────────
class _PortfolioItemCard extends StatelessWidget {
  final PortfolioModel media;

  const _PortfolioItemCard({required this.media});

  @override
  Widget build(BuildContext context) {
    final formatted = ApiEndpoints.formatMediaUrl(media.image);
    final hasImage = formatted.startsWith('http');

    return Container(
      width: 110,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          hasImage
              ? Image.network(
                  formatted,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _emptyThumbnail(),
                )
              : _emptyThumbnail(),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),

          // Video Play Overlay Badge if it's a video
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
    );
  }

  Widget _emptyThumbnail() {
    return Container(
      color: const Color(0xFF0F2D3A),
      child: Icon(
        media.isVideo ? LucideIcons.video : LucideIcons.image,
        color: AppColors.greyText,
        size: 32,
      ),
    );
  }
}
