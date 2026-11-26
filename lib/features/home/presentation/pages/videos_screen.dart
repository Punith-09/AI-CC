import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/media_downloader/media_downloader.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/reels_video_controller_manager.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> with WidgetsBindingObserver {
  late final PageController _pageController;
  late final ReelsVideoControllerManager _preloadManager;
  int _currentPage = 0;
  bool _isMuted = false;
  int _lastLoadedPage = -1;
  int _lastPostsCount = 0;

  // GoRouter listener – detects tab switches and pushed routes
  VoidCallback? _routerListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _preloadManager = ReelsVideoControllerManager();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feed = context.read<HomeFeedProvider>();
      if (!feed.hasFetchedVideos && !feed.isVideoLoading) {
        feed.fetchVideos();
      } else if (feed.videoPosts.isNotEmpty) {
        _preloadManager.updateWindow(0, feed.videoPosts);
      }

      // Start listening to route changes so we can pause when navigating away
      _attachRouterListener();
    });
  }

  void _attachRouterListener() {
    if (!mounted) return;
    final router = GoRouter.of(context);
    _routerListener = () {
      if (!mounted) return;
      final location = router.routerDelegate.currentConfiguration.uri.toString();
      // If the current top route is NOT the videos tab, pause everything
      if (location != AppRoutes.videos) {
        _preloadManager.pauseAll();
      }
    };
    router.routerDelegate.addListener(_routerListener!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause all video when app goes to background / becomes inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _preloadManager.pauseAll();
    }
  }

  @override
  void dispose() {
    // Remove GoRouter listener
    if (_routerListener != null && mounted) {
      try {
        GoRouter.of(context).routerDelegate.removeListener(_routerListener!);
      } catch (_) {}
    }
    WidgetsBinding.instance.removeObserver(this);
    _preloadManager.pauseAll();
    _pageController.dispose();
    _preloadManager.disposeAll();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _preloadManager.setMuted(_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<HomeFeedProvider>();
    final videoPosts = feedProvider.videoPosts;
    final isVideoLoading = feedProvider.isVideoLoading;
    final isLoadingMore = feedProvider.isLoadingMoreVideos;
    final errorMessage = feedProvider.videoErrorMessage;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // Keep preloading sliding window updated when page or post list changes (deferred to post-frame)
    if (videoPosts.isNotEmpty &&
        (_lastLoadedPage != _currentPage || _lastPostsCount != videoPosts.length)) {
      _lastLoadedPage = _currentPage;
      _lastPostsCount = videoPosts.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _preloadManager.updateWindow(_currentPage, videoPosts);
        }
      });
    }

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
              _preloadManager.updateWindow(0, feedProvider.videoPosts);
            }
          },
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: totalCount,
            onPageChanged: (index) {
              _lastLoadedPage = index;
              setState(() {
                _currentPage = index;
              });
              // Stop every other reel immediately when user swipes
              _preloadManager.playOnly(index);
              _preloadManager.updateWindow(index, videoPosts);
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
              final post = videoPosts[index];
              return _ReelVideoItem(
                key: ValueKey('reel_${post.id}_$index'),
                index: index,
                post: post,
                isCurrent: _currentPage == index,
                isMuted: _isMuted,
                isFollowing: feedProvider.isFollowing(post.creatorId),
                onToggleMute: _toggleMute,
                manager: _preloadManager,
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
  final int index;
  final FeedPostModel post;
  final bool isCurrent;
  final bool isMuted;
  final bool isFollowing;
  final VoidCallback onToggleMute;
  final ReelsVideoControllerManager manager;

  const _ReelVideoItem({
    super.key,
    required this.index,
    required this.post,
    required this.isCurrent,
    required this.isMuted,
    required this.isFollowing,
    required this.onToggleMute,
    required this.manager,
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
  bool _isBuffering = false;
  bool _hasIncrementedView = false;

  String get effectiveMediaUrl =>
      ApiEndpoints.optimizeVideoUrl(widget.post.mediaUrl);

  String? get effectiveThumbUrl {
    // 1. Prioritize video starting frame (frame 0) from video URL
    final startingFrame =
        ApiEndpoints.getVideoStartingFrameUrl(widget.post.mediaUrl);
    if (startingFrame != null && startingFrame.isNotEmpty) {
      return startingFrame;
    }

    // 2. Fall back to custom thumbnail only if it is not the default clapperboard/stock placeholder
    final thumb = widget.post.thumbnailUrl;
    if (thumb != null && thumb.trim().isNotEmpty) {
      final formatted = ApiEndpoints.formatMediaUrl(thumb).trim();
      if (!ApiEndpoints.isDefaultClapperboardOrPlaceholder(formatted)) {
        return formatted;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _syncWithManager();
  }

  @override
  void didUpdateWidget(covariant _ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index || oldWidget.post.id != widget.post.id) {
      _controller?.removeListener(_onControllerUpdate);
      _syncWithManager();
    } else {
      if (widget.isCurrent && !oldWidget.isCurrent) {
        // User swiped to this reel
        if (_controller != null && _isInitialized) {
          _playCurrentVideo();
        } else {
          // If not initialized yet, immediately promote to active high-priority loading!
          _syncWithManager(forceActive: true);
        }
      } else if (!widget.isCurrent && oldWidget.isCurrent) {
        _pauseCurrentVideo();
      }

      if (widget.isMuted != oldWidget.isMuted) {
        _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
      }
    }
  }

  void _syncWithManager({bool forceActive = false}) {
    final manager = widget.manager;
    final index = widget.index;
    final isTargetActive = widget.isCurrent || forceActive;

    final existingCtrl = manager.getController(index);

    if (existingCtrl != null && existingCtrl.value.isInitialized) {
      // PRELOAD HIT! Instant zero-lag playback!
      _controller = existingCtrl;
      _isInitialized = true;
      _isLoading = false;
      _hasError = false;
      _isPlaying = isTargetActive;

      _controller!.removeListener(_onControllerUpdate);
      _controller!.addListener(_onControllerUpdate);

      if (isTargetActive) {
        _playCurrentVideo();
      }
      return;
    }

    if (isTargetActive) {
      // High-priority active load for current video
      _controller = null;
      _isInitialized = false;
      _isLoading = true;
      _hasError = false;

      manager.loadActive(index, widget.post).then((success) {
        if (!mounted || widget.index != index) return;
        if (success) {
          final newCtrl = manager.getController(index);
          if (newCtrl != null && newCtrl.value.isInitialized) {
            setState(() {
              _controller = newCtrl;
              _isInitialized = true;
              _isLoading = false;
              _hasError = false;
              _isPlaying = widget.isCurrent;
            });

            newCtrl.removeListener(_onControllerUpdate);
            newCtrl.addListener(_onControllerUpdate);

            if (widget.isCurrent) {
              _playCurrentVideo();
            }
          }
        } else {
          // Only show error if the user is STILL on this video
          if (widget.isCurrent) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      });
    } else {
      // Background item waiting for sequential preloader
      _isInitialized = false;
      _isLoading = true;
      _hasError = false;
    }
  }

  Future<void> _playCurrentVideo() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.play();
        if (mounted) setState(() => _isPlaying = true);
        _incrementViewIfNeeded();
      } catch (e) {
        debugPrint('[REELS_PLAY] Error playing: $e');
      }
    }
  }

  void _pauseCurrentVideo() {
    _controller?.pause();
    if (mounted) setState(() => _isPlaying = false);
  }

  void _onControllerUpdate() {
    if (!mounted || _controller == null) return;
    if (widget.manager.getController(widget.index) != _controller) return;
    try {
      final value = _controller!.value;

      if (value.hasError && !_hasError) {
        debugPrint('[REELS_ITEM] Controller error on index ${widget.index}: ${value.errorDescription}');
        if (widget.isCurrent) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        return;
      }

      final isPlaying = value.isPlaying;
      final isBuffering = value.isBuffering;

      if (value.isInitialized) {
        if (_isPlaying != isPlaying || _isBuffering != isBuffering) {
          setState(() {
            _isPlaying = isPlaying;
            _isBuffering = isBuffering;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final success = await widget.manager.retry(widget.index, widget.post);
    if (!mounted) return;

    if (success) {
      _syncWithManager(forceActive: true);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
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
      builder: (bottomSheetContext) {
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
                onTap: () async {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.pop(bottomSheetContext);
                  final link =
                      await DeepLinkService.instance.createPostShareLink(widget.post);
                  await Clipboard.setData(ClipboardData(text: link));
                  messenger?.showSnackBar(
                    const SnackBar(content: Text('Video link copied to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: Colors.white),
                title: const Text('View Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (widget.post.creatorId != null && widget.post.creatorId!.isNotEmpty) {
                    context.push(AppRoutes.exploreProfile, extra: widget.post.creatorId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  DeepLinkService.instance.sharePost(
                    context: context,
                    post: widget.post,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded, color: Colors.white),
                title: const Text('Download', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  MediaDownloader.downloadPostMedia(context, widget.post);
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
    try {
      _controller?.removeListener(_onControllerUpdate);
    } catch (_) {}
    _controller = null;
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

    final isFollowing = widget.isFollowing;
    final myUserId = LocalStorage.instance.getUserId();
    final isOwner = widget.post.creatorId != null &&
        widget.post.creatorId!.isNotEmpty &&
        widget.post.creatorId == myUserId;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Layer & Instant Poster
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
                  DeepLinkService.instance.sharePost(
                    context: context,
                    post: widget.post,
                  );
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
    final thumb = effectiveThumbUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Instant Poster Thumbnail (always visible until video frames play)
        if (thumb != null && thumb.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (context, url) => const ColoredBox(color: Colors.black),
              errorWidget: (context, url, error) => const ColoredBox(color: Colors.black),
            ),
          )
        else
          const Positioned.fill(
            child: ColoredBox(color: Colors.black),
          ),

        // 2. Video Player layer
        if (_isInitialized &&
            _controller != null &&
            _controller!.value.isInitialized &&
            widget.manager.getController(widget.index) == _controller)
          Center(
            child: SizedBox.expand(
              child: FittedBox(
                fit: _controller!.value.size.height >= _controller!.value.size.width
                    ? BoxFit.cover
                    : BoxFit.contain,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: IgnorePointer(
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ),

        // 3. Centered subtle loading spinner (only if not initialized yet or buffering mid-playback)
        if (_isLoading || (_isInitialized && _controller != null && (_isBuffering || _controller!.value.isBuffering)))
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),

        // 4. Error state overlay with Retry
        if (_hasError)
          _buildErrorOverlay(),
      ],
    );
  }

  Widget _buildErrorOverlay() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Could not load video',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check your connection and try again',
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
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
