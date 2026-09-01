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
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../../../messages/presentation/providers/messages_provider.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../providers/home_feed_provider.dart';

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

    if (_post.isVideo) {
      _initializeVideo();
    }

    _fetchComments();
    _incrementView();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
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
    } catch (_) {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  // =========================================================
  // ACTIONS (LIKE, FOLLOW, MESSAGE, SHARE)
  // =========================================================

  Future<void> _toggleLike() async {
    final isLiked = !_post.liked;
    final likesCount = isLiked
        ? _post.likesCount + 1
        : (_post.likesCount > 0 ? _post.likesCount - 1 : 0);

    setState(() {
      _post = _post.copyWith(liked: isLiked, likesCount: likesCount);
    });

    try {
      context.read<HomeFeedProvider>().toggleLike(_post.id);
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    if (_post.creatorId == null || _post.creatorId!.isEmpty || _isFollowLoading) return;
    setState(() => _isFollowLoading = true);

    try {
      await sl<ProfileRepository>().followUser(_post.creatorId!);
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isFollowLoading = false;
        });
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

    // Check by creator ID
    if (_post.creatorId != null &&
        _post.creatorId!.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      if (_post.creatorId == currentUserId) return true;
    }

    // Check by creator name
    if (_post.creatorName.isNotEmpty &&
        currentUserName != null &&
        currentUserName.isNotEmpty) {
      if (_post.creatorName.trim().toLowerCase() ==
          currentUserName.trim().toLowerCase()) {
        return true;
      }
    }

    // Check by ProfileProvider currentProfile
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backGroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header / Top Bar ──
              _buildTopBar(),

              // ── Scrollable Body ──
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Media Section (Video Player or Photo)
                      _buildMediaSection(),

                      const SizedBox(height: 16),

                      // 2. Creator Info & Follow / Message Buttons
                      _buildCreatorRow(),

                      const SizedBox(height: 14),

                      // 3. Post Title & Description
                      _buildTitleAndDescription(),

                      const SizedBox(height: 14),

                      // 4. Views & Likes Stat Row
                      _buildStatsRow(),

                      const SizedBox(height: 12),

                      // 5. Action Buttons (Like, Comment, Share)
                      _buildActionButtonsRow(),

                      const SizedBox(height: 8),

                      const Divider(color: Colors.white12, height: 16, thickness: 1),

                      // 6. Comments Header & List
                      _buildCommentsSection(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ── Bottom Fixed Comment Bar ──
              _buildBottomCommentBar(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 60),
                child: Text(
                  _post.isVideo ? 'Watch Video' : 'View Photo',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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

  Widget _buildMediaSection() {
    if (_post.isVideo) {
      return Container(
        width: double.infinity,
        height: 270,
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
                      color: Color(0xFF7C4DFF),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),

            // Controls Overlay with Play/Pause and "Tap to Play/Pause"
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
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2.5,
                            ),
                          ),
                          child: Icon(
                            _isVideoPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // "Tap to Play/Pause" badge
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
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
      constraints: const BoxConstraints(maxHeight: 380),
      color: const Color(0xFF0F1722),
      child: photoUrl.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox(
                height: 260,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C4DFF),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const SizedBox(
                height: 240,
                child: Center(
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

  Widget _buildCreatorRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _navigateToCreatorProfile,
            child: UserAvatar(
              imageUrl: _post.creatorPic,
              name: _post.creatorName,
              radius: 24,
              fontSize: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
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
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_post.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 15, color: Color(0xFF22D3EE)),
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
                      color: Colors.white60,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Follow & Message Buttons (hidden for logged-in user)
          if (!_isCurrentUser) ...[
            // Follow Button
            GestureDetector(
              onTap: _toggleFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF9066FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 8),

            // Message Button
            GestureDetector(
              onTap: _messageCreator,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildTitleAndDescription() {
    final title = _post.title;
    final desc = _post.description;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
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
          const Divider(color: Colors.white10, height: 1, thickness: 1),
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
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_post.viewsCount} views',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Likes count
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Color(0xFFE940B7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_post.likesCount} likes',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
          // ── Like Button ──
          InkWell(
            onTap: _toggleLike,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFFE940B7) : Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Like',
                    style: GoogleFonts.poppins(
                      color: isLiked ? const Color(0xFFE940B7) : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Comment Button ──
          InkWell(
            onTap: () {
              _commentFocusNode.requestFocus();
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.messageSquare,
                    color: Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comment',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Share Button ──
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
                    color: Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
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
  // COMMENTS SECTION
  // =========================================================

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Comments (${_comments.length})',
            style: GoogleFonts.poppins(
              color: Colors.white,
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
                    color: Color(0xFF7C4DFF),
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.messageSquareDashed,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 38,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No comments yet.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to share your thoughts!',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (_, i) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentTile(comment);
              },
            ),
        ],
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
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.timeAgo,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.comment,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
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
            color: comment.isLiked ? const Color(0xFFE940B7) : Colors.white30,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BOTTOM COMMENT BAR
  // =========================================================

  Widget _buildBottomCommentBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1622),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
        ),
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
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.07),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: const BorderSide(
                    color: Color(0xFF7C4DFF),
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _postComment(),
            ),
          ),

          const SizedBox(width: 10),

          // Post button
          GestureDetector(
            onTap: _postComment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9E6FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
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
