import 'package:aicc/common/widgets/video_frame_thumbnail.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../home/data/models/feed_post_model.dart';
import '../../data/models/portfolio_model.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PortfolioCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanUrl = ApiEndpoints.formatMediaUrl(item.image);
    final isNetwork = cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    final isAsset = cleanUrl.startsWith('assets/');

    Widget buildVideoDarkPlaceholder() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
      );
    }

    Widget buildPhotoPlaceholder() {
      return Container(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: Icon(
          Icons.photo_outlined,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
          size: 32,
        ),
      );
    }

    // Resolve the video URL for thumbnail extraction
    String? videoThumbnailUrl;
    if (item.isVideo) {
      final rawVideo = (item.videoUrl != null && item.videoUrl!.isNotEmpty)
          ? item.videoUrl!
          : (FeedPostModel.isVideoMediaUrl(item.image) ? item.image : '');
      videoThumbnailUrl = rawVideo.isNotEmpty
          ? ApiEndpoints.formatMediaUrl(rawVideo)
          : null;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Media layer ──────────────────────────────────────────
                if (item.isVideo)
                  videoThumbnailUrl != null
                      ? VideoFrameThumbnail(
                          videoUrl: videoThumbnailUrl,
                          fallback: buildVideoDarkPlaceholder(),
                        )
                      : buildVideoDarkPlaceholder()
                else if (isNetwork)
                  Image.network(
                    cleanUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _e) => buildPhotoPlaceholder(),
                  )
                else if (isAsset)
                  Image.asset(
                    cleanUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _e) => buildPhotoPlaceholder(),
                  )
                else
                  buildPhotoPlaceholder(),

                // ── Play button overlay for videos ────────────────────
                if (item.isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),

                // ── Border overlay ────────────────────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 3-dot options menu ────────────────────────────────────────
        if (onDelete != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<String>(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                offset: const Offset(0, 34),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
