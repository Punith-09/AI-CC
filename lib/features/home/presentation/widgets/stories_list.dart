import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../stories/data/models/story_item_model.dart';
import '../../../stories/data/models/user_stories_group_model.dart';
import '../../../stories/presentation/pages/story_viewer_screen.dart';
import '../../../stories/presentation/providers/stories_provider.dart';
import 'story_avatar.dart';

class StoriesList extends StatefulWidget {
  const StoriesList({super.key});

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  // Built-in community stories matching the Figma design to ensure home screen is lively
  static final List<UserStoriesGroupModel> _demoCommunityStories = [
    UserStoriesGroupModel(
      creatorId: 'demo_priya',
      creatorName: 'Priya',
      creatorUsername: 'priya_roy',
      creatorPic: 'assets/images/profile2.jpeg',
      hasUnviewed: true,
      items: [
        StoryItemModel(
          id: 'demo_s1',
          mediaUrl: 'assets/images/profile2.jpeg',
          mediaType: 'image',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        StoryItemModel(
          id: 'demo_s2',
          mediaUrl: 'assets/images/post1.jpeg',
          mediaType: 'image',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    UserStoriesGroupModel(
      creatorId: 'demo_shirisha',
      creatorName: 'Shirisha',
      creatorUsername: 'shirisha_k',
      creatorPic: 'assets/images/profile4.jpeg',
      hasUnviewed: true,
      items: [
        StoryItemModel(
          id: 'demo_s3',
          mediaUrl: 'assets/images/profile4.jpeg',
          mediaType: 'image',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    UserStoriesGroupModel(
      creatorId: 'demo_anjali',
      creatorName: 'Anjali',
      creatorUsername: 'anjali_art',
      creatorPic: 'assets/images/profile3.jpeg',
      hasUnviewed: true,
      items: [
        StoryItemModel(
          id: 'demo_s4',
          mediaUrl: 'assets/images/profile3.jpeg',
          mediaType: 'image',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    UserStoriesGroupModel(
      creatorId: 'demo_meena',
      creatorName: 'Meena',
      creatorUsername: 'meena_v',
      creatorPic: 'assets/images/profile5.jpeg',
      hasUnviewed: true,
      items: [
        StoryItemModel(
          id: 'demo_s5',
          mediaUrl: 'assets/images/profile5.jpeg',
          mediaType: 'image',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoriesProvider>().fetchStories(silent: true);
    });
  }

  void _openViewer(BuildContext context, List<UserStoriesGroupModel> groups, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          groups: groups,
          initialGroupIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storiesProvider = context.watch<StoriesProvider>();
    final myStoriesGroup = storiesProvider.myStoriesGroup;
    final hasMyStory = storiesProvider.hasMyStory;

    // Prefer server stories; combine with demo community stories if server list is empty
    final serverOtherStories = storiesProvider.otherStoriesGroups;
    final otherGroups = serverOtherStories.isNotEmpty ? serverOtherStories : _demoCommunityStories;

    final myProfilePic = LocalStorage.instance.getUserProfilePhoto();

    // Build the complete list of groups for viewer navigation
    final List<UserStoriesGroupModel> allGroups = [];
    if (hasMyStory && myStoriesGroup != null) {
      allGroups.add(myStoriesGroup);
    }
    allGroups.addAll(otherGroups);

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: otherGroups.length + 1, // +1 for "Your Story"
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          // 1. "Your Story" item at index 0
          if (index == 0) {
            return StoryAvatarItem(
              name: 'Your Story',
              imageUrl: myProfilePic,
              isMine: true,
              hasStory: hasMyStory,
              hasUnviewed: hasMyStory && (myStoriesGroup?.hasUnviewed ?? false),
              onTap: () {
                if (hasMyStory && myStoriesGroup != null) {
                  _openViewer(context, allGroups, 0);
                } else {
                  context.push(AppRoutes.storyUpload);
                }
              },
              onAddTap: () {
                context.push(AppRoutes.storyUpload);
              },
            );
          }

          // 2. Other users' stories
          final groupIndex = index - 1;
          final group = otherGroups[groupIndex];
          final isAsset = group.creatorPic != null && group.creatorPic!.startsWith('assets/');

          return StoryAvatarItem(
            name: group.displayName,
            imageUrl: !isAsset ? group.creatorPic : null,
            assetPath: isAsset ? group.creatorPic : null,
            isMine: false,
            hasStory: true,
            hasUnviewed: group.hasUnviewed,
            onTap: () {
              final viewerIndex = hasMyStory ? groupIndex + 1 : groupIndex;
              _openViewer(context, allGroups, viewerIndex);
            },
          );
        },
      ),
    );
  }
}