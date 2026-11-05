import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoriesProvider>().fetchStories(silent: true);
    });
  }

  void _openViewer(BuildContext context, List<UserStoriesGroupModel> groups, int initialIndex) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
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

    final otherGroups = storiesProvider.otherStoriesGroups;
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