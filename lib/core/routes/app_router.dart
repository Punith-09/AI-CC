import 'package:aicc/features/roles/presentation/pages/roles_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../storage/local_storage.dart';

import '../../common/widgets/custom_bottom_navbar.dart';

import '../../features/apply_job/data/models/application_model.dart';
import '../../features/apply_job/presentation/pages/apply_screen.dart';
import '../../features/apply_job/presentation/pages/applied_auditions_screen.dart';
import '../../features/artist_profile/presentation/pages/artist_profile_screen.dart';
import '../../features/artist_profile/presentation/pages/edit_profile_screen.dart';
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
import '../../features/messages/presentation/pages/messages_screen.dart';
import '../../features/notifications/presentation/pages/activity_screen.dart';
import '../../features/post/presentation/pages/post_screen.dart';
import '../../features/post/presentation/pages/upload_photo_screen.dart';
import '../../features/post/presentation/pages/upload_video_screen.dart';
import '../../features/explore/presentation/pages/explore_profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,

  // =========================================================
  // AUTH REDIRECT
  // Runs on every navigation. If a valid token exists in
  // LocalStorage the user is already logged in, so we skip
  // the welcome / login screens and go straight to home.
  // =========================================================
  redirect: (context, state) {
    final isLoggedIn = LocalStorage.instance.hasToken();
    final location = state.uri.toString();

    final isAuthRoute =
        location == AppRoutes.welcome ||
        location == AppRoutes.login ||
        location == AppRoutes.signup;

    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.home;
    }

    return null; // no redirect needed
  },

  routes: [
    // =========================================================
    // WELCOME
    // =========================================================

    GoRoute(
      path: AppRoutes.welcome,
      builder: (_, __) =>
      const WelcomeScreen(),
    ),

    // =========================================================
    // LOGIN
    // =========================================================

    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) =>
      const LoginScreen(),
    ),

    // =========================================================
    // SIGN UP
    // =========================================================

    GoRoute(
      path: AppRoutes.signup,
      builder: (_, __) =>
      const SignUpWizardPage(),
    ),

    // =========================================================
    // MESSAGES INBOX
    // =========================================================

    GoRoute(
      path: AppRoutes.messages,
      builder: (_, __) => const MessagesScreen(),
    ),

    // =========================================================
    // CHAT
    // =========================================================

    GoRoute(
      path: AppRoutes.chat,
      builder: (_, __) =>
      const ChatScreen(),
    ),

    // =========================================================
    // APPLY / EDIT APPLICATION
    // =========================================================

    GoRoute(
      path: AppRoutes.applyJob,

      builder: (context, state) {
        final extra = state.extra;

        print('');
        print('========================================');
        print('🧭 APPLY ROUTE');
        print('========================================');
        print('EXTRA TYPE: ${extra.runtimeType}');
        print('EXTRA: $extra');
        print('========================================');

        // -----------------------------------------------------
        // CREATE APPLICATION
        // -----------------------------------------------------

        if (extra is AuditionModel) {
          return ApplyScreen(
            audition: extra,
          );
        }

        // -----------------------------------------------------
        // EDIT APPLICATION
        // -----------------------------------------------------

        if (extra is ApplicationModel) {
          return ApplyScreen(
            application: extra,
          );
        }

        // -----------------------------------------------------
        // FALLBACK
        // -----------------------------------------------------

        return const ApplyScreen();
      },
    ),

    // =========================================================
    // AUDITION DETAILS
    // =========================================================

    GoRoute(
      path: AppRoutes.auditionDetails,

      builder: (context, state) {
        final extra = state.extra;

        if (extra is AuditionModel) {
          return AuditionDetails(
            audition: extra,
            auditionId: extra.id,
          );
        }

        if (extra is String) {
          return AuditionDetails(
            auditionId: extra,
          );
        }

        return const AuditionDetails();
      },
    ),

    // =========================================================
    // ROLES
    // =========================================================

    GoRoute(
      path: AppRoutes.role,
      builder: (_, __) =>
          RolesScreen(),
    ),

    // =========================================================
    // UPLOAD PHOTO
    // =========================================================

    GoRoute(
      path: AppRoutes.uploadPhoto,
      builder: (_, __) =>
      const UploadPhotoScreen(),
    ),

    // =========================================================
    // UPLOAD VIDEO
    // =========================================================

    GoRoute(
      path: AppRoutes.uploadVideo,
      builder: (_, __) =>
      const UploadVideoScreen(),
    ),

    // =========================================================
    // APPLIED AUDITIONS
    // =========================================================

    GoRoute(
      path: AppRoutes.appliedAuditions,
      builder: (_, __) =>
      const AppliedAuditionsScreen(),
    ),

    // =========================================================
    // EXPLORE PROFILE (public view from explore tap)
    // =========================================================

    GoRoute(
      path: AppRoutes.exploreProfile,
      builder: (context, state) {
        final userId = state.extra as String? ?? '';
        return ExploreProfileScreen(userId: userId);
      },
    ),

    // =========================================================
    // MAIN SHELL
    // =========================================================

    ShellRoute(
      builder: (
          context,
          state,
          child,
          ) {
        return MainScreen(
          child: child,
        );
      },

      routes: [
        // -----------------------------------------------------
        // HOME
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) =>
          const HomeScreen(),
        ),

        // -----------------------------------------------------
        // EXPLORE
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.explore,
          builder: (_, __) =>
          const ExploreScreen(),
        ),

        // -----------------------------------------------------
        // POST
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.post,
          builder: (_, __) =>
          const PostScreen(),
        ),

        // -----------------------------------------------------
        // AUDITIONS
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.auditions,
          builder: (_, __) =>
          const AuditionScreen(),
        ),

        // -----------------------------------------------------
        // ACTIVITY
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.activity,
          builder: (_, __) =>
          const ActivityScreen(),
        ),

        // -----------------------------------------------------
        // EDIT ARTIST PROFILE
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.editArtistProfile,
          builder: (_, __) =>
          const EditProfileScreen(),
        ),

        // -----------------------------------------------------
        // ARTIST PROFILE
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.artistProfile,
          builder: (_, __) =>
          const ArtistProfileScreen(),
        ),

        // -----------------------------------------------------
        // CREATOR PROFILE
        // -----------------------------------------------------

        GoRoute(
          path: AppRoutes.creatorProfile,
          builder: (_, __) =>
          const CreatorProfileScreen(),
        ),
      ],
    ),
  ],
);

// ===========================================================
// MAIN SCREEN
// ===========================================================

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation =
    GoRouterState.of(context)
        .uri
        .toString();

    return Scaffold(
      extendBody: true,

      body: child,

      bottomNavigationBar:
      CustomBottomNavbar(
        currentLocation:
        currentLocation,

        onItemSelected: (route) {
          // IMPORTANT:
          // Always use GO for bottom navigation.
          //
          // PUSH will create:
          //
          // Home -> Explore -> Auditions -> Home
          //
          // which causes navigation-stack problems.

          if (currentLocation != route) {
            context.go(route);
          }
        },
      ),
    );
  }
}