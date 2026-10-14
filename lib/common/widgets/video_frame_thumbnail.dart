import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Initializes a [VideoPlayerController], seeks to t=0 (the first frame),
/// renders the frame paused, and disposes the controller on widget removal.
/// Falls back to [fallback] while loading or upon error.
class VideoFrameThumbnail extends StatefulWidget {
  final String videoUrl;
  final Widget fallback;
  final BoxFit fit;

  const VideoFrameThumbnail({
    super.key,
    required this.videoUrl,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  State<VideoFrameThumbnail> createState() => _VideoFrameThumbnailState();
}

class _VideoFrameThumbnailState extends State<VideoFrameThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoFrameThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _initialized = false;
      _error = false;
      _initController();
    }
  }

  Future<void> _initController() async {
    try {
      final uri = Uri.tryParse(widget.videoUrl);
      if (uri == null || !uri.hasScheme) {
        if (mounted) setState(() => _error = true);
        return;
      }
      final ctrl = VideoPlayerController.networkUrl(uri);
      await ctrl.initialize();
      await ctrl.seekTo(Duration.zero);
      await ctrl.pause();
      if (mounted) {
        setState(() {
          _controller = ctrl;
          _initialized = true;
        });
      } else {
        await ctrl.dispose();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return widget.fallback;
    if (!_initialized || _controller == null) return widget.fallback;

    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
