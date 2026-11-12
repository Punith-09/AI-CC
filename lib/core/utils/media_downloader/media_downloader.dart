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
  }) async {
    return await impl.downloadFile(url, fileName);
  }

  static Future<void> downloadPostMedia(BuildContext context, FeedPostModel post) async {
    final rawUrl = post.mediaUrl;
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media URL found to download.')),
      );
      return;
    }

    final effectiveUrl = ApiEndpoints.formatMediaUrl(rawUrl);

    // Determine file extension
    String ext = post.isVideo ? '.mp4' : '.jpg';
    try {
      final uri = Uri.parse(effectiveUrl);
      final path = uri.path.toLowerCase();
      if (path.endsWith('.mp4')) {
        ext = '.mp4';
      } else if (path.endsWith('.mov')) {
        ext = '.mov';
      } else if (path.endsWith('.webm')) {
        ext = '.webm';
      } else if (path.endsWith('.png')) {
        ext = '.png';
      } else if (path.endsWith('.jpeg')) {
        ext = '.jpeg';
      } else if (path.endsWith('.jpg')) {
        ext = '.jpg';
      } else if (path.endsWith('.webp')) {
        ext = '.webp';
      }
    } catch (_) {}

    final safeTitle = post.title.trim().isNotEmpty
        ? post.title.trim().replaceAll(RegExp(r'[^\w\-]'), '_')
        : (post.id.isNotEmpty ? post.id : 'media_${DateTime.now().millisecondsSinceEpoch}');
    final fileName = '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}$ext';

    ScaffoldMessenger.of(context).showSnackBar(
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
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await MediaDownloader.download(
        url: effectiveUrl,
        fileName: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded successfully: $fileName'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download media. Please try again.'),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
