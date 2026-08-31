import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/artist_avatar.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/artist_info.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/audition_button.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/info_section.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/portfolio_grid.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/portfolio_header.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/profile_header.dart';
import 'package:aicc/features/artist_profile/presentation/widgets/role_chips.dart';

import 'package:aicc/features/artist_profile/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            )
                          else
                            const SizedBox(width: 48),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            tooltip: "Logout",
                            onPressed: () async {
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                context.go(AppRoutes.welcome);
                              }
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF123B4A).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                color: Colors.redAccent,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Unable to Load Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await context.read<AuthProvider>().logout();
                                      if (context.mounted) {
                                        context.go(AppRoutes.welcome);
                                      }
                                    },
                                    icon: const Icon(Icons.logout, size: 18),
                                    label: const Text("Log Out"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF087F9C),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (widget.userId != null) {
                                        context.read<ProfileProvider>().fetchUserProfile(widget.userId!);
                                      } else {
                                        context.read<ProfileProvider>().fetchMyProfile();
                                      }
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text("Retry"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              }
              
              // Depending on whether it's 'me' or someone else:
              final profile = widget.userId != null ? provider.viewedProfile : provider.currentProfile;
              final mediaList = widget.userId != null ? provider.viewedMedia : provider.myMedia;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const ProfileHeader(),

                    const SizedBox(height: 12),

                    Center(
                      child: ArtistAvatar(
                        profileImage: profile?.profileImage,
                        name: profile?.name,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: ArtistInfo(
                        name: profile?.name,
                        city: profile?.city,
                        state: profile?.state,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: RoleChips(roles: profile?.roles),
                      ),
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

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InfoSection(
                        experience: profile?.experience,
                        languages: profile?.languages,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: PortfolioHeader(),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PortfolioGrid(
                        items: mediaList,
                      ),
                    ),

                    if (widget.userId != null) ...[
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            provider.followUser(widget.userId!);
                          },
                          child: const AuditionButton(),
                        ),
                      ),
                    ],

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
