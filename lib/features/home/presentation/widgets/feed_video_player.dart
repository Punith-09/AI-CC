import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';

class FeedVideoPlayer extends StatefulWidget {
  final FeedPostModel post;

  const FeedVideoPlayer({
    super.key,
    required this.post,
  });

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _hasError = false;
  bool _showControls = false;
  bool _hasIncrementedView = false;
  Timer? _hideControlsTimer;

  String get effectiveVideoUrl =>
      ApiEndpoints.formatMediaUrl(widget.post.mediaUrl);

  String get effectiveThumbUrl =>
      ApiEndpoints.formatMediaUrl(widget.post.thumbnailUrl ?? widget.post.mediaUrl);

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startPlayback() async {
    if (_controller != null && _isInitialized) {
      _togglePlayPause();
      return;
    }

    if (effectiveVideoUrl.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final uri = Uri.parse(effectiveVideoUrl);
      _controller = VideoPlayerController.networkUrl(uri);

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();

      _controller!.addListener(_onPlayerStateChanged);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _isPlaying = true;
          _showControls = true;
        });

        _scheduleHideControls();
      }

      // Record view count once per video session
      if (!_hasIncrementedView && widget.post.id.isNotEmpty) {
        _hasIncrementedView = true;
        sl<HomeRepository>().incrementVideoView(widget.post.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onPlayerStateChanged() {
    if (!mounted || _controller == null) return;

    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) {
      _startPlayback();
      return;
    }

    setState(() {
      _showControls = true;
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });

    _scheduleHideControls();
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      _showControls = true;
    });

    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      color: const Color(0xFF0F1722),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Video Layer or Thumbnail Layer
          if (_isInitialized && _controller != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
                if (_showControls) {
                  _scheduleHideControls();
                }
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0
                      ? _controller!.value.aspectRatio
                      : (16 / 9),
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            _buildThumbnail(),

          // 2. Loading / Buffering Indicator
          if (_isLoading || (_isInitialized && _controller?.value.isBuffering == true))
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(
                    color: Color(0xFF8E3CF7),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // 3. Error Overlay with Retry
          if (_hasError)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 38,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unable to load video stream',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    // ElevatedButton.icon(
                    //   onPressed: _startPlayback,
                    //   style: ElevatedButton.styleFrom(
                    //
                    //     backgroundColor: AppColors.primary,
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 8,
                    //     ),
                    //   ),
                    //   icon: const Icon(Icons.refresh_rounded, size: 16),
                    //   label: const Text('Retry', style: TextStyle(fontSize: 12)),
                    // ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color(0xFF7C4DFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _startPlayback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Retry',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ),

          // 4. Initial Play Button Overlay (when not yet playing)
          if (!_isInitialized && !_isLoading && !_hasError)
            GestureDetector(
              onTap: _startPlayback,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E3CF7), Color(0xFFCC3EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E3CF7).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

          // 5. Center Play/Pause transient indicator when playing
          if (_isInitialized && _showControls && !_isLoading)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

          // 6. Top-Right "VIDEO" Pill Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    LucideIcons.video,
                    color: Colors.white,
                    size: 13,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. Bottom-Right Sound / Mute Toggle Button
          if (_isInitialized)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

          // 8. Bottom Video Progress Bar
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF8E3CF7),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumb = effectiveThumbUrl;
    final isNetwork = thumb.startsWith('http');

    return GestureDetector(
      onTap: _startPlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isNetwork)
            Image.network(
              thumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _buildFallbackThumbnail();
              },
            )
          else if (thumb.isNotEmpty)
            Image.asset(
              thumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
            )
          else
            _buildFallbackThumbnail(),

          // Dark vignette overlay for contrast
          Container(
            color: Colors.black.withValues(alpha: 0.28),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      color: const Color(0xFF141F2B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.film,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.title.isNotEmpty ? widget.post.title : 'Video Clip',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
