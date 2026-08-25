import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/feed_post_model.dart';
import 'feed_video_player.dart';

// class FeedImage extends StatelessWidget {
//   final FeedPostModel post;
//
//   const FeedImage({
//     super.key,
//     required this.post,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (post.isVideo) {
//       return ClipRRect(
//         child: FeedVideoPlayer(post: post),
//       );
//     }
//
//     final formattedMediaUrl = ApiEndpoints.formatMediaUrl(post.mediaUrl);
//     final isNetwork = formattedMediaUrl.startsWith('http');
//
//     return ClipRRect(
//       child: Container(
//         width: double.infinity,
//         height: 260,
//         color: const Color(0xFF1B2330),
//         child: isNetwork
//             ? Image.network(
//                 formattedMediaUrl,
//                 width: double.infinity,
//                 height: 260,
//                 fit: BoxFit.fill,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: const Color(0xFF15222E),
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             LucideIcons.image,
//                             color: Colors.white38,
//                             size: 40,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             post.title.isNotEmpty ? post.title : 'Photo',
//                             style: const TextStyle(
//                               color: Colors.white54,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     color: const Color(0xFF15222E),
//                     child: const Center(
//                       child: SizedBox(
//                         width: 28,
//                         height: 28,
//                         child: CircularProgressIndicator(
//                           color: AppColors.primary,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : Image.asset(
//                 formattedMediaUrl.isNotEmpty
//                     ? formattedMediaUrl
//                     : 'assets/images/post1.jpeg',
//                 width: double.infinity,
//                 height: 260,
//                 fit: BoxFit.cover,
//               ),
//       ),
//     );
//   }
// }




class FeedImage extends StatelessWidget {
  final FeedPostModel post;

  const FeedImage({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    if (post.isVideo) {
      return ClipRRect(
        child: FeedVideoPlayer(post: post),
      );
    }

    final formattedMediaUrl =
    ApiEndpoints.formatMediaUrl(post.mediaUrl);

    final isNetwork = formattedMediaUrl.startsWith('http');

    return ClipRRect(
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