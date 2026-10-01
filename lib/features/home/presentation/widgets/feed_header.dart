import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/feed_post_model.dart';
import '../providers/home_feed_provider.dart';

class FeedHeader extends StatelessWidget {
  final FeedPostModel post;

  const FeedHeader({
    super.key,
    required this.post,
  });

  void _navigateToProfile(BuildContext context) {
    final targetUserId = post.creatorId;
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
        (post.creatorName.isNotEmpty &&
            currentUserName != null &&
            post.creatorName.trim().toLowerCase() ==
                currentUserName.trim().toLowerCase());

    if (isMe) {
      context.push(AppRoutes.artistProfile);
      return;
    }

    if (targetUserId != null && targetUserId.isNotEmpty) {
      context.push(AppRoutes.exploreProfile, extra: targetUserId);
    }
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

    final targetUserId = post.creatorId;
    final isMe = (targetUserId != null &&
            targetUserId.isNotEmpty &&
            currentUserId != null &&
            targetUserId == currentUserId) ||
        (post.creatorName.isNotEmpty &&
            currentUserName != null &&
            post.creatorName.trim().toLowerCase() ==
                currentUserName.trim().toLowerCase());

    final feedProvider = context.watch<HomeFeedProvider>();
    final creatorId = post.creatorId ?? '';
    final isFollowing = feedProvider.isFollowing(creatorId);
    final isFollowLoading = feedProvider.isFollowLoading(creatorId);

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _navigateToProfile(context),
            child: UserAvatar(
              imageUrl: post.creatorPic,
              name: post.creatorName,
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
                          post.creatorName,
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
                  if (post.location.isNotEmpty ||
                      (post.creatorCategory != null &&
                          post.creatorCategory!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (post.location.isNotEmpty) ...[
                            Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: subColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: subColor,
                              ),
                            ),
                          ],
                          if (post.location.isNotEmpty &&
                              post.creatorCategory != null &&
                              post.creatorCategory!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•  ${post.creatorCategory}',
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else if (post.creatorCategory != null &&
                              post.creatorCategory!.isNotEmpty) ...[
                            Text(
                              post.creatorCategory!,
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
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
                            await feedProvider.toggleFollowUser(creatorId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newFollowing
                                    ? 'Following ${post.creatorName}'
                                    : 'Unfollowed ${post.creatorName}',
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

          Icon(
            Icons.more_vert,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}