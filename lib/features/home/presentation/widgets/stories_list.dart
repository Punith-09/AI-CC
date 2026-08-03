import 'package:flutter/material.dart';


import '../../data/datasource/story_data.dart';
import 'story_avatar.dart';

class StoriesList extends StatelessWidget {

  const StoriesList({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      height: 120,

      child: ListView.separated(

        scrollDirection: Axis.horizontal,

        itemBuilder: (_, index) {

          return StoryAvatar(
            story: stories[index],
          );

        },

        separatorBuilder: (_, __) =>
        const SizedBox(width: 18),

        itemCount: stories.length,

      ),

    );

  }

}