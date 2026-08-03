import 'package:aicc/features/creator_profile/data/models/creator_post.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/like_badge.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {

  final CreatorPost post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),

      child: AspectRatio(
        aspectRatio: .8,

        child: Stack(
          fit: StackFit.expand,
          children: [

            Image.asset(
              post.image,
              fit: BoxFit.cover,
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(.45),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: LikeBadge(
                likes: post.likes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}