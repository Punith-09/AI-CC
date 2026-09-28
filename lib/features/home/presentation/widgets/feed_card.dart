import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: isDesktop ? Colors.white : AppColors.card,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 22),
        border: Border.all(
          color: isDesktop ? const Color(0xFFE5E7EB) : Colors.white10,
          width: 1,
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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