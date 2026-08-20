import 'package:aicc/features/roles/presentation/pages/roles_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

import '../../common/widgets/custom_bottom_navbar.dart';

import '../../features/apply_job/presentation/pages/apply_screen.dart';
import '../../features/artist_profile/presentation/pages/artist_profile_screen.dart';
import '../../features/auditions/data/models/audition_model.dart';
import '../../features/auditions/presentation/pages/audition_details.dart';
import '../../features/auditions/presentation/pages/auditions_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/creator_profile/presentation/pages/creator_profile_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/messages/presentation/pages/chat_screen.dart';
import '../../features/notifications/presentation/pages/activity_screen.dart';
import '../../features/post/presentation/pages/post_screen.dart';
import '../../features/post/presentation/pages/upload_photo_screen.dart';
import '../../features/post/presentation/pages/upload_video_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,

  routes: [

    GoRoute(
      path: AppRoutes.welcome,
      builder: (_, __) => const WelcomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.signup,
      builder: (_, __) => const SignUpWizardPage(),
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (_, __) => const ChatScreen(),
    ),

    GoRoute(
      path: AppRoutes.applyJob,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is AuditionModel) {
          return ApplyScreen(audition: extra);
        }
        return const ApplyScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.auditionDetails,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is AuditionModel) {
          return AuditionDetails(audition: extra, auditionId: extra.id);
        } else if (extra is String) {
          return AuditionDetails(auditionId: extra);
        }
        return const AuditionDetails();
      },
    ),
    GoRoute(
      path: AppRoutes.role,
      builder: (_, __) =>  RolesScreen(),
    ),
    GoRoute(
      path: AppRoutes.uploadPhoto,
      builder: (_, __) => const UploadPhotoScreen(),
    ),
    GoRoute(
      path: AppRoutes.uploadVideo,
      builder: (_, __) => const UploadVideoScreen(),
    ),

    ShellRoute(

      builder: (_, __, child) {

        return MainScreen(child: child);

      },

      routes: [

        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomeScreen(),
        ),

        GoRoute(
          path: AppRoutes.explore,
          builder: (_, __) => const ExploreScreen(),
        ),

        GoRoute(
          path: AppRoutes.post,
          builder: (_, __) => const PostScreen(),
        ),

        GoRoute(
          path: AppRoutes.auditions,
          builder: (_, __) => const AuditionScreen(),
        ),

        GoRoute(
          path: AppRoutes.activity,
          builder: (_, __) => const ActivityScreen(),
        ),

        GoRoute(
          path: AppRoutes.artistProfile,
          builder: (_, __) => const ArtistProfileScreen(),
        ),

        GoRoute(
          path: AppRoutes.creatorProfile,
          builder: (_, __) => const CreatorProfileScreen(),
        ),
      ],
    )
  ],
);

class MainScreen extends StatelessWidget {

  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      body: child,

      bottomNavigationBar: CustomBottomNavbar(

        currentLocation: GoRouterState.of(context).uri.toString(),

        onItemSelected: (route) {
          if(route == "/home") {
            context.go(route);
          }else{
            context.push(route);
          }

        },
      ),
    );
  }
}