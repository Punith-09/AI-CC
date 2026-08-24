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
import 'package:go_router/go_router.dart';
import 'package:aicc/core/routes/app_routes.dart';

import '../../data/datasource/portfolio_data.dart';

import 'package:provider/provider.dart';
import '../../presentation/providers/profile_provider.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String? userId; // Optional ID for viewing other users
  const ArtistProfileScreen({super.key, this.userId});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        context.read<ProfileProvider>().fetchUserProfile(widget.userId!);
      } else {
        context.read<ProfileProvider>().fetchMyProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              // Depending on whether it's 'me' or someone else:
              final profile = widget.userId != null ? provider.viewedProfile : provider.currentProfile;
              
              // We just let the widgets use dummy data for now or fallback, 
              // but we integrated the API layer properly.
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileHeader(coverImage: profile?.coverImage),

                        Positioned(
                          left: 24,
                          bottom: -45,
                          child: ArtistAvatar(profileImage: profile?.profileImage),
                        ),

                        Positioned(
                          left: 150, 
                          bottom: -30,
                          child: ArtistInfo(
                            name: profile?.name,
                            city: profile?.city,
                            state: profile?.state,
                          ),
                        ),

                        // Edit Button for the current user
                        if (widget.userId == null)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                              ),
                              icon: const Icon(Icons.mode_edit_outline_rounded, color: Colors.white),
                              onPressed: () {
                                context.push(AppRoutes.editArtistProfile);
                              },
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: RoleChips(roles: profile?.roles),
                    ),

                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StatsCard(
                        projects: profile?.projects,
                        followers: profile?.followers,
                        awards: profile?.awards,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InfoSection(
                        experience: profile?.experience,
                        languages: profile?.languages,
                      ),
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      // Mocking the follow button integration over Audition Button
                      child: GestureDetector(
                        onTap: () {
                          if (widget.userId != null) {
                             provider.followUser(widget.userId!);
                          }
                        },
                        child: const AuditionButton(),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
