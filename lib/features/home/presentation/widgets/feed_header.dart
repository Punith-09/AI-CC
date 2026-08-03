import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/models/post_model.dart';
import '../../../../core/constants/app_colors.dart';

class FeedHeader extends StatelessWidget {
  final PostModel post;

  const FeedHeader({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: const EdgeInsets.only(left: 16,top: 16,right: 16,bottom: 0),
        child: Row(
          children: [

            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(post.profileImage),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (post.isVerified) ...[
                        const SizedBox(width: 5),

                        const Icon(
                          Icons.verified,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [

                      const Icon(
                        LucideIcons.mapPin,
                        size: 13,
                        color: Colors.white70,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        post.location,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Icon(Icons.more_horiz),
          ],
        )
      );

  }
}