import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/features/creator_profile/data/datasource/creator_posts.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: creatorPosts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isDesktop ? .85 : .72,
      ),
      itemBuilder: (_, index) {
        return PostCard(
          post: creatorPosts[index],
        );
      },
    );
  }
}