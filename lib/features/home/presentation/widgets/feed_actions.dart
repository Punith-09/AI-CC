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

  /// Format large numbers: 1200 → "1.2k", 1_200_000 → "1.2M"
  String _formatCount(int count) {
    if (count >= 1000000) {
      final m = count / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.liked;
    final likesCount = widget.post.likesCount;
    final commentsCount = widget.post.commentsCount;

    return Container(
      padding: const EdgeInsets.only(left: 6, top: 0, right: 14, bottom: 0),
      child: Row(
        children: [
          // ── Like icon + count ──────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () =>
                    context.read<HomeFeedProvider>().toggleLike(widget.post.id),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: isLiked
                      ? const Icon(
                          Icons.favorite,
                          key: ValueKey('liked'),
                          size: 28,
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
                          size: 28,
                          color: Colors.white,
                        ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _formatCount(likesCount),
                  key: ValueKey(likesCount),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isLiked
                        ? const Color(0xFFE940B7)
                        : Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),

          // ── Comment icon + count ───────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF102B36),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    builder: (context) =>
                        CommentsBottomSheet(post: widget.post),
                  );
                },
                icon: const Icon(
                  LucideIcons.messageCircle,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              Text(
                _formatCount(commentsCount),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),

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