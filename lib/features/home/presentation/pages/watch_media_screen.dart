import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../../../messages/presentation/providers/messages_provider.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../providers/home_feed_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/limit_upgrade_dialog.dart';

class WatchMediaScreen extends StatefulWidget {
  final FeedPostModel post;

  const WatchMediaScreen({
    super.key,
    required this.post,
  });

  @override
  State<WatchMediaScreen> createState() => _WatchMediaScreenState();
}

class _WatchMediaScreenState extends State<WatchMediaScreen> {
  late FeedPostModel _post;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _desktopCommentsScrollController = ScrollController();

  // Video Controller State
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = false;
  bool _isVideoPlaying = false;
  bool _showVideoControls = true;
  bool _hasVideoError = false;
  Timer? _hideControlsTimer;

  // Comments State
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  bool _isPostingComment = false;

  // Follow State
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;

    _initFollowStatus();

    if (_post.isVideo) {
      _initializeVideo();
    }

    _fetchComments();
    _incrementView();
  }

  void _initFollowStatus() {
    final creatorId = _post.creatorId;
    if (creatorId != null && creatorId.isNotEmpty) {
      try {
        final viewed = context.read<ProfileProvider>().viewedProfile;
        if (viewed != null && viewed.id == creatorId) {
          _isFollowing = viewed.following;
        }
      } catch (_) {}
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFollowStatus();
      });
    }
  }

  Future<void> _checkFollowStatus() async {
    final creatorId = _post.creatorId;
    if (creatorId == null || creatorId.isEmpty) return;

    try {
      final profile = await sl<ProfileRepository>().getUserProfile(creatorId);
      if (mounted) {
        setState(() {
          _isFollowing = profile.following;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _desktopCommentsScrollController.dispose();
    super.dispose();
  }

  // =========================================================
  // VIDEO PLAYBACK
  // =========================================================

  Future<void> _initializeVideo() async {
    final videoUrl = ApiEndpoints.formatMediaUrl(_post.mediaUrl);
    if (videoUrl.isEmpty) {
      setState(() => _hasVideoError = true);
      return;
    }

    setState(() {
      _isVideoLoading = true;
      _hasVideoError = false;
    });

    try {
      final uri = Uri.parse(videoUrl);
      _videoController = VideoPlayerController.networkUrl(uri);
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();

      _videoController!.addListener(_onVideoStateChanged);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoLoading = false;
          _isVideoPlaying = true;
          _showVideoControls = true;
        });
        _scheduleHideControls();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _hasVideoError = true;
        });
      }
    }
  }

  void _onVideoStateChanged() {
    if (!mounted || _videoController == null) return;
    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _isVideoPlaying) {
      setState(() => _isVideoPlaying = isPlaying);
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() {
        _isVideoPlaying = false;
        _showVideoControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      _videoController!.play();
      setState(() {
        _isVideoPlaying = true;
        _showVideoControls = true;
      });
      _scheduleHideControls();
    }
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isVideoPlaying) {
        setState(() => _showVideoControls = false);
      }
    });
  }

  void _incrementView() {
    if (_post.id.isNotEmpty && _post.isVideo) {
      sl<HomeRepository>().incrementVideoView(_post.id);
    }
  }

  // =========================================================
  // COMMENTS
  // =========================================================

  Future<void> _fetchComments() async {
    if (_post.id.isEmpty) {
      setState(() => _isLoadingComments = false);
      return;
    }

    try {
      final list = await sl<HomeRepository>().getComments(_post.id);
      if (mounted) {
        setState(() {
          _comments = list;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPostingComment || _post.id.isEmpty) return;

    final subProvider = context.read<SubscriptionProvider>();
    if (!subProvider.canComment) {
      LimitUpgradeDialog.show(context, type: LimitType.comment);
      return;
    }

    subProvider.recordCommentUsed();

    setState(() => _isPostingComment = true);
    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      final newComment = await sl<HomeRepository>().postComment(
        videoId: _post.id,
        text: text,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _post = _post.copyWith(commentsCount: _comments.length);
          _isPostingComment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPostingComment = false);
        final sub = context.read<SubscriptionProvider>();
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('limit') ||
            errStr.contains('quota') ||
            errStr.contains('upgrade') ||
            errStr.contains('429') ||
            errStr.contains('403')) {
          sub.markLimitReached(LimitType.comment);
          LimitUpgradeDialog.show(context, type: LimitType.comment);
        } else {
          sub.revertCommentUsed();
        }
      }
    }
  }

  // =========================================================
  // ACTIONS (LIKE, FOLLOW, MESSAGE, SHARE)
  // =========================================================

  Future<void> _toggleLike() async {
    if (_post.id.isEmpty) return;

    final originalPost = _post;
    final isLiked = !_post.liked;

    if (isLiked) {
      final subProvider = context.read<SubscriptionProvider>();
      if (!subProvider.canLike) {
        LimitUpgradeDialog.show(context, type: LimitType.like);
        return;
      }
      subProvider.recordLikeUsed();
    }

    final likesCount = isLiked
        ? _post.likesCount + 1
        : (_post.likesCount > 0 ? _post.likesCount - 1 : 0);

    setState(() {
      _post = _post.copyWith(liked: isLiked, likesCount: likesCount);
    });

    try {
      try {
        context.read<HomeFeedProvider>().syncPostLike(
          _post.id,
          liked: isLiked,
          likesCount: likesCount,
        );
      } catch (_) {}

      final res = await sl<HomeRepository>().toggleLike(
        id: _post.id,
        isVideo: _post.isVideo,
      );

      if (mounted && res.isNotEmpty) {
        final serverLiked = res['liked'] as bool? ?? (res['data'] is Map ? res['data']['liked'] as bool? : null);
        final dynamic rawServerLikes = res['likesCount'] ?? res['data']?['likesCount'] ?? (res['likes'] is List ? (res['likes'] as List).length : null);
        int? serverLikesCount;
        if (rawServerLikes is int) {
          serverLikesCount = rawServerLikes;
        } else if (rawServerLikes is num) {
          serverLikesCount = rawServerLikes.toInt();
        } else if (rawServerLikes is String) {
          serverLikesCount = int.tryParse(rawServerLikes);
        }

        if (serverLiked != null || serverLikesCount != null) {
          final finalLiked = serverLiked ?? isLiked;
          final finalCount = serverLikesCount ?? likesCount;
          setState(() {
            _post = _post.copyWith(
              liked: finalLiked,
              likesCount: finalCount,
            );
          });
          try {
            context.read<HomeFeedProvider>().syncPostLike(
              _post.id,
              liked: finalLiked,
              likesCount: finalCount,
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _post = originalPost;
        });
        try {
          context.read<HomeFeedProvider>().syncPostLike(
            _post.id,
            liked: originalPost.liked,
            likesCount: originalPost.likesCount,
          );
        } catch (_) {}

        if (isLiked) {
          final sub = context.read<SubscriptionProvider>();
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('limit') ||
              errStr.contains('quota') ||
              errStr.contains('upgrade') ||
              errStr.contains('429') ||
              errStr.contains('403')) {
            sub.markLimitReached(LimitType.like);
            LimitUpgradeDialog.show(context, type: LimitType.like);
          } else {
            sub.revertLikeUsed();
          }
        }
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_post.creatorId == null || _post.creatorId!.isEmpty || _isFollowLoading) return;
    setState(() => _isFollowLoading = true);

    final creatorId = _post.creatorId!;
    try {
      await sl<ProfileRepository>().followUser(creatorId);
      final newFollowing = !_isFollowing;
      if (mounted) {
        setState(() {
          _isFollowing = newFollowing;
          _isFollowLoading = false;
        });
        try {
          context.read<ProfileProvider>().syncFollowStatus(creatorId, following: newFollowing);
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? 'Following ${_post.creatorName}' : 'Unfollowed ${_post.creatorName}'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update follow status. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _messageCreator() async {
    final targetId = _post.creatorId;
    if (targetId == null || targetId.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final chat = await context.read<MessagesProvider>().startChat(targetId);
    if (chat != null) {
      final enrichedChat = chat.copyWith(
        participantId: targetId,
        participantName: chat.participantName.isNotEmpty ? chat.participantName : _post.creatorName,
        participantAvatar: chat.participantAvatar.isNotEmpty ? chat.participantAvatar : (_post.creatorPic ?? ''),
        participantRole: chat.participantRole.isNotEmpty ? chat.participantRole : (_post.creatorCategory ?? 'Artist'),
      );
      router.push(AppRoutes.chat, extra: enrichedChat);
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open chat. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool get _isCurrentUser {
    String? currentUserId;
    String? currentUserName;

    try {
      currentUserId = LocalStorage.instance.getUserId();
      currentUserName = LocalStorage.instance.getUserName();
    } catch (_) {}

    if (_post.creatorId != null &&
        _post.creatorId!.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      if (_post.creatorId == currentUserId) return true;
    }

    if (_post.creatorName.isNotEmpty &&
        currentUserName != null &&
        currentUserName.isNotEmpty) {
      if (_post.creatorName.trim().toLowerCase() ==
          currentUserName.trim().toLowerCase()) {
        return true;
      }
    }

    try {
      final currentProfile = context.read<ProfileProvider>().currentProfile;
      if (currentProfile != null) {
        if (currentProfile.id.isNotEmpty &&
            _post.creatorId != null &&
            _post.creatorId == currentProfile.id) {
          return true;
        }
        if (currentProfile.name.isNotEmpty &&
            _post.creatorName.trim().toLowerCase() ==
                currentProfile.name.trim().toLowerCase()) {
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  void _navigateToCreatorProfile() {
    if (_isCurrentUser) {
      context.push(AppRoutes.artistProfile);
      return;
    }
    final targetId = _post.creatorId;
    if (targetId != null && targetId.isNotEmpty) {
      context.push(AppRoutes.exploreProfile, extra: targetId);
    }
  }

  // =========================================================
  // BUILD UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFFF8FAFC) : Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(isDesktop: isDesktop),

            // Body (Desktop 2-column or Mobile single-column)
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
            ),

            // Fixed bottom comment bar on Mobile
            if (!isDesktop) _buildBottomCommentBar(isDesktop: false),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DESKTOP LAYOUT (2 Columns)
  // =========================================================

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Media Player + Title/Desc + Stats + Actions
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media Section
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _buildMediaSection(isDesktop: true),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Card containing Title, Description, Stats & Action Buttons
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndDescription(isDesktop: true),
                            const SizedBox(height: 16),
                            _buildStatsRow(),
                            const SizedBox(height: 12),
                            _buildActionButtonsRow(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Right Column: Creator Info + Comments Section + Input Bar
              Expanded(
                flex: 5,
                child: Container(
                  height: MediaQuery.of(context).size.height - 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Creator Header Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: _buildCreatorRow(isDesktop: true),
                      ),

                      const Divider(height: 1, color: Color(0xFFE2E8F0)),

                      // Comments List Header & Body
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Comments (${_comments.length})',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF111827),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: _isLoadingComments
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    color: AppColors.buttonPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _comments.isEmpty
                                ? _buildEmptyComments()
                                : ListView.separated(
                                    controller: _desktopCommentsScrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: _comments.length,
                                    separatorBuilder: (_, index) => const Divider(height: 18, color: Color(0xFFF1F5F9)),
                                    itemBuilder: (context, index) {
                                      return _buildCommentTile(_comments[index]);
                                    },
                                  ),
                      ),

                      // Fixed Bottom Comment Input inside Right Card
                      _buildBottomCommentBar(isDesktop: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MOBILE LAYOUT (Single Column)
  // =========================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Media Section
          _buildMediaSection(isDesktop: false),

          const SizedBox(height: 14),

          // 2. Creator Info & Follow / Message Buttons
          _buildCreatorRow(isDesktop: false),

          const SizedBox(height: 14),

          // 3. Post Title & Description
          _buildTitleAndDescription(isDesktop: false),

          const SizedBox(height: 14),

          // 4. Views & Likes Stat Row
          _buildStatsRow(),

          const SizedBox(height: 10),

          // 5. Action Buttons (Like, Comment, Share)
          _buildActionButtonsRow(),

          const SizedBox(height: 8),

          const Divider(color: Color(0xFFE5E7EB), height: 16, thickness: 1),

          // 6. Comments Header & List
          _buildCommentsSection(isDesktop: false),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar({required bool isDesktop}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF111827),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDesktop ? 'Back to Feed' : 'Back',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF111827),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: isDesktop ? 100 : 60),
                child: Text(
                  _post.isVideo ? 'Watch Video' : 'View Photo',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111827),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MEDIA SECTION
  // =========================================================

  Widget _buildMediaSection({required bool isDesktop}) {
    final mediaHeight = isDesktop ? 460.0 : 270.0;

    if (_post.isVideo) {
      return Container(
        width: double.infinity,
        height: mediaHeight,
        color: const Color(0xFF0F1722),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Player Layer
            if (_isVideoInitialized && _videoController != null)
              GestureDetector(
                onTap: _togglePlayPause,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio > 0
                        ? _videoController!.value.aspectRatio
                        : (16 / 9),
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              _buildThumbnail(),

            // Buffering Spinner
            if (_isVideoLoading || (_isVideoInitialized && _videoController?.value.isBuffering == true))
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      color: AppColors.buttonPrimary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),

            // Controls Overlay with Play/Pause
            if (_showVideoControls || !_isVideoPlaying)
              GestureDetector(
                onTap: _togglePlayPause,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circle Play/Pause Button
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 2.2,
                            ),
                          ),
                          child: Icon(
                            _isVideoPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Text(
                            'Tap to Play/Pause',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Error Overlay
            if (_hasVideoError)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
                      const SizedBox(height: 8),
                      const Text('Unable to play video', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _initializeVideo,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Photo Display
    final photoUrl = ApiEndpoints.formatMediaUrl(_post.mediaUrl);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: isDesktop ? 500 : 380),
      color: const Color(0xFF0F1722),
      child: photoUrl.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => SizedBox(
                height: isDesktop ? 340 : 260,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => SizedBox(
                height: isDesktop ? 300 : 240,
                child: const Center(
                  child: Icon(LucideIcons.image, color: Colors.white38, size: 48),
                ),
              ),
            )
          : Image.asset(
              photoUrl.isNotEmpty ? photoUrl : 'assets/images/post1.jpeg',
              fit: BoxFit.contain,
            ),
    );
  }

  Widget _buildThumbnail() {
    final thumbUrl = ApiEndpoints.formatMediaUrl(_post.thumbnailUrl ?? _post.mediaUrl);
    if (thumbUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: thumbUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, e, s) => Container(color: const Color(0xFF15222E)),
      );
    }
    return Container(color: const Color(0xFF15222E));
  }

  // =========================================================
  // CREATOR ROW
  // =========================================================

  Widget _buildCreatorRow({required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _navigateToCreatorProfile,
            child: UserAvatar(
              imageUrl: _post.creatorPic,
              name: _post.creatorName,
              radius: 22,
              fontSize: 15,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 12),

          // Name + Role
          Expanded(
            child: GestureDetector(
              onTap: _navigateToCreatorProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _post.creatorName.isNotEmpty ? _post.creatorName : 'Creator',
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_post.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 15, color: Color(0xFF0284C7)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _post.creatorCategory != null && _post.creatorCategory!.isNotEmpty
                        ? _post.creatorCategory!
                        : (_post.isVideo ? 'Actor' : 'Artist'),
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Follow & Message Buttons (hidden for logged-in user)
          if (!_isCurrentUser) ...[
            // Follow Button (SOLID COLOR)
            GestureDetector(
              onTap: _toggleFollow,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: _isFollowing
                      ? const Color(0xFFF1F5F9)
                      : AppColors.buttonPrimary,
                  borderRadius: BorderRadius.circular(20),
                  border: _isFollowing
                      ? Border.all(color: const Color(0xFFCBD5E1), width: 1)
                      : null,
                ),
                child: _isFollowLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: GoogleFonts.poppins(
                          color: _isFollowing ? const Color(0xFF334155) : Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 8),

            // Message Button (Clean border outline)
            GestureDetector(
              onTap: _messageCreator,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E293B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // TITLE & DESCRIPTION
  // =========================================================

  Widget _buildTitleAndDescription({required bool isDesktop}) {
    final title = _post.title;
    final desc = _post.description;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // STATS ROW (VIEWS & LIKES)
  // =========================================================

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Views count
              Row(
                children: [
                  const Icon(
                    LucideIcons.eye,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_post.viewsCount} views',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Likes count
              Row(
                children: [
                  Icon(
                    _post.liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: const Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${_post.likesCount} likes',
                      key: ValueKey(_post.likesCount),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1F2937),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTION BUTTONS ROW (LIKE, COMMENT, SHARE)
  // =========================================================

  Widget _buildActionButtonsRow() {
    final isLiked = _post.liked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Like Button
          InkWell(
            onTap: _toggleLike,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isLiked),
                      color: isLiked ? const Color(0xFFE11D48) : const Color(0xFF4B5563),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Like',
                    style: GoogleFonts.poppins(
                      color: isLiked ? const Color(0xFFE11D48) : const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment Button
          InkWell(
            onTap: () {
              _commentFocusNode.requestFocus();
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.messageSquare,
                    color: Color(0xFF4B5563),
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comment',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Share Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.share2,
                    color: Color(0xFF4B5563),
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMMENTS SECTION (Mobile)
  // =========================================================

  Widget _buildCommentsSection({required bool isDesktop}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Comments (${_comments.length})',
            style: GoogleFonts.poppins(
              color: const Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // Loading
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.buttonPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_comments.isEmpty)
            _buildEmptyComments()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (_, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                return _buildCommentTile(_comments[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.messageSquareDashed,
              color: const Color(0xFF94A3B8),
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              'No comments yet.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share your thoughts!',
              style: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          imageUrl: comment.profileImage,
          name: comment.username,
          radius: 17,
          fontSize: 12,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.username,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF111827),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.timeAgo,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.comment,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF334155),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            try {
              final newLiked = !comment.isLiked;
              final newLikes = newLiked ? comment.likes + 1 : (comment.likes > 0 ? comment.likes - 1 : 0);
              setState(() {
                final idx = _comments.indexWhere((c) => c.id == comment.id);
                if (idx != -1) {
                  _comments[idx] = comment.copyWith(isLiked: newLiked, likes: newLikes);
                }
              });
              await sl<HomeRepository>().toggleCommentLike(comment.id);
            } catch (_) {}
          },
          icon: Icon(
            comment.isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: comment.isLiked ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BOTTOM COMMENT BAR
  // =========================================================

  Widget _buildBottomCommentBar({required bool isDesktop}) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: isDesktop ? 12 : MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: isDesktop ? 1 : 0.8,
          ),
        ),
        borderRadius: isDesktop
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Input field
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              style: GoogleFonts.poppins(
                color: const Color(0xFF111827),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.buttonPrimary,
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _postComment(),
            ),
          ),

          const SizedBox(width: 10),

          // Post button (SOLID PURPLE, NO GRADIENT)
          GestureDetector(
            onTap: _postComment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: _isPostingComment
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Post',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
