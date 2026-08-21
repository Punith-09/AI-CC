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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedHeader(post: post),
          const SizedBox(height: 14),
          FeedImage(post: post),
          const SizedBox(height: 14),
          FeedActions(post: post),
          const SizedBox(height: 10),
          FeedCaption(post: post),
        ],
      ),
    );
  }
}