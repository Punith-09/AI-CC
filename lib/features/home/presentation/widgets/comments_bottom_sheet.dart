import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../common/widgets/user_avatar.dart';
import '../../../artist_profile/data/models/artist_model.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/limit_upgrade_dialog.dart';
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

    // TODO: Re-enable subscription canComment check when ready
    // final subProvider = context.read<SubscriptionProvider>();
    // if (!subProvider.canComment) {
    //   LimitUpgradeDialog.show(context, type: LimitType.comment);
    //   return;
    // }
    // subProvider.recordCommentUsed();

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
          _comments.removeWhere((c) => c.id == tempComment.id);
          _isPosting = false;
        });

        // TODO: Re-enable subscription revert/limit logic when ready
        // final sub = context.read<SubscriptionProvider>();
        // final errStr = e.toString().toLowerCase();
        // if (errStr.contains('limit') ||
        //     errStr.contains('quota') ||
        //     errStr.contains('upgrade') ||
        //     errStr.contains('429') ||
        //     errStr.contains('403')) {
        //   sub.markLimitReached(LimitType.comment);
        //   LimitUpgradeDialog.show(context, type: LimitType.comment);
        // } else {
        //   sub.revertCommentUsed();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('Failed to post comment: $e'),
        //       backgroundColor: AppColors.danger,
        //       behavior: SnackBarBehavior.floating,
        //     ),
        //   );
        // }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkCard : Colors.white;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final handleColor = isDark ? Colors.white24 : Colors.black12;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
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
              color: handleColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Comments (${_comments.length})",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: dividerColor),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final textTertiary = isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.6) : const Color(0xFF94A3B8);
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

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
              style: TextStyle(color: textSecondary, fontSize: 13),
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
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: isDark ? Colors.white24 : Colors.black12,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              "No comments yet",
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Be the first to share your thoughts!",
              style: TextStyle(
                color: textTertiary,
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
        color: dividerColor,
        height: 16,
      ),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final displayName = comment.username.isNotEmpty ? comment.username : 'Artist';

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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
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
                style: TextStyle(
                  fontSize: 11,
                  color: textTertiary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              comment.comment,
              style: TextStyle(
                color: textSecondary,
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
                      color: comment.isLiked ? const Color(0xFFE940B7) : (isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8)),
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
                        color: comment.isLiked ? const Color(0xFFE940B7) : textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final inputBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final inputText = isDark ? AppColors.darkText : AppColors.lightText;
    final inputHint = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
      // TODO: Re-enable subscription quota display when ready
      // Consumer<SubscriptionProvider>(
      //   builder: (context, subProvider, _) {
      //     final remaining = subProvider.remainingToday.comments;
      //     final total = subProvider.limits.commentsPerDay;
      //     final plan = subProvider.planLabel;
      //     return Padding(
      //       padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Text(
      //             "$remaining of $total comments left today ($plan)",
      //             style: TextStyle(
      //               fontSize: 11,
      //               color: remaining <= 0
      //                   ? const Color(0xFFF59E0B)
      //                   : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
      //               fontWeight: remaining <= 0 ? FontWeight.bold : FontWeight.normal,
      //             ),
      //           ),
      //           if (remaining <= 5 && !subProvider.activePlan.contains('max'))
      //             GestureDetector(
      //               onTap: () {
      //                 context.push(AppRoutes.subscription);
      //               },
      //               child: const Text(
      //                 "Upgrade for more",
      //                 style: TextStyle(
      //                   fontSize: 11,
      //                   color: Color(0xFF1CC8FF),
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: inputBorder,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(
                        color: inputText,
                        fontSize: 14,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        hintStyle: TextStyle(
                          color: inputHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
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
        ],
      ),
    );
  }
}