import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../data/models/feed_post_model.dart';

/// Centralized manager for preloading, prioritizing, and caching
/// VideoPlayerControllers in vertical reels feeds (TikTok / Instagram style).
///
/// Features:
/// 1. Prioritized Pipeline: The active video (what the user sees) gets 100% of
///    available bandwidth with high priority. Upcoming videos (N+1, N+2) preload
///    sequentially ONLY after the active video is ready, eliminating bandwidth contention.
/// 2. Fault Tolerance: Generous timeouts (30s) + exponential backoff retries for active videos.
/// 3. Error Isolation: Failures in background preloading are silent and NEVER mark
///    the video as failed for the user. When the user swipes to that video, it
///    triggers a fresh active load.
/// 4. URL Sanitization: Safely encodes spaces and malformed characters in media URLs.
/// 5. Resource Management: Keeps at most 4 controllers in memory:
///    `[currentIndex - 1, currentIndex, currentIndex + 1, currentIndex + 2]`
///    and disposes out-of-window controllers immediately to prevent decoder saturation.
class ReelsVideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, Completer<bool>> _loadingCompleters = {};
  final Set<int> _failedIndices = {};
  bool _isMuted = false;

  int _sequenceId = 0;

  bool get isMuted => _isMuted;

  void setMuted(bool muted) {
    _isMuted = muted;
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) {
        controller.setVolume(muted ? 0.0 : 1.0);
      }
    }
  }

  VideoPlayerController? getController(int index) {
    return _controllers[index];
  }

  bool isInitialized(int index) {
    final ctrl = _controllers[index];
    return ctrl != null && ctrl.value.isInitialized;
  }

  bool hasFailed(int index) {
    return _failedIndices.contains(index);
  }

  bool isLoading(int index) {
    return _loadingCompleters.containsKey(index);
  }

  /// Safely sanitizes raw media URLs into valid URIs.
  static Uri? sanitizeVideoUri(String rawUrl) {
    if (rawUrl.trim().isEmpty) return null;
    final formatted = ApiEndpoints.formatMediaUrl(rawUrl).trim();
    if (formatted.isEmpty) return null;

    // Encode spaces to %20 so ExoPlayer and HTTP servers don't reject the request
    final escaped = formatted.replaceAll(' ', '%20');
    try {
      final uri = Uri.parse(escaped);
      if (!uri.hasScheme) return null;
      return uri;
    } catch (e) {
      debugPrint('[REELS_MANAGER] Failed to parse URI: $escaped ($e)');
      return null;
    }
  }

  /// Loads the ACTIVE video with MAXIMUM priority.
  /// Uses a generous 30-second timeout and up to 3 retry attempts with backoff.
  Future<bool> loadActive(int index, FeedPostModel post) async {
    _failedIndices.remove(index);

    // If already ready, return immediately
    final existing = _controllers[index];
    if (existing != null && existing.value.isInitialized) {
      return true;
    }

    // If an active load is already in flight, reuse its completer
    if (_loadingCompleters.containsKey(index)) {
      return _loadingCompleters[index]!.future;
    }

    final completer = Completer<bool>();
    _loadingCompleters[index] = completer;

    final uri = sanitizeVideoUri(post.mediaUrl);
    if (uri == null) {
      _failedIndices.add(index);
      _loadingCompleters.remove(index);
      completer.complete(false);
      return false;
    }

    bool success = false;
    const maxAttempts = 3;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // Clean up previous dead controller if any
        _controllers[index]?.dispose();
        _controllers.remove(index);

        final controller = VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        _controllers[index] = controller;

        // 30-second timeout for active video to accommodate slow mobile networks
        await controller.initialize().timeout(const Duration(seconds: 30));
        await controller.setLooping(true);
        await controller.setVolume(_isMuted ? 0.0 : 1.0);

        _failedIndices.remove(index);
        success = true;
        break;
      } catch (e) {
        debugPrint('[REELS_ACTIVE] Load attempt $attempt failed for index $index: $e');
        _controllers[index]?.dispose();
        _controllers.remove(index);

        if (attempt < maxAttempts) {
          // Exponential backoff between attempts: 500ms, 1500ms
          await Future.delayed(Duration(milliseconds: attempt * 750));
        }
      }
    }

    _loadingCompleters.remove(index);
    if (!success) {
      _failedIndices.add(index);
    }

    if (!completer.isCompleted) {
      completer.complete(success);
    }

    return success;
  }

  /// Silently preloads upcoming videos in the background.
  /// Failures are non-fatal and NEVER populate [_failedIndices].
  Future<bool> _preloadBackground(int index, FeedPostModel post, int seqId) async {
    // If sequence changed (user swiped away), abort
    if (_sequenceId != seqId) return false;

    // Already ready
    if (_controllers.containsKey(index) && _controllers[index]!.value.isInitialized) {
      return true;
    }

    // Already in flight
    if (_loadingCompleters.containsKey(index)) {
      return _loadingCompleters[index]!.future;
    }

    final uri = sanitizeVideoUri(post.mediaUrl);
    if (uri == null) return false;

    final completer = Completer<bool>();
    _loadingCompleters[index] = completer;

    bool success = false;
    try {
      final controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controllers[index] = controller;

      // 18-second timeout for background preloads
      await controller.initialize().timeout(const Duration(seconds: 18));
      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0.0 : 1.0);
      await controller.pause(); // frame 0 ready

      if (_sequenceId == seqId) {
        success = true;
      } else {
        // User moved far away, dispose
        controller.dispose();
        _controllers.remove(index);
      }
    } catch (e) {
      debugPrint('[REELS_PRELOAD_BG] Silent fail for index $index: $e');
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }

    _loadingCompleters.remove(index);
    if (!completer.isCompleted) {
      completer.complete(success);
    }

    return success;
  }

  /// Updates the sliding window around [currentIndex] using a prioritized pipeline.
  ///
  /// Sequential Preload Priority:
  /// 1. [currentIndex] (High Priority - 100% bandwidth)
  /// 2. [currentIndex + 1] (Next video - buffered only after active video is safe)
  /// 3. [currentIndex + 2] (Next-next video)
  void updateWindow(int currentIndex, List<FeedPostModel> posts) {
    if (posts.isEmpty) return;

    final currentSeq = ++_sequenceId;

    final prev1 = currentIndex - 1;
    final next1 = currentIndex + 1;
    final next2 = currentIndex + 2;

    // Evict controllers outside the sliding window [currentIndex - 1 .. currentIndex + 2]
    final allowed = {prev1, currentIndex, next1, next2};
    final toRemove = _controllers.keys.where((k) => !allowed.contains(k)).toList();
    for (final k in toRemove) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
      _loadingCompleters.remove(k);
      _failedIndices.remove(k);
    }

    // Step 1: Prioritize the active video first
    if (currentIndex >= 0 && currentIndex < posts.length) {
      loadActive(currentIndex, posts[currentIndex]).then((ready) {
        if (!ready || _sequenceId != currentSeq) return;

        // Step 2: Once active video is ready and user is still on it, preload N+1
        if (next1 < posts.length) {
          _preloadBackground(next1, posts[next1], currentSeq).then((readyNext1) {
            if (!readyNext1 || _sequenceId != currentSeq) return;

            // Step 3: Once N+1 is ready, preload N+2
            if (next2 < posts.length) {
              _preloadBackground(next2, posts[next2], currentSeq);
            }
          });
        }
      });
    }
  }

  Future<bool> retry(int index, FeedPostModel post) async {
    _controllers[index]?.dispose();
    _controllers.remove(index);
    _loadingCompleters.remove(index);
    _failedIndices.remove(index);
    return loadActive(index, post);
  }

  void disposeAll() {
    _sequenceId++;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _loadingCompleters.clear();
    _failedIndices.clear();
  }
}
