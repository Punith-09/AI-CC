import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/widgets/user_avatar.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/story_item_model.dart';
import '../../data/models/user_stories_group_model.dart';
import '../providers/stories_provider.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<UserStoriesGroupModel> groups;
  final int initialGroupIndex;

  const StoryViewerScreen({
    super.key,
    required this.groups,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _groupIndex;
  int _itemIndex = 0;

  AnimationController? _animController;
  VideoPlayerController? _videoController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroupIndex.clamp(0, widget.groups.length - 1);
    _initStoryItem();
  }

  UserStoriesGroupModel? get _currentGroup {
    if (_groupIndex >= 0 && _groupIndex < widget.groups.length) {
      return widget.groups[_groupIndex];
    }
    return null;
  }

  StoryItemModel? get _currentItem {
    final group = _currentGroup;
    if (group != null && _itemIndex >= 0 && _itemIndex < group.items.length) {
      return group.items[_itemIndex];
    }
    return null;
  }

  bool get _isMyStory {
    final group = _currentGroup;
    if (group == null) return false;
    final myId = LocalStorage.instance.getUserId();
    return myId != null && myId.isNotEmpty && group.creatorId == myId;
  }

  void _initStoryItem() {
    _animController?.stop();
    _animController?.dispose();
    _animController = null;

    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    final item = _currentItem;
    final group = _currentGroup;
    if (item == null || group == null) {
      if (mounted) context.pop();
      return;
    }

    // Mark as viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StoriesProvider>().markStoryViewed(item.id, group.creatorId);
      }
    });

    final formattedUrl = ApiEndpoints.formatMediaUrl(item.mediaUrl);

    if (item.isVideo) {
      final videoUri = Uri.tryParse(formattedUrl);
      if (videoUri != null) {
        _videoController = VideoPlayerController.networkUrl(videoUri)
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {});
            final dur = _videoController!.value.duration;
            _startProgressTimer(dur.inMilliseconds > 0 ? dur : const Duration(seconds: 7));
            _videoController!.play();
          }).catchError((_) {
            _startProgressTimer(const Duration(seconds: 5));
          });
      } else {
        _startProgressTimer(const Duration(seconds: 5));
      }
    } else {
      _startProgressTimer(const Duration(seconds: 5));
    }
  }

  void _startProgressTimer(Duration duration) {
    _animController = AnimationController(vsync: this, duration: duration);
    _animController!.forward();
    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStoryItem();
      }
    });
  }

  void _nextStoryItem() {
    final group = _currentGroup;
    if (group == null) return;

    if (_itemIndex < group.items.length - 1) {
      setState(() {
        _itemIndex++;
      });
      _initStoryItem();
    } else {
      // Next group
      if (_groupIndex < widget.groups.length - 1) {
        setState(() {
          _groupIndex++;
          _itemIndex = 0;
        });
        _initStoryItem();
      } else {
        // Reached end of all stories
        if (mounted) context.pop();
      }
    }
  }

  void _prevStoryItem() {
    if (_itemIndex > 0) {
      setState(() {
        _itemIndex--;
      });
      _initStoryItem();
    } else {
      // Previous group
      if (_groupIndex > 0) {
        setState(() {
          _groupIndex--;
          final prevGroup = widget.groups[_groupIndex];
          _itemIndex = prevGroup.items.isNotEmpty ? prevGroup.items.length - 1 : 0;
        });
        _initStoryItem();
      } else {
        // Rewind current
        _initStoryItem();
      }
    }
  }

  void _pause() {
    if (!_isPaused) {
      _isPaused = true;
      _animController?.stop(canceled: false);
      _videoController?.pause();
    }
  }

  void _resume() {
    if (_isPaused) {
      _isPaused = false;
      _animController?.forward();
      _videoController?.play();
    }
  }

  Future<void> _confirmDeleteStory() async {
    _pause();
    final item = _currentItem;
    final group = _currentGroup;
    if (item == null || group == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Story?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this story? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<StoriesProvider>().deleteStory(item.id, group.creatorId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story deleted.'),
              backgroundColor: AppColors.primary,
            ),
          );
          _nextStoryItem();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete story: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
          _resume();
        }
      }
    } else {
      _resume();
    }
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return 'Recent';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _animController?.stop();
    _animController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = _currentGroup;
    final item = _currentItem;

    if (group == null || item == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final formattedUrl = ApiEndpoints.formatMediaUrl(item.mediaUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            context.pop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media View
            Center(
              child: item.isVideo
                  ? (_videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ))
                  : CachedNetworkImage(
                      imageUrl: formattedUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 64),
                      ),
                    ),
            ),

            // Tap Zones for Left (Prev) and Right (Next)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _prevStoryItem,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _nextStoryItem,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),

            // Top Gradient & Controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  right: 12,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(group.items.length, (idx) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                height: 2.5,
                                color: Colors.white.withValues(alpha: 0.3),
                                child: idx < _itemIndex
                                    ? Container(color: Colors.white)
                                    : (idx == _itemIndex && _animController != null
                                        ? AnimatedBuilder(
                                            animation: _animController!,
                                            builder: (ctx, _) {
                                              return FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: _animController!.value,
                                                child: Container(color: Colors.white),
                                              );
                                            },
                                          )
                                        : const SizedBox.shrink()),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // User Info Header
                    Row(
                      children: [
                        UserAvatar(
                          imageUrl: group.creatorPic,
                          name: group.creatorName,
                          radius: 18,
                          fontSize: 14,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.creatorName.isNotEmpty ? group.creatorName : group.creatorUsername,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatTimeAgo(item.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isMyStory)
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.white70, size: 20),
                            onPressed: _confirmDeleteStory,
                            tooltip: 'Delete story',
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
