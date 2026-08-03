import 'package:aicc/features/apply_job/presentation/pages/apply_screen.dart';
import 'package:aicc/features/artist_profile/presentation/pages/artist_profile_screen.dart';
import 'package:aicc/features/auditions/presentation/pages/audition_details.dart';
import 'package:aicc/features/auth/presentation/pages/signup_screen.dart';
import 'package:aicc/features/creator_profile/presentation/pages/creator_profile_screen.dart';
import 'package:aicc/features/explore/presentation/pages/explore_screen.dart';
import 'package:aicc/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/custom_bottom_navbar.dart';
import '../../features/messages/presentation/pages/chat_screen.dart';

import '../../features/auditions/presentation/pages/auditions_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/welcome_Screen.dart';
import '../../features/notifications/presentation/pages/activity.dart';
import '../../features/post/presentation/pages/post_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',

  routes: [
    GoRoute(path: '/welcome', builder: (context, state) => WelcomeScreen()),

    GoRoute(path: '/login', builder: (context, state) => Login()),
    GoRoute(path: '/signup', builder: (context, state) => SignUpWizardPage()),

    GoRoute(path: '/chat',builder: (context,state)=> ChatScreen()),
    GoRoute(path: '/auditionDetails',builder: (context,state)=> AuditionDetails()),
    GoRoute(path: '/applyScreen',builder: (context,state)=> ApplyScreen()),

    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },

      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) => const PostScreen(),
        ),
        GoRoute(
          path: '/auditions',
          builder: (context, state) => const AIRecommendationScreen(),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen()
        ),
        GoRoute(
          path: '/artistProfile',
          builder: (context, state) => const ArtistProfileScreen(),
        ),
        GoRoute(
          path: '/creatorProfile',
          builder: (context, state) => const CreatorProfileScreen(),
        ),
      ],
    ),
  ],
);

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      extendBody: true,
      body: child,

      bottomNavigationBar:  const CustomBottomNavbar(),

    );
  }
}
