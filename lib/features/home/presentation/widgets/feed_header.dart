import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/media_downloader/media_downloader.dart';
import '../../data/models/feed_post_model.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';

/// In-memory cache for creator TRK codes (app IDs) to guarantee instant display.
class FeedHeaderUserTrkCache {
  static final Map<String, String> _cache = {};
  static String? get(String userId) => _cache[userId];
  static void set(String userId, String trk) {
    if (userId.isNotEmpty && trk.isNotEmpty) {
      _cache[userId] = trk;
    }
  }
}

class FeedHeader extends StatefulWidget {
  final FeedPostModel post;

  const FeedHeader({
    super.key,
    required this.post,
  });

  @override
  State<FeedHeader> createState() => _FeedHeaderState();
}

class _FeedHeaderState extends State<FeedHeader> {
  bool _isFetchingTrk = false;

  @override
  void initState() {
    super.initState();
    _checkAndResolveTrkCode();
  }

  @override
  void didUpdateWidget(covariant FeedHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.creatorId != widget.post.creatorId ||
        oldWidget.post.creatorTrkCode != widget.post.creatorTrkCode) {
      _checkAndResolveTrkCode();
    }
  }

  void _checkAndResolveTrkCode() {
    final trk = widget.post.creatorTrkCode;
    final creatorId = widget.post.creatorId ?? '';

    if (trk != null && trk.isNotEmpty && creatorId.isNotEmpty) {
      FeedHeaderUserTrkCache.set(creatorId, trk);
      return;
    }

    if (creatorId.isNotEmpty &&
        FeedHeaderUserTrkCache.get(creatorId) == null &&
        !_isFetchingTrk &&
        sl.isRegistered<ProfileRepository>()) {
      _isFetchingTrk = true;
      sl<ProfileRepository>().getUserProfile(creatorId).then((profile) {
        if (mounted && profile.trkCode.isNotEmpty) {
          FeedHeaderUserTrkCache.set(creatorId, profile.trkCode);
          setState(() {});
        }
      }).catchError((_) {}).whenComplete(() {
        _isFetchingTrk = false;
      });
    }
  }

  void _navigateToProfile(BuildContext context) {
    final targetUserId = widget.post.creatorId;
    String? currentUserId;
    String? currentUserName;

    try {
      currentUserId = LocalStorage.instance.getUserId();
      currentUserName = LocalStorage.instance.getUserName();
    } catch (_) {}

    final isMe = (targetUserId != null &&
            targetUserId.isNotEmpty &&
            currentUserId != null &&
            targetUserId == currentUserId) ||
        (widget.post.creatorName.isNotEmpty &&
            currentUserName != null &&
            widget.post.creatorName.trim().toLowerCase() ==
                currentUserName.trim().toLowerCase());

    if (isMe) {
      context.push(AppRoutes.artistProfile);
      return;
    }

    if (targetUserId != null && targetUserId.isNotEmpty) {
      context.push(AppRoutes.exploreProfile, extra: targetUserId);
    }
  }

  void _showMoreOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.download_rounded, color: iconColor),
                title: Text(
                  'Download',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  MediaDownloader.downloadPostMedia(context, widget.post);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkText : AppColors.black;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.greyText;
    final accentColor = AppColors.primary;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.black;

    String? currentUserId;
    String? currentUserName;
    try {
      currentUserId = LocalStorage.instance.getUserId();
      currentUserName = LocalStorage.instance.getUserName();
    } catch (_) {}

    final targetUserId = widget.post.creatorId;
    final isMe = (targetUserId != null &&
            targetUserId.isNotEmpty &&
            currentUserId != null &&
            targetUserId == currentUserId) ||
        (widget.post.creatorName.isNotEmpty &&
            currentUserName != null &&
            widget.post.creatorName.trim().toLowerCase() ==
                currentUserName.trim().toLowerCase());

    final profileProvider = context.watch<ProfileProvider>();
    final creatorId = widget.post.creatorId ?? '';
    final isFollowing = profileProvider.isFollowing(creatorId);
    final isFollowLoading = profileProvider.isFollowLoading(creatorId);

    // Resolve effective TRK code (App ID)
    String? effectiveTrk = widget.post.creatorTrkCode;
    if (effectiveTrk == null || effectiveTrk.trim().isEmpty) {
      if (isMe) {
        effectiveTrk = LocalStorage.instance.getUserTrkCode() ??
            profileProvider.currentProfile?.trkCode;
      } else if (creatorId.isNotEmpty) {
        effectiveTrk = FeedHeaderUserTrkCache.get(creatorId);
      }
    }
    effectiveTrk = effectiveTrk?.trim();

    final hasTrk = effectiveTrk != null && effectiveTrk.isNotEmpty;
    final hasCategory = widget.post.creatorCategory != null &&
        widget.post.creatorCategory!.trim().isNotEmpty;
    final hasLocation = widget.post.location.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _navigateToProfile(context),
            child: UserAvatar(
              imageUrl: widget.post.creatorPic,
              name: widget.post.creatorName,
              radius: 22,
              fontSize: 16,
              backgroundColor: AppColors.whiteShade,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _navigateToProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.post.creatorName,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hasLocation || hasTrk || hasCategory)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (hasLocation) ...[
                            Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: subColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: subColor,
                              ),
                            ),
                            if (hasTrk || hasCategory) ...[
                              const SizedBox(width: 6),
                              Text(
                                '•  ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subColor,
                                ),
                              ),
                            ],
                          ],
                          if (hasTrk) ...[
                            Text(
                              effectiveTrk,
                              style: TextStyle(
                                fontSize: 12,
                                color: subColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (hasCategory) ...[
                              Text(
                                ' - ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                          if (hasCategory)
                            Text(
                              widget.post.creatorCategory!,
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Follow Button (hidden for current user's own posts)
          if (!isMe && creatorId.isNotEmpty) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isFollowLoading
                  ? null
                  : () async {
                      try {
                        final newFollowing =
                            await profileProvider.toggleFollowUser(creatorId,
                                userName: widget.post.creatorName);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newFollowing
                                    ? 'Following ${widget.post.creatorName}'
                                    : 'Unfollowed ${widget.post.creatorName}',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to update follow status. Please try again.'),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isFollowing
                      ? (isDark
                          ? const Color(0xFF222222)
                          : const Color(0xFFE2E8F0))
                      : (isDark ? const Color(0xFF141414) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFollowing
                        ? Colors.transparent
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : const Color(0xFFCBD5E1)),
                    width: 1,
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
                        style: TextStyle(
                          color: isFollowing
                              ? (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569))
                              : (isDark ? Colors.white : AppColors.black),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: iconColor,
            ),
            onPressed: () => _showMoreOptions(context),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
