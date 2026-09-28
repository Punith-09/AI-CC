import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/feed_post_model.dart';

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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final titleColor = AppColors.black;
    final subColor = AppColors.black;
    final accentColor = isDesktop ? const Color(0xFF8E3CF7) : AppColors.primary;
    final iconColor = AppColors.black;

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
              backgroundColor: AppColors.whiteShade
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
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8E3CF7),
                  width: 1.2,
                ),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Color(0xFF8E3CF7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Icon(
            Icons.more_horiz,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}