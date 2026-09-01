import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/feed_post_model.dart';

class FeedCaption extends StatelessWidget {
  final FeedPostModel post;

  const FeedCaption({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final hasDesc = post.description.isNotEmpty;
    final captionText = post.title.isNotEmpty
        ? (hasDesc ? '${post.title} — ${post.description}' : post.title)
        : post.description;

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${post.likesCount} likes",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.5,
                color: Colors.white70,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: "${post.creatorName} ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      String? currentUserId;
                      String? currentUserName;
                      try {
                        currentUserId = LocalStorage.instance.getUserId();
                        currentUserName = LocalStorage.instance.getUserName();
                      } catch (_) {}

                      final isMe = (post.creatorId != null &&
                              post.creatorId!.isNotEmpty &&
                              currentUserId != null &&
                              post.creatorId == currentUserId) ||
                          (post.creatorName.isNotEmpty &&
                              currentUserName != null &&
                              post.creatorName.trim().toLowerCase() ==
                                  currentUserName.trim().toLowerCase());

                      if (isMe) {
                        context.push(AppRoutes.artistProfile);
                      } else if (post.creatorId != null && post.creatorId!.isNotEmpty) {
                        context.push(AppRoutes.exploreProfile, extra: post.creatorId);
                      }
                    },
                ),
                TextSpan(
                  text: captionText,
                ),
                if (post.hashtags != null && post.hashtags!.isNotEmpty) ...[
                  TextSpan(
                    text: " ${post.hashtags}",
                    style: const TextStyle(
                      color: Color(0xff4C8DFF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.timeAgo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}