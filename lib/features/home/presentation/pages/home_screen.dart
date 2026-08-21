// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/widgets/app_background.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../providers/home_feed_provider.dart';
// import '../widgets/feed_card.dart';
// import '../widgets/home_appbar.dart';
// import '../widgets/recommendation_card.dart';
// import '../widgets/stories_list.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<HomeFeedProvider>().fetchFeed();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final feedProvider = context.watch<HomeFeedProvider>();
//     final posts = feedProvider.posts;
//     final isLoading = feedProvider.isLoading;
//     final errorMessage = feedProvider.errorMessage;
//
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: AppBackground(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             child: Column(
//               children: [
//                 const HomeAppbar(),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: RefreshIndicator(
//                     color: AppColors.primary,
//                     backgroundColor: const Color(0xFF102B36),
//                     onRefresh: () => feedProvider.refreshFeed(),
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(
//                         parent: BouncingScrollPhysics(),
//                       ),
//                       itemCount: _calculateItemCount(isLoading, errorMessage, posts.length),
//                       separatorBuilder: (context, index) => const SizedBox(height: 24),
//                       itemBuilder: (context, index) {
//                         // 1. Stories at the top
//                         if (index == 0) {
//                           return const StoriesList();
//                         }
//
//                         // 2. Loading State
//                         if (isLoading && posts.isEmpty) {
//                           return const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 48),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: AppColors.primary,
//                               ),
//                             ),
//                           );
//                         }
//
//                         // 3. Error State
//                         if (errorMessage != null && posts.isEmpty) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
//                             child: Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.error_outline_rounded,
//                                     color: Colors.redAccent,
//                                     size: 40,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     errorMessage,
//                                     style: const TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.primary,
//                                     ),
//                                     onPressed: () => feedProvider.fetchFeed(),
//                                     child: const Text('Retry'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }
//
//                         // 4. Empty Posts State
//                         if (posts.isEmpty) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 40),
//                             child: Column(
//                               children: [
//                                 const Icon(
//                                   Icons.photo_library_outlined,
//                                   color: Colors.white30,
//                                   size: 48,
//                                 ),
//                                 const SizedBox(height: 12),
//                                 const Text(
//                                   'No posts or videos yet',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 const Text(
//                                   'Be the first one to share a photo or video reel!',
//                                   style: TextStyle(
//                                     color: Colors.white38,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 const RecommendationCard(),
//                               ],
//                             ),
//                           );
//                         }
//
//                         // 5. Post Items
//                         final postIndex = index - 1;
//                         if (postIndex < posts.length) {
//                           return FeedCard(post: posts[postIndex]);
//                         }
//
//                         // 6. Recommendation Card at the bottom of feed
//                         return const RecommendationCard();
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   int _calculateItemCount(bool isLoading, String? error, int postsLength) {
//     if (isLoading && postsLength == 0) return 2; // Stories + Loader
//     if (error != null && postsLength == 0) return 2; // Stories + Error
//     if (postsLength == 0) return 2; // Stories + Empty card
//     return postsLength + 2; // Stories + Posts + Recommendation Card
//   }
// }





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/feed_card.dart';
import '../widgets/home_appbar.dart';
import '../widgets/recommendation_card.dart';
// import '../widgets/stories_list.dart'; // Temporarily disabled

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<HomeFeedProvider>();

    final posts = feedProvider.posts;
    final isLoading = feedProvider.isLoading;
    final errorMessage = feedProvider.errorMessage;

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
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: const Color(0xFF102B36),
                    onRefresh: () => feedProvider.refreshFeed(),

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
                        return const SizedBox(height: 24);
                      },

                      itemBuilder: (context, index) {

                        // 1. Loading State
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

                        // 2. Error State
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
                                    style: const TextStyle(
                                      color: Colors.white70,
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
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // 3. Empty Posts State
                        if (posts.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white30,
                                  size: 48,
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  'No posts or videos yet',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  'Be the first one to share a photo or video reel!',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const RecommendationCard(),
                              ],
                            ),
                          );
                        }

                        // 4. Post Items
                        if (index < posts.length) {
                          return FeedCard(
                            post: posts[index],
                          );
                        }

                        // 5. Recommendation Card
                        return const RecommendationCard();
                      },
                    ),
                  ),
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
      return 1; // Loader
    }

    if (error != null && postsLength == 0) {
      return 1; // Error
    }

    if (postsLength == 0) {
      return 1; // Empty state
    }

    return postsLength + 1; // Posts + Recommendation
  }
}