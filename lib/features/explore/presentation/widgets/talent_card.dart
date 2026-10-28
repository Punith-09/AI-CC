import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../messages/presentation/providers/messages_provider.dart';

class TalentCard extends StatelessWidget {
  final TalentModel talent;

  const TalentCard({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);
    final nameColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor = isDark ? const Color(0xFF8A8A8E) : const Color(0xFF6B7280);

    final formattedPic = talent.pic.isNotEmpty
        ? ApiEndpoints.formatMediaUrl(talent.pic)
        : '';
    final hasValidNetworkPic = formattedPic.startsWith('http');

    // Use profile pic as the featured image too (as in the reference)
    final featuredImageUrl = hasValidNetworkPic ? formattedPic : null;

    // Format handle/ID
    final handleText = talent.handle.isNotEmpty
        ? talent.handle
        : (talent.id.isNotEmpty ? talent.id.substring(0, talent.id.length.clamp(0, 8)) : '');
    final categoryText = talent.category.isNotEmpty ? talent.category : 'Artist';
    final subtitleLine = [handleText, categoryText]
        .where((s) => s.isNotEmpty)
        .join(' - ');

    return GestureDetector(
      onTap: () {
        if (talent.id.isNotEmpty) {
          context.push(AppRoutes.exploreProfile, extra: talent.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  _TalentAvatar(
                    imageUrl: hasValidNetworkPic ? formattedPic : null,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),

                  // Name + Handle + Active status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talent.name.isNotEmpty ? talent.name : 'Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: nameColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitleLine.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: subtitleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        // Active status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Active',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF388E3C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Follow button + kebab menu column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _FollowButton(
                          talentId: talent.id, talentName: talent.name),
                      const SizedBox(height: 6),
                      // Icon(
                      //   Icons.more_vert,
                      //   color: subtitleColor,
                      //   size: 20,
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Featured Media Image ─────────────────────────
            if (featuredImageUrl != null)
              ClipRRect(
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    featuredImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _MediaPlaceholder(isDark: isDark),
                  ),
                ),
              )
            else
              _MediaPlaceholder(isDark: isDark),

            // ── Stats & Message Row ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  // Posts count
                  Text(
                    'Posts: (${talent.videosCount})',
                    style: GoogleFonts.poppins(
                      color: nameColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Views count (followers used as proxy)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.eye,
                        size: 14,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(talent.followers),
                        style: GoogleFonts.poppins(
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Message button
                  _MessageButton(talent: talent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Talent Avatar
// ──────────────────────────────────────────────────────────────────────────────
class _TalentAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;

  const _TalentAvatar({this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
      child: Icon(
        Icons.person_rounded,
        color: isDark ? const Color(0xFF8A8A8E) : const Color(0xFF94A3B8),
        size: 28,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Media Placeholder
// ──────────────────────────────────────────────────────────────────────────────
class _MediaPlaceholder extends StatelessWidget {
  final bool isDark;

  const _MediaPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 40,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Follow Button — backed by ProfileProvider for global synchronization
// ──────────────────────────────────────────────────────────────────────────────
class _FollowButton extends StatelessWidget {
  final String talentId;
  final String talentName;

  const _FollowButton({required this.talentId, required this.talentName});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final isFollowing = profileProvider.isFollowing(talentId);
    final isFollowLoading = profileProvider.isFollowLoading(talentId);

    return GestureDetector(
      onTap: isFollowLoading || talentId.isEmpty
          ? null
          : () async {
              try {
                await profileProvider.toggleFollowUser(talentId,
                    userName: talentName);
              } catch (_) {}
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: isFollowLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Colors.white,
                ),
              )
            : Text(
                isFollowing ? 'Following' : 'Follow',
                style: GoogleFonts.poppins(
                  color: isFollowing ? AppColors.primary : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Message Button
// ──────────────────────────────────────────────────────────────────────────────
class _MessageButton extends StatefulWidget {
  final TalentModel talent;

  const _MessageButton({required this.talent});

  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton> {
  bool _isStarting = false;

  Future<void> _handleTap() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    try {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final chat = await context
          .read<MessagesProvider>()
          .startChat(widget.talent.id);

      if (!mounted) return;

      if (chat != null) {
        final enriched = chat.copyWith(
          participantId: widget.talent.id,
          participantName: chat.participantName.isNotEmpty
              ? chat.participantName
              : widget.talent.name,
          participantAvatar: chat.participantAvatar.isNotEmpty
              ? chat.participantAvatar
              : widget.talent.pic,
          participantRole: chat.participantRole.isNotEmpty
              ? chat.participantRole
              : widget.talent.category,
        );
        router.push(AppRoutes.chat, extra: enriched);
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
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isStarting ? null : _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3A3A3C)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: _isStarting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.messageCircle,
                    size: 14,
                    color: isDark ? Colors.white70 : AppColors.lightText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Message',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : AppColors.lightText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}