import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../common/widgets/user_avatar.dart';
import '../../../artist_profile/data/models/artist_model.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../providers/home_feed_provider.dart';

class CommentsBottomSheet extends StatefulWidget {
  final FeedPostModel? post;
  final String? postId;

  const CommentsBottomSheet({
    super.key,
    this.post,
    this.postId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  // Static memory cache for fetched user profiles across sheets
  static final Map<String, ArtistModel> _cachedUserProfiles = {};

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _errorMessage;

  String get effectivePostId =>
      widget.post?.id ?? widget.postId ?? '';

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _ensureUserProfile();
  }

  Future<void> _ensureUserProfile() async {
    final currentName = LocalStorage.instance.getUserName();
    if (currentName == null || currentName.isEmpty) {
      try {
        if (sl.isRegistered<ProfileRepository>()) {
          await sl<ProfileRepository>().getProfileMe();
          if (mounted) {
            setState(() {});
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (effectivePostId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = sl<HomeRepository>();
      final list = await repository.getComments(effectivePostId);

      if (mounted) {
        setState(() {
          _comments = list;
          _isLoading = false;
        });

        // Push the real count back to the feed card counter
        if (widget.post != null) {
          _updateFeedCount(list.length);
        }

        // Resolve missing author names for any comments
        _resolveCommentAuthors();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _resolveCommentAuthors() {
    final myId = LocalStorage.instance.getUserId() ?? '';
    final myName = LocalStorage.instance.getUserName() ?? 'You';
    final myPic = LocalStorage.instance.getUserProfilePhoto() ?? '';

    for (int i = 0; i < _comments.length; i++) {
      final comment = _comments[i];

      // If it's my own comment
      if (myId.isNotEmpty && comment.userId == myId) {
        _comments[i] = comment.copyWith(
          username: myName,
          profileImage: comment.profileImage.isNotEmpty ? comment.profileImage : myPic,
        );
        continue;
      }

      // If author name is generic or missing, and we have a userId
      if ((comment.username.isEmpty || comment.username == 'Artist' || comment.username == 'User') &&
          comment.userId.isNotEmpty) {
        if (_cachedUserProfiles.containsKey(comment.userId)) {
          final cached = _cachedUserProfiles[comment.userId]!;
          _comments[i] = comment.copyWith(
            username: cached.name.isNotEmpty ? cached.name : comment.username,
            profileImage: cached.profileImage.isNotEmpty ? cached.profileImage : comment.profileImage,
          );
        } else {
          // Fetch user profile in background
          _fetchUserProfileForComment(i, comment.userId);
        }
      }
    }
  }

  Future<void> _fetchUserProfileForComment(int index, String userId) async {
    try {
      if (sl.isRegistered<ProfileRepository>()) {
        final profile = await sl<ProfileRepository>().getUserProfile(userId);
        _cachedUserProfiles[userId] = profile;

        if (mounted && index < _comments.length && _comments[index].userId == userId) {
          setState(() {
            _comments[index] = _comments[index].copyWith(
              username: profile.name.isNotEmpty ? profile.name : _comments[index].username,
              profileImage: profile.profileImage.isNotEmpty ? profile.profileImage : _comments[index].profileImage,
            );
          });
        }
      }
    } catch (_) {}
  }

  /// Pushes the comment count into the feed card via the provider.
  void _updateFeedCount(int count) {
    if (widget.post == null || !mounted) return;
    try {
      Provider.of<HomeFeedProvider>(context, listen: false)
          .updateCommentsCount(widget.post!.id, count);
    } catch (_) {}
  }

  Future<void> _handlePostComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPosting) return;

    if (effectivePostId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot post comment: invalid post ID.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    _commentController.clear();

    final myId = LocalStorage.instance.getUserId() ?? '';
    final myName = LocalStorage.instance.getUserName() ?? 'You';
    final myPic = LocalStorage.instance.getUserProfilePhoto() ?? '';

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final tempComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: myId,
      profileImage: myPic,
      username: myName,
      comment: text,
      time: '1m',
      createdAt: nowIso,
      likes: 0,
      isLiked: false,
    );

    setState(() {
      _comments.insert(0, tempComment);
    });

    try {
      final repository = sl<HomeRepository>();
      final createdComment = await repository.postComment(
        videoId: effectivePostId,
        text: text,
      );

      final finalComment = createdComment.copyWith(
        userId: createdComment.userId.isNotEmpty ? createdComment.userId : myId,
        username: (createdComment.username.isNotEmpty && createdComment.username != 'Artist' && createdComment.username != 'User')
            ? createdComment.username
            : myName,
        profileImage: createdComment.profileImage.isNotEmpty
            ? createdComment.profileImage
            : myPic,
      );

      if (mounted) {
        setState(() {
          _comments[0] = finalComment;
          _isPosting = false;
        });
        // Keep feed card count in sync
        _updateFeedCount(_comments.length);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleToggleCommentLike(int index) async {
    final comment = _comments[index];
    final bool newLiked = !comment.isLiked;
    final int newLikes = newLiked ? comment.likes + 1 : (comment.likes > 0 ? comment.likes - 1 : 0);

    setState(() {
      _comments[index] = comment.copyWith(
        isLiked: newLiked,
        likes: newLikes,
      );
    });

    if (comment.id.isEmpty) return;

    try {
      final repository = sl<HomeRepository>();
      final res = await repository.toggleCommentLike(comment.id);
      if (res.isNotEmpty && mounted) {
        final rawLiked = res['liked'] ?? res['isLiked'];
        final serverLiked = rawLiked is bool ? rawLiked : (rawLiked?.toString() == 'true');

        final rawLikes = res['likes'] ?? res['likesCount'];
        final serverLikes = rawLikes is int
            ? rawLikes
            : (int.tryParse(rawLikes?.toString() ?? '') ?? newLikes);

        setState(() {
          _comments[index] = _comments[index].copyWith(
            isLiked: serverLiked,
            likes: serverLikes,
          );
        });
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _comments[index] = comment;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF102B36),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Comments (${_comments.length})",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.08)),

          // Comments List
          Expanded(
            child: _buildCommentsList(),
          ),

          // Bottom Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null && _comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _fetchComments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white24,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              "No comments yet",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Be the first to share your thoughts!",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withValues(alpha: 0.04),
        height: 16,
      ),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final displayName = comment.username.isNotEmpty ? comment.username : 'Artist';
        final hasNetworkAvatar = comment.profileImage.startsWith('http');

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: UserAvatar(
            imageUrl: comment.profileImage,
            name: displayName,
            radius: 18,
            fontSize: 13,
            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (comment.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
              const SizedBox(width: 8),
              Text(
                comment.timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              comment.comment,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ),
          trailing: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleToggleCommentLike(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey('comment_like_${comment.id}_${comment.isLiked}'),
                      size: 20,
                      color: comment.isLiked ? const Color(0xFFE940B7) : Colors.white60,
                      shadows: comment.isLiked
                          ? const [
                              Shadow(
                                color: Color(0xFFE940B7),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (comment.likes > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      "${comment.likes}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: comment.isLiked ? const Color(0xFFE940B7) : Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: const InputDecoration(
                    hintText: "Write a comment...",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handlePostComment(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFCC3EFF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isPosting ? null : _handlePostComment,
                icon: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}