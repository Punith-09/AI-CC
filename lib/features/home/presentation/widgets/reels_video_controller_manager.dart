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
///    available bandwidth with high priority. Upcoming video (N+1) preloads
///    sequentially ONLY after the active video is ready, eliminating bandwidth contention.
/// 2. Fault Tolerance: 15s timeout with backoff retry for active videos.
/// 3. Error Isolation: Failures in background preloading are silent and NEVER mark
///    the video as failed for the user. When the user swipes to that video, it
///    triggers a fresh active load.
/// 4. URL Optimization: Applies dynamic Cloudinary mobile transformations (`q_auto,w_720,c_limit,f_mp4`)
///    and encodes spaces.
/// 5. Resource Management: Keeps at most 2 controllers in memory:
///    `[currentIndex, currentIndex + 1]` to prevent hardware decoder saturation on mobile devices.
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

  static Uri? _parseUri(String url) {
    if (url.trim().isEmpty) return null;
    final escaped = url.trim().replaceAll(' ', '%20');
    try {
      final uri = Uri.parse(escaped);
      if (uri.hasScheme) return uri;
    } catch (_) {}
    return null;
  }

  /// Extracts ordered candidate URIs to try for playback:
  /// 1. Cloudinary optimized stream (q_auto, w_720, c_limit) for fast start & low data.
  /// 2. Raw fallback stream directly from source (guarantees playback if on-the-fly transformation fails on large/long videos).
  static List<Uri> getCandidateUris(FeedPostModel post) {
    final List<Uri> candidates = [];

    final raw = ApiEndpoints.formatMediaUrl(post.mediaUrl).trim();
    final optimized = ApiEndpoints.optimizeVideoUrl(post.mediaUrl).trim();

    if (optimized.isNotEmpty) {
      final optUri = _parseUri(optimized);
      if (optUri != null) candidates.add(optUri);
    }

    if (raw.isNotEmpty) {
      final rawUri = _parseUri(raw);
      if (rawUri != null && !candidates.contains(rawUri)) {
        candidates.add(rawUri);
      }
    }

    return candidates;
  }

  /// Safely sanitizes raw media URL into a valid URI.
  static Uri? sanitizeVideoUri(String rawUrl) {
    if (rawUrl.trim().isEmpty) return null;
    final optimized = ApiEndpoints.optimizeVideoUrl(rawUrl);
    return _parseUri(optimized) ?? _parseUri(ApiEndpoints.formatMediaUrl(rawUrl));
  }

  /// Loads the ACTIVE video with MAXIMUM priority.
  /// Tries optimized URL first; if it fails or times out (common for large Cloudinary videos),
  /// immediately falls back to the original raw video stream.
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

    final candidates = getCandidateUris(post);
    if (candidates.isEmpty) {
      _failedIndices.add(index);
      _loadingCompleters.remove(index);
      completer.complete(false);
      return false;
    }

    bool success = false;

    for (int cIdx = 0; cIdx < candidates.length; cIdx++) {
      final uri = candidates[cIdx];
      final isLastCandidate = cIdx == candidates.length - 1;
      // If we have a fallback available, don't stall on candidate 1 for 15s; give candidate 1 (transformed) 7 seconds.
      // If it's stuck or fails, immediately try candidate 2 (raw) with 20 seconds!
      final timeoutDuration = (!isLastCandidate)
          ? const Duration(seconds: 7)
          : const Duration(seconds: 20);

      try {
        _controllers[index]?.dispose();
        _controllers.remove(index);

        final controller = VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
          httpHeaders: kIsWeb
              ? const {}
              : const {
                  'User-Agent': 'TreeKo/1.0.8 (Mobile; Android)',
                  'Accept': '*/*',
                },
        );

        _controllers[index] = controller;

        await controller.initialize().timeout(timeoutDuration);
        await controller.setLooping(true);
        await controller.setVolume(_isMuted ? 0.0 : 1.0);

        _failedIndices.remove(index);
        success = true;
        break;
      } catch (e) {
        debugPrint('[REELS_ACTIVE] Candidate $uri failed for index $index: $e');
        _controllers[index]?.dispose();
        _controllers.remove(index);
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

  /// Silently preloads upcoming video in the background.
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

    final candidates = getCandidateUris(post);
    if (candidates.isEmpty) return false;

    final completer = Completer<bool>();
    _loadingCompleters[index] = completer;

    bool success = false;
    for (int cIdx = 0; cIdx < candidates.length; cIdx++) {
      if (_sequenceId != seqId) break;
      final uri = candidates[cIdx];
      final isLastCandidate = cIdx == candidates.length - 1;
      final timeoutDuration = (!isLastCandidate)
          ? const Duration(seconds: 6)
          : const Duration(seconds: 15);

      try {
        final controller = VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
          httpHeaders: kIsWeb
              ? const {}
              : const {
                  'User-Agent': 'TreeKo/1.0.8 (Mobile; Android)',
                  'Accept': '*/*',
                },
        );

        _controllers[index] = controller;

        await controller.initialize().timeout(timeoutDuration);
        await controller.setLooping(true);
        await controller.setVolume(_isMuted ? 0.0 : 1.0);
        await controller.pause(); // frame 0 ready

        if (_sequenceId == seqId) {
          success = true;
          break;
        } else {
          // User moved far away, dispose
          controller.dispose();
          _controllers.remove(index);
          break;
        }
      } catch (e) {
        debugPrint('[REELS_PRELOAD_BG] Candidate $uri failed for index $index: $e');
        _controllers[index]?.dispose();
        _controllers.remove(index);
      }
    }

    _loadingCompleters.remove(index);
    if (!completer.isCompleted) {
      completer.complete(success);
    }

    return success;
  }

  /// Updates the sliding window around [currentIndex] using a prioritized pipeline.
  ///
  /// On mobile devices, keeps strictly 2 controllers [currentIndex, currentIndex + 1]
  /// to ensure 100% bandwidth for the active video and prevent hardware decoder exhaustion.
  void updateWindow(int currentIndex, List<FeedPostModel> posts) {
    if (posts.isEmpty) return;

    final currentSeq = ++_sequenceId;
    final next1 = currentIndex + 1;

    // Evict controllers outside [currentIndex, next1]
    final allowed = {currentIndex, next1};
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

        // Step 2: Once active video is ready and user is still on it, preload ONLY N+1
        if (next1 < posts.length) {
          _preloadBackground(next1, posts[next1], currentSeq);
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

  /// Immediately pauses every controller and silences their audio.
  /// Call this whenever the user navigates away from the Reels screen.
  void pauseAll() {
    for (final ctrl in _controllers.values) {
      if (ctrl.value.isInitialized) {
        ctrl.setVolume(0.0);
        ctrl.pause();
      }
    }
  }

  /// Pauses every controller EXCEPT [activeIndex], which is left for the
  /// caller to play. Used when swiping between reels to enforce 1-at-a-time playback.
  void playOnly(int activeIndex) {
    for (final entry in _controllers.entries) {
      if (entry.key != activeIndex && entry.value.value.isInitialized) {
        entry.value.setVolume(0.0);
        entry.value.pause();
      }
    }
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
