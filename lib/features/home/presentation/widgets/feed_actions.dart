import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/models/feed_post_model.dart';
import '../providers/home_feed_provider.dart';
import 'comments_bottom_sheet.dart';

class FeedActions extends StatefulWidget {
  final FeedPostModel post;

  const FeedActions({
    super.key,
    required this.post,
  });

  @override
  State<FeedActions> createState() => _FeedActionsState();
}

class _FeedActionsState extends State<FeedActions> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.liked;

    return Container(
      padding: const EdgeInsets.only(left: 14, top: 0, right: 14, bottom: 0),
      child: Row(
        children: [
          // Like Button
          IconButton(
            onPressed: () {
              context.read<HomeFeedProvider>().toggleLike(widget.post.id);
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: isLiked
                  ? const Icon(
                      Icons.favorite,
                      key: ValueKey('liked'),
                      size: 32,
                      color: Color(0xFFE940B7),
                      shadows: [
                        Shadow(
                          color: Color(0xFFE940B7),
                          blurRadius: 18,
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.favorite_border,
                      key: ValueKey('unliked'),
                      size: 32,
                      color: Colors.white,
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Comments Button
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color(0xFF102B36),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                builder: (context) {
                  return CommentsBottomSheet(post: widget.post);
                },
              );
            },
            icon: const Icon(
              LucideIcons.messageCircle,
              size: 26,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          // Share Button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.send,
              size: 25,
              color: Colors.white,
            ),
          ),

          const Spacer(),

          // Bookmark / Save Button
          IconButton(
            onPressed: () {
              setState(() {
                _saved = !_saved;
              });
            },
            icon: Icon(
              _saved ? Icons.bookmark : Icons.bookmark_border,
              size: 30,
              color: _saved ? const Color(0xFF8E3CF7) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}