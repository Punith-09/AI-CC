import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../messages/presentation/providers/messages_provider.dart';
import '../../../stories/presentation/providers/stories_provider.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/feed_card.dart';
import '../widgets/home_appbar.dart';
import '../widgets/stories_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeFeedProvider>().fetchFeed();
      context.read<MessagesProvider>().fetchChats(silent: true);
      context.read<StoriesProvider>().fetchStories(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<HomeFeedProvider>();

    final posts = feedProvider.posts;
    final isLoading = feedProvider.isLoading;
    final errorMessage = feedProvider.errorMessage;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final feedListWidget = RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      onRefresh: () async {
        await Future.wait([
          feedProvider.refreshFeed(),
          context.read<StoriesProvider>().fetchStories(silent: true),
        ]);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _calculateItemCount(
          isLoading,
          errorMessage,
          posts.length,
        ),
        separatorBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 16);
          }
          return const SizedBox(height: 24);
        },
        itemBuilder: (context, index) {
          // 1. Stories at the top
          if (index == 0) {
            return const StoriesList();
          }

          final postIndex = index - 1;

          // 2. Loading State
          if (isLoading && posts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          // 3. Error State
          if (errorMessage != null && posts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 16,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        feedProvider.fetchFeed();
                        context.read<StoriesProvider>().fetchStories(silent: true);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Empty Posts State
          if (posts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No posts or videos yet',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first one to share a photo or video reel!',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          // 5. Post Items
          return FeedCard(
            post: posts[postIndex],
          );
        },
      ),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: feedListWidget,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Column(
              children: [
                const HomeAppbar(),
                const SizedBox(height: 16),
                Expanded(
                  child: feedListWidget,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateItemCount(
    bool isLoading,
    String? error,
    int postsLength,
  ) {
    if (isLoading && postsLength == 0) {
      return 2; // Stories + Loader
    }

    if (error != null && postsLength == 0) {
      return 2; // Stories + Error
    }

    if (postsLength == 0) {
      return 2; // Stories + Empty state
    }

    return postsLength + 1; // Stories + Posts
  }
}