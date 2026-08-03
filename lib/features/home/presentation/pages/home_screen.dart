import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/home/data/datasource/posts_data.dart';
import 'package:aicc/features/home/presentation/widgets/feed_card.dart';
import 'package:aicc/features/home/presentation/widgets/home_appbar.dart';
import 'package:aicc/features/home/presentation/widgets/recommendation_card.dart';
import 'package:aicc/features/home/presentation/widgets/stories_list.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Column(
              children: [
                const HomeAppbar(),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),

                    itemCount: postsData.length + 2,

                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 20),

                    itemBuilder: (context, index) {

                      if(index == 0){
                        return const StoriesList();
                      }

                      if(index == postsData.length + 1){
                        return const RecommendationCard();
                      }

                      return FeedCard(
                        post: postsData[index - 1],
                      );

                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
