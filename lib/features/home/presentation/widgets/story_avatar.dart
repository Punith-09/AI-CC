import 'package:flutter/material.dart';

import '../../../../common/models/story_model.dart';
import '../../../../core/constants/app_colors.dart';


class StoryAvatar extends StatelessWidget {

  final StoryModel story;

  const StoryAvatar({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: 82,

      child: Column(

        children: [

          Stack(

            clipBehavior: Clip.none,

            children: [

              Container(

                padding: const EdgeInsets.all(3),

                decoration: BoxDecoration(

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.8),
                    width: 2,
                  ),

                ),

                child: CircleAvatar(

                  radius: 34,

                  backgroundImage:
                  AssetImage(story.image),

                ),

              ),

              if(story.isMine)

                Positioned(

                  right: 2,
                  bottom: 2,

                  child: Container(

                    width: 24,
                    height: 24,

                    decoration:  BoxDecoration(

                      color: AppColors.primary.withOpacity(0.8),

                      shape: BoxShape.circle,

                    ),

                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),

                  ),

                ),

              if(story.isLive)

                Positioned(

                  bottom: -8,
                  left: 18,

                  child: Container(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),

                    decoration: BoxDecoration(

                      color: AppColors.primary.withOpacity(0.8),

                      borderRadius:
                      BorderRadius.circular(12),

                    ),

                    child: const Text(

                      "LIVE",

                      style: TextStyle(
                        color: AppColors.white,

                        fontSize: 10,

                        fontWeight: FontWeight.w900,

                      ),

                    ),

                  ),

                )

            ],

          ),

          const SizedBox(height: 10),

          Text(

            story.name,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500
            ),

          ),

        ],

      ),

    );

  }

}