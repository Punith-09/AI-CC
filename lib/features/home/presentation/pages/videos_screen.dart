import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/comments_bottom_sheet.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feed = context.read<HomeFeedProvider>();
      if (!feed.hasFetchedVideos && !feed.isVideoLoading) {
        feed.fetchVideos();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<HomeFeedProvider>();
    final videoPosts = feedProvider.videoPosts;
    final isVideoLoading = feedProvider.isVideoLoading;
    final isLoadingMore = feedProvider.isLoadingMoreVideos;
    final errorMessage = feedProvider.videoErrorMessage;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    Widget body;

    if (isVideoLoading && videoPosts.isEmpty) {
      body = const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    } else if (errorMessage != null && videoPosts.isEmpty) {
      body = ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => feedProvider.fetchVideos(isRefresh: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (videoPosts.isEmpty) {
      body = ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.video_library_outlined,
                color: Colors.white54,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'No videos yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to share an audition or reel video!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => feedProvider.fetchVideos(isRefresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    } else {
      final totalCount = videoPosts.length + (isLoadingMore ? 1 : 0);

      body = ColoredBox(
        color: Colors.black,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Colors.black,
          onRefresh: () async {
            await feedProvider.fetchVideos(isRefresh: true);
            if (mounted && _pageController.hasClients) {
              _pageController.jumpToPage(0);
              setState(() {
                _currentPage = 0;
              });
            }
          },
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: totalCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              if (index >= videoPosts.length - 2) {
                feedProvider.fetchMoreVideos();
              }
            },
            itemBuilder: (context, index) {
              if (index >= videoPosts.length) {
                return const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }
              return _ReelVideoItem(
                key: ValueKey(videoPosts[index].id),
                post: videoPosts[index],
                isCurrent: _currentPage == index,
                isMuted: _isMuted,
                onToggleMute: _toggleMute,
              );
            },
          ),
        ),
      );
    }

    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: body,
        ),
      );
    }

    return body;
  }
}

class _ReelVideoItem extends StatefulWidget {
  final FeedPostModel post;
  final bool isCurrent;
  final bool isMuted;
  final VoidCallback onToggleMute;

  const _ReelVideoItem({
    super.key,
    required this.post,
    required this.isCurrent,
    required this.isMuted,
    required this.onToggleMute,
  });

  @override
  State<_ReelVideoItem> createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<_ReelVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = true;
  bool _hasIncrementedView = false;

  String get effectiveMediaUrl =>
      ApiEndpoints.formatMediaUrl(widget.post.mediaUrl);

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant _ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCurrent && !oldWidget.isCurrent) {
      if (_controller != null && _isInitialized) {
        _controller!.play();
        _incrementViewIfNeeded();
      }
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _controller?.pause();
    }

    if (widget.isMuted != oldWidget.isMuted) {
      _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    if (_isPlaying != isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  Future<void> _initController() async {
    if (effectiveMediaUrl.isEmpty ||
        !FeedPostModel.isVideoMediaUrl(effectiveMediaUrl, category: widget.post.category)) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
      return;
    }

    try {
      final uri = Uri.parse(effectiveMediaUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);

      controller.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _isPlaying = widget.isCurrent;
        });

        if (widget.isCurrent) {
          controller.play();
          _incrementViewIfNeeded();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _incrementViewIfNeeded() {
    if (!_hasIncrementedView && widget.post.id.isNotEmpty) {
      _hasIncrementedView = true;
      try {
        sl<HomeRepository>().incrementVideoView(widget.post.id);
      } catch (_) {}
    }
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;

    final wasPlaying = _isPlaying || _controller!.value.isPlaying;

    setState(() {
      _isPlaying = !wasPlaying;
    });

    try {
      if (wasPlaying) {
        await _controller!.pause();
      } else {
        await _controller!.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.white),
                title: const Text('Copy Link', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: effectiveMediaUrl));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video link copied to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: Colors.white),
                title: const Text('View Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.post.creatorId != null && widget.post.creatorId!.isNotEmpty) {
                    context.push(AppRoutes.exploreProfile, extra: widget.post.creatorId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(effectiveMediaUrl, subject: widget.post.title);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}hrs ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return 'Recent';
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final mediaBottom = MediaQuery.of(context).padding.bottom;
    // On mobile, Scaffold(extendBody: true) places the body behind the bottom navbar (~72px).
    // On web/desktop, there is no bottom navbar, so controls should be positioned cleanly at the bottom.
    final navClearance = isDesktop
        ? 0.0
        : (mediaBottom >= 64.0 ? mediaBottom : (72.0 + mediaBottom));
    final controlsBottom = isDesktop
        ? 16.0
        : (navClearance + 12.0);

    final isFollowing = context.watch<HomeFeedProvider>().isFollowing(widget.post.creatorId);
    final myUserId = LocalStorage.instance.getUserId();
    final isOwner = widget.post.creatorId != null &&
        widget.post.creatorId!.isNotEmpty &&
        widget.post.creatorId == myUserId;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Layer (pure visual, clicks handled above it)
        Container(
          color: Colors.black,
          child: _buildVideoContent(),
        ),

        // 2. Full-Screen Tap Recognizer for Play/Pause
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayPause,
          ),
        ),

        // 3. Play Button in Center when Paused (stays visible while paused)
        if (_isInitialized && !_isPlaying)
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),

        // 3. Top-Left Badge
        // Positioned(
        //   top: MediaQuery.of(context).padding.top + 10,
        //   left: 16,
        //   child: Container(
        //     padding: const EdgeInsets.all(6),
        //     decoration: BoxDecoration(
        //       color: Colors.black.withValues(alpha: 0.25),
        //       shape: BoxShape.circle,
        //     ),
        //     child: const Icon(
        //       Icons.workspace_premium_rounded,
        //       color: Color(0xFFFFB800),
        //       size: 28,
        //     ),
        //   ),
        // ),

        // 4. Subtle Gradient Shade at Bottom for Text Readability
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 220,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // 5. Right-Side Action Buttons (Mute, Like, Comment, Views, Share, More)
        Positioned(
          right: 12,
          bottom: controlsBottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mute / Unmute
              _ReelActionButton(
                icon: widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                iconColor: Colors.white,
                onTap: widget.onToggleMute,
              ),
              const SizedBox(height: 14),

              // Like
              _ReelActionButton(
                icon: widget.post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: widget.post.liked ? AppColors.favorite : Colors.white,
                label: '${widget.post.likesCount}',
                onTap: () {
                  context.read<HomeFeedProvider>().toggleLike(widget.post.id);
                },
              ),
              const SizedBox(height: 14),

              // Comment
              _ReelActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.white,
                label: '${widget.post.commentsCount}',
                onTap: () {
                  if (isDesktop) {
                    _controller?.pause();
                    context.push(
                      '${AppRoutes.watchVideo}?focusComment=true',
                      extra: widget.post,
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withValues(alpha: 0.65),
                      builder: (context) => CommentsBottomSheet(post: widget.post),
                    );
                  }
                },
              ),
              const SizedBox(height: 14),

              // Views
              _ReelActionButton(
                icon: Icons.remove_red_eye_outlined,
                iconColor: Colors.white,
                label: '${widget.post.viewsCount}',
                onTap: null,
              ),
              const SizedBox(height: 14),

              // Share
              _ReelActionButton(
                icon: Icons.near_me_outlined,
                iconColor: Colors.white,
                label: 'Share',
                onTap: () {
                  Share.share(effectiveMediaUrl, subject: widget.post.title);
                },
              ),
              const SizedBox(height: 14),

              // More (Three dots)
              _ReelActionButton(
                icon: Icons.more_horiz_rounded,
                iconColor: Colors.white,
                onTap: _showMoreOptions,
              ),
            ],
          ),
        ),

        // 6. Bottom-Left Information (Creator, Follow, Timestamp, Title/Caption)
        Positioned(
          left: 16,
          right: 76,
          bottom: controlsBottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator Row (Avatar, Name, Follow button)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.post.creatorId != null && widget.post.creatorId!.isNotEmpty) {
                        context.push(AppRoutes.exploreProfile, extra: widget.post.creatorId);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: UserAvatar(
                        radius: 17,
                        imageUrl: widget.post.creatorPic,
                        name: widget.post.creatorName,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.post.creatorId != null && widget.post.creatorId!.isNotEmpty) {
                          context.push(AppRoutes.exploreProfile, extra: widget.post.creatorId);
                        }
                      },
                      child: Text(
                        widget.post.creatorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isOwner && widget.post.creatorId != null && widget.post.creatorId!.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        context.read<HomeFeedProvider>().toggleFollowUser(widget.post.creatorId!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.2),
                          color: isFollowing
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // Timestamp (e.g. "20hrs ago")
              Text(
                _formatTimeAgo(widget.post.createdAt),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  shadows: [
                    Shadow(blurRadius: 3, color: Colors.black87),
                  ],
                ),
              ),

              // Title
              if (widget.post.title.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black87),
                    ],
                  ),
                ),
              ],

              // Description / Caption
              if (widget.post.description.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  widget.post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black87),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 7. Video Progress Line flush right on top of the navbar
        if (_controller != null && _isInitialized)
          Positioned(
            left: 0,
            right: 0,
            bottom: navClearance,
            child: SizedBox(
              height: 2.0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_hasError || _controller == null || !_isInitialized) {
      final thumbUrl = widget.post.thumbnailUrl;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (thumbUrl != null && thumbUrl.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.network(
                  ApiEndpoints.formatMediaUrl(thumbUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white54, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Could not load video',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _initController();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final isPortrait = _controller!.value.size.height >= _controller!.value.size.width;

    return Center(
      child: SizedBox.expand(
        child: FittedBox(
          fit: isPortrait ? BoxFit.cover : BoxFit.contain,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: IgnorePointer(
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReelActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? label;
  final VoidCallback? onTap;

  const _ReelActionButton({
    required this.icon,
    this.iconColor = Colors.white,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 26,
              color: iconColor,
              shadows: const [
                Shadow(blurRadius: 4, color: Colors.black87),
              ],
            ),
          ),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black87),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
