import 'package:flutter/material.dart';

import '../../api/api_endpoints.dart';
import '../../constants/app_colors.dart';
import '../../../features/home/data/models/feed_post_model.dart';
import 'media_downloader_stub.dart'
    if (dart.library.io) 'media_downloader_io.dart'
    if (dart.library.html) 'media_downloader_web.dart' as impl;

class MediaDownloader {
  MediaDownloader._();

  static Future<String> download({
    required String url,
    required String fileName,
    bool isVideo = false,
  }) async {
    return await impl.downloadFile(url, fileName, isVideo: isVideo);
  }

  static Future<void> downloadPostMedia(BuildContext context, FeedPostModel post) async {
    // Capture the ScaffoldMessenger upfront before any async operations or modal pops
    final messenger = ScaffoldMessenger.maybeOf(context);

    final rawUrl = post.mediaUrl;
    if (rawUrl.isEmpty) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('No media URL found to download.')),
      );
      return;
    }

    // For videos, use optimized download URL (compresses Cloudinary streams to 1080p H.264 MP4)
    final effectiveUrl = post.isVideo
        ? ApiEndpoints.optimizeVideoDownloadUrl(rawUrl)
        : ApiEndpoints.formatMediaUrl(rawUrl);

    // Determine clean file extension
    String ext = post.isVideo ? '.mp4' : '.jpg';
    if (!post.isVideo) {
      try {
        final uri = Uri.parse(effectiveUrl);
        final path = uri.path.toLowerCase();
        if (path.endsWith('.png')) {
          ext = '.png';
        } else if (path.endsWith('.jpeg')) {
          ext = '.jpeg';
        } else if (path.endsWith('.jpg')) {
          ext = '.jpg';
        } else if (path.endsWith('.webp')) {
          ext = '.webp';
        }
      } catch (_) {}
    }

    // Sanitize title to safe ASCII filename
    String cleanTitle = post.title.trim().replaceAll(RegExp(r'[^\w\-]'), '_');
    cleanTitle = cleanTitle.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (cleanTitle.length > 25) {
      cleanTitle = cleanTitle.substring(0, 25);
    }
    if (cleanTitle.isEmpty) {
      cleanTitle = post.isVideo ? 'video' : 'photo';
    }
    final fileName = '${cleanTitle}_${DateTime.now().millisecondsSinceEpoch}$ext';

    // Show persistent progress snackbar while downloading
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Downloading...'),
          ],
        ),
        duration: Duration(minutes: 5),
      ),
    );

    try {
      try {
        await MediaDownloader.download(
          url: effectiveUrl,
          fileName: fileName,
          isVideo: post.isVideo,
        );
      } catch (firstError) {
        // Fall back to original raw URL if Cloudinary transformation fails on large videos
        final rawFallback = ApiEndpoints.formatMediaUrl(rawUrl);
        if (rawFallback != effectiveUrl) {
          await MediaDownloader.download(
            url: rawFallback,
            fileName: fileName,
            isVideo: post.isVideo,
          );
        } else {
          rethrow;
        }
      }

      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Downloaded Successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger?.hideCurrentSnackBar();
      final rawMsg = e.toString().replaceFirst('Exception: ', '').trim();
      final displayMsg = (rawMsg.isNotEmpty && !rawMsg.startsWith('DioException'))
          ? rawMsg
          : 'Failed to download media. Please try again.';
      messenger?.showSnackBar(
        SnackBar(
          content: Text(displayMsg),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
