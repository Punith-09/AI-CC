import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/feed_post_model.dart';

class FeedHeader extends StatelessWidget {
  final FeedPostModel post;

  const FeedHeader({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    void navigateToProfile() {
      if (post.creatorId != null && post.creatorId!.isNotEmpty) {
        context.push(AppRoutes.exploreProfile, extra: post.creatorId);
      }
    }

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: navigateToProfile,
            child: UserAvatar(
              imageUrl: post.creatorPic,
              name: post.creatorName,
              radius: 22,
              fontSize: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: navigateToProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.creatorName,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
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
                          const Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        if (post.location.isNotEmpty &&
                            post.creatorCategory != null &&
                            post.creatorCategory!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '•  ${post.creatorCategory}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (post.creatorCategory != null &&
                            post.creatorCategory!.isNotEmpty) ...[
                          Text(
                            post.creatorCategory!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
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
        const Icon(
            Icons.more_horiz,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}