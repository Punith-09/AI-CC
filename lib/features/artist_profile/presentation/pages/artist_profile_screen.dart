import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/artist_avatar.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/artist_info.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/audition_button.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/info_section.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/portfolio_grid.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/portfolio_header.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/profile_header.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/role_chips.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/social_links.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';

import '../../data/datasource/portfolio_data.dart';

class ArtistProfileScreen extends StatelessWidget {
  const ArtistProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const ProfileHeader(),

                    Positioned(
                      left: 24,
                      bottom: -45,
                      child: const ArtistAvatar(),
                    ),

                    Positioned(
                      left: 150, // Increase this
                      bottom: -30,
                      child: const ArtistInfo(),
                    ),
                  ],
                ),

                const SizedBox(height: 40),



                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: RoleChips(),
                ),

                const SizedBox(height: 28),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: StatsCard(),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: InfoSection(),
                ),

                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PortfolioHeader(),
                ),

                const SizedBox(height: 18),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PortfolioGrid(
                    items: portfolioList,
                  ),
                ),

                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SocialLinks(),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AuditionButton(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
