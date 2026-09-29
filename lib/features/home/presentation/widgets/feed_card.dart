import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/feed_post_model.dart';
import 'feed_actions.dart';
import 'feed_caption.dart';
import 'feed_header.dart';
import 'feed_image.dart';

class FeedCard extends StatelessWidget {
  final FeedPostModel post;

  const FeedCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedHeader(post: post),
          const SizedBox(height: 12),
          FeedImage(post: post),
          const SizedBox(height: 12),
          FeedActions(post: post),
          const SizedBox(height: 8),
          FeedCaption(post: post),
        ],
      ),
    );
  }
}