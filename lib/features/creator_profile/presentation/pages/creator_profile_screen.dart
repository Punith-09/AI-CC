import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/action_buttons.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/creator_avatar.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/creator_header.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/creator_info.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/post_grid.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/profile_tabs.dart';
import 'package:aicc/features/creator_profile/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';

class CreatorProfileScreen extends StatelessWidget {
  const CreatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: SafeArea(
          top: false,

          child: SingleChildScrollView(
            child: Column(
              children: [

                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    const CreatorHeader(),

                    Positioned(
                      bottom: -45,
                      child: CreatorAvatar(),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                const CreatorInfo(),

                const SizedBox(height: 28),

                const StatsCard(),

                const SizedBox(height: 24),

                const ActionButtons(),

                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ProfileTabs(),
                ),

                const SizedBox(height: 25),

                const PostGrid(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
