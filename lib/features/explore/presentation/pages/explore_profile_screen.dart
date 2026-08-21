import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ──────────────────────────────────────
                  // Back button
                  // ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────
                  // Content
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
                                child: Text(
                                  provider.error!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 24),

                                    // ─────────────────────
                                    // Avatar
                                    // ─────────────────────
                                    _ProfileAvatar(
                                      imageUrl: profile?.profileImage,
                                    ),

                                    const SizedBox(height: 14),

                                    // ─────────────────────
                                    // Name
                                    // ─────────────────────
                                    Text(
                                      profile?.name.isNotEmpty == true
                                          ? profile!.name
                                          : 'Unknown Artist',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),

                                    if (profile?.roles.isNotEmpty == true)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4),
                                        child: Text(
                                          profile!.roles.first,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 28),

                                    // ─────────────────────
                                    // Stats row
                                    // ─────────────────────
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: AppColors.card
                                            .withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.border
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _StatColumn(
                                              value: profile?.followers
                                                      .isNotEmpty ==
                                                  true
                                                  ? profile!.followers
                                                  : '0',
                                              label: 'Followers',
                                            ),
                                            VerticalDivider(
                                              color: AppColors.border
                                                  .withOpacity(0.5),
                                              thickness: 1,
                                            ),
                                            _StatColumn(
                                              value: profile?.projects !=
                                                      null
                                                  ? profile!.projects
                                                      .toString()
                                                  : '0',
                                              label: 'Videos',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // ─────────────────────
                                    // Action Buttons
                                    // ─────────────────────
                                    Row(
                                      children: [
                                        // Follow button
                                        Expanded(
                                          child: _ActionButton(
                                            label: _isFollowing
                                                ? 'Following'
                                                : 'Follow',
                                            isPrimary: true,
                                            isActive: _isFollowing,
                                            onTap: () async {
                                              setState(() {
                                                _isFollowing =
                                                    !_isFollowing;
                                              });
                                              await provider.followUser(
                                                  widget.userId);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Message button
                                        Expanded(
                                          child: _ActionButton(
                                            label: 'Message',
                                            isPrimary: false,
                                            onTap: () {
                                              context.push(
                                                  AppRoutes.messages);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 32),

                                    // ─────────────────────
                                    // Portfolio Videos
                                    // ─────────────────────
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Portfolio Videos',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    _PortfolioSection(
                                      profileImage: profile?.profileImage,
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
// Profile Avatar
// ──────────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.55),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.card,
      child: const Icon(
        Icons.person,
        size: 50,
        color: AppColors.greyText,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stat Column
// ──────────────────────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Action Button
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
      // Gradient (Follow) button
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
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
            color: isActive ? AppColors.card : null,
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                  )
                : null,
            boxShadow: isActive
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : AppColors.white,
              ),
            ),
          ),
        ),
      );
    }

    // Outlined (Message) button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card.withOpacity(0.7),
          border: Border.all(
            color: AppColors.border.withOpacity(0.6),
          ),
        ),
        child: const Center(
          child: Text(
            'Message',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Portfolio Section
// ──────────────────────────────────────────────────────────────

class _PortfolioSection extends StatelessWidget {
  final String? profileImage;

  const _PortfolioSection({this.profileImage});

  @override
  Widget build(BuildContext context) {
    // Show at least one portfolio thumbnail using the profile image as placeholder
    final hasImage = profileImage != null &&
        profileImage!.isNotEmpty &&
        profileImage!.startsWith('http');

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hasImage ? 1 : 0,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  profileImage!,
                  width: 105,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _emptyThumbnail(),
                ),
              ),
              // Play overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.black.withOpacity(0.3),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyThumbnail() {
    return Container(
      width: 105,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: const Icon(
        Icons.videocam_outlined,
        color: AppColors.greyText,
        size: 32,
      ),
    );
  }
}
