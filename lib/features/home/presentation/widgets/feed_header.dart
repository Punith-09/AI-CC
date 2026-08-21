import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final hasValidCreatorPic = post.creatorPic != null &&
        post.creatorPic!.isNotEmpty &&
        post.creatorPic!.startsWith('http');

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: hasValidCreatorPic
                ? NetworkImage(post.creatorPic!)
                : const AssetImage('assets/images/profile4.jpeg') as ImageProvider,
            onBackgroundImageError: hasValidCreatorPic
                ? (exception, stackTrace) {
                    // Gracefully fallback when avatar URL gives 404
                  }
                : null,
            child: post.creatorName.isNotEmpty
                ? Text(
                    post.creatorName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 2),
                Row(
                  children: [
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
                    if (post.creatorCategory != null &&
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
                    ],
                  ],
                ),
              ],
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