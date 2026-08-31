import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/feed_post_model.dart';
import 'feed_video_player.dart';

class FeedImage extends StatelessWidget {
  final FeedPostModel post;

  const FeedImage({
    super.key,
    required this.post,
  });

  void _openWatchMedia(BuildContext context) {
    context.push(AppRoutes.watchVideo, extra: post);
  }

  @override
  Widget build(BuildContext context) {
    if (post.isVideo) {
      return ClipRRect(
        child: FeedVideoPlayer(
          post: post,
          onTapMedia: () => _openWatchMedia(context),
        ),
      );
    }

    final formattedMediaUrl = ApiEndpoints.formatMediaUrl(post.mediaUrl);
    final isNetwork = formattedMediaUrl.startsWith('http');

    return GestureDetector(
      onTap: () => _openWatchMedia(context),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        child: Container(
          width: double.infinity,
          color: const Color(0xFF1B2330),
          child: isNetwork
              ? Image.network(
                  formattedMediaUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorWidget();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const SizedBox(
                      height: 260,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Image.asset(
                  formattedMediaUrl.isNotEmpty
                      ? formattedMediaUrl
                      : 'assets/images/post1.jpeg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 260,
      color: const Color(0xFF15222E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.image,
              color: Colors.white38,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              post.title.isNotEmpty ? post.title : 'Photo',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}