import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:aicc/features/messages/presentation/providers/messages_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../artist_profile/data/models/artist_model.dart';

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
                  // ── Top App Bar (< Back) ──────────────────────────
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

                  // ── Scrollable Profile Content ────────────────────
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
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),

                                    // ── Profile Info Row (matches first screen) ──
                                    _ProfileInfoRow(profile: profile),

                                    const SizedBox(height: 20),

                                    // ── Stats Row (matches first screen style) ──
                                    _StatsRow(profile: profile),

                                    const SizedBox(height: 16),

                                    // ── Experience & Languages (matches first screen) ──
                                    _ExperienceLanguagesRow(profile: profile),

                                    // ── Follow & Message Buttons ──
                                    if (!_isCurrentUser(profile)) ...[
                                      const SizedBox(height: 16),
                                      _ActionButtonsRow(
                                        userId: widget.userId,
                                        profile: profile,
                                        provider: provider,
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // ── Portfolio Section Header ──
                                    Text(
                                      'Portfolio',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // ── Portfolio Grid ──
                                    _ArtistPortfolioGrid(
                                      mediaList: mediaList,
                                      profile: profile,
                                      userId: widget.userId,
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

}

// ──────────────────────────────────────────────────────────────
// Profile Info Row – matches artist_profile_screen layout
// ──────────────────────────────────────────────────────────────
class _ProfileInfoRow extends StatelessWidget {
  final ArtistModel? profile;

  const _ProfileInfoRow({this.profile});

  static String _formatLocation(String? city, String? state) {
    final c = (city ?? '').trim();
    final s = (state ?? '').trim();
    if (c.isNotEmpty && s.isNotEmpty) return '$c, $s';
    if (c.isNotEmpty) return c;
    if (s.isNotEmpty) return s;
    return 'Location not available';
  }

  @override
  Widget build(BuildContext context) {
    final fullName = profile?.name ?? '';
    final location = _formatLocation(profile?.city, profile?.state);
    final role = profile?.roles.isNotEmpty == true
        ? profile!.roles.first.toLowerCase()
        : 'artist';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar – same styling as first screen
        _ProfileAvatar(imageUrl: profile?.profileImage),
        const SizedBox(width: 16),

        // Name + Role + Location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.isNotEmpty ? fullName : 'Unknown Artist',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Role badge – orange, matching first screen
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role,
                  style: GoogleFonts.poppins(
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
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Profile Avatar – matches first screen style
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
        child: hasImage
            ? Image.network(
                formatted,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.white70,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stats Row – matches first screen individual box style
// ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final ArtistModel? profile;

  const _StatsRow({this.profile});

  @override
  Widget build(BuildContext context) {
    final followers = profile?.followers.isNotEmpty == true
        ? profile!.followers
        : '0';
    final awards = '${profile?.awards ?? 0}';

    return Row(
      children: [
        _StatBox(
          value: followers.padLeft(2, '0'),
          label: 'Followers',
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: awards.padLeft(2, '0'),
          label: 'Awards',
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stat Box – matches first screen _StatBox style
// ──────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Experience & Languages Row – orange-themed to match first screen
// ──────────────────────────────────────────────────────────────
class _ExperienceLanguagesRow extends StatelessWidget {
  final ArtistModel? profile;

  const _ExperienceLanguagesRow({this.profile});

  @override
  Widget build(BuildContext context) {
    final experience = profile?.experience.isNotEmpty == true
        ? profile!.experience
        : 'Not specified';
    final languages = profile?.languages.isNotEmpty == true
        ? profile!.languages
        : 'Not specified';

    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: LucideIcons.award,
            title: 'Experience',
            value: experience,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: LucideIcons.globe,
            title: 'Languages',
            value: languages,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Info Tile – orange-themed, matching first screen style
// ──────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Action Buttons Row (Follow / Message) – matches first screen
// ──────────────────────────────────────────────────────────────
class _ActionButtonsRow extends StatelessWidget {
  final String userId;
  final ArtistModel? profile;
  final ProfileProvider provider;

  const _ActionButtonsRow({
    required this.userId,
    this.profile,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = provider.isFollowing(userId);

    return Row(
      children: [
        // Follow button – orange gradient (matches first screen primary action)
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await provider.toggleFollowUser(
                userId,
                userName: profile?.name,
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isFollowing
                    ? null
                    : const LinearGradient(
                        colors: AppColors.BtnGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color:
                    isFollowing ? const Color(0xFF1A1A1A) : null,
                border: isFollowing
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5))
                    : null,
                boxShadow: isFollowing
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
                  isFollowing ? 'Following' : 'Follow',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isFollowing ? AppColors.primary : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Message button – dark, matching first screen secondary action
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              final chat = await context
                  .read<MessagesProvider>()
                  .startChat(userId);
              if (chat != null) {
                final enrichedChat = chat.copyWith(
                  participantId: userId,
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
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
// Portfolio Grid
// ──────────────────────────────────────────────────────────────
class _ArtistPortfolioGrid extends StatelessWidget {
  final List<PortfolioModel> mediaList;
  final ArtistModel? profile;
  final String userId;

  const _ArtistPortfolioGrid({
    required this.mediaList,
    this.profile,
    this.userId = '',
  });

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
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
          return _PortfolioItemCard(
            media: item,
            onTap: () {
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
            },
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

  const _PortfolioItemCard({
    required this.media,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = ApiEndpoints.formatMediaUrl(media.image);
    final hasImage = formatted.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      color: const Color(0xFF1A1A1A),
      child: Icon(
        media.isVideo ? LucideIcons.video : LucideIcons.image,
        color: Colors.white38,
        size: 32,
      ),
    );
  }
}
