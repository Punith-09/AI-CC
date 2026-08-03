import 'package:aicc/features/creator_profile/data/datasource/creator_posts.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.symmetric(horizontal: 20),

      itemCount: creatorPosts.length,

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 2,

        crossAxisSpacing: 14,

        mainAxisSpacing: 14,

        childAspectRatio: .72,
      ),

      itemBuilder: (_, index) {
        return PostCard(
          post: creatorPosts[index],
        );
      },
    );
  }
}