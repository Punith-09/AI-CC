import 'package:flutter/material.dart';

import '../../../../common/models/post_model.dart';


class FeedCaption extends StatelessWidget {
  final PostModel post;

  const FeedCaption({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: const EdgeInsets.only(left: 16,top: 0,right: 16,bottom: 16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "${post.likes} likes",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.45,
                ),
                children: [

                  TextSpan(
                    text: "${post.userName} ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  TextSpan(
                    text: post.caption,
                  ),

                  TextSpan(
                    text: " ${post.hashtags}",
                    style: const TextStyle(
                      color: Color(0xff4C8DFF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              post.time,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ) ,
      );

  }
}