import 'dart:async';
// import 'package:aicc/features/auth/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import '../storage/local_storage.dart';
import '../responsive/responsive_breakpoints.dart';
import '../responsive/desktop_shell.dart';

import '../../common/widgets/custom_bottom_navbar.dart';
import '../../common/widgets/app_sidebar.dart';
import '../../core/utils/scaffold_key.dart';
import '../../features/messages/presentation/providers/messages_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';

import '../../features/apply_job/data/models/application_model.dart';
import '../../features/apply_job/presentation/pages/apply_screen.dart';
import '../../features/apply_job/presentation/pages/applied_auditions_screen.dart';
import '../../features/artist_profile/presentation/pages/artist_profile_screen.dart';
import '../../features/artist_profile/presentation/pages/edit_profile_screen.dart';
import '../../features/artist_profile/presentation/pages/complete_profile_screen.dart';
import '../../features/auditions/data/models/audition_model.dart';
import '../../features/auditions/presentation/pages/audition_details.dart';
import '../../features/messages/data/models/chat_model.dart';
import '../../features/auditions/presentation/pages/auditions_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/change_password_screen.dart';
import '../../features/auth/presentation/pages/delete_account_screen.dart';
import '../../features/creator_profile/presentation/pages/creator_profile_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/home/data/models/feed_post_model.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/watch_media_screen.dart';
import '../../features/messages/presentation/pages/chat_screen.dart';
import '../../features/messages/presentation/pages/messages_screen.dart';
import '../../features/notifications/presentation/pages/activity_screen.dart';
import '../../features/post/presentation/pages/post_screen.dart';
import '../../features/post/presentation/pages/upload_photo_screen.dart';
import '../../features/post/presentation/pages/upload_video_screen.dart';
import '../../features/explore/presentation/pages/explore_profile_screen.dart';
import '../../features/subscription/presentation/pages/subscription_screen.dart';
import '../../features/stories/presentation/pages/story_upload_screen.dart';
import '../../features/home/data/repository/home_repository.dart';
import '../../features/live_stats/presentation/pages/live_stats_screen.dart';
import '../../core/di/injection_container.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  redirect: (context, state) {
    final isLoggedIn = LocalStorage.instance.hasToken();
    final location = state.uri.path;

    final isAuthRoute =
        location == AppRoutes.welcome ||
        location == AppRoutes.login;

    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.home;
    }

    return null; // no redirect needed
  },

  errorBuilder: (context, state) {
    debugPrint('🌿 [AppRouter] Handled route error for: ${state.uri}');
    final uriStr = state.uri.toString().toLowerCase();
    if (uriStr.contains('delete') && uriStr.contains('account')) {
      return const DeleteAccountScreen();
    }

    if (uriStr.contains('reset') && uriStr.contains('password')) {
      final token = state.uri.queryParameters['token'] ??
          state.uri.queryParameters['deep_link_sub1'] ??
          state.uri.queryParameters['deep_link_sub2'] ??
          state.uri.queryParameters['otp'];
      final email = state.uri.queryParameters['email'];
      return ForgotPasswordScreen(token: token, initialEmail: email);
    }

    final id = state.uri.queryParameters['id'] ??
        state.uri.queryParameters['profile_id'] ??
        state.uri.queryParameters['deep_link_value'];

    if (id != null && id.trim().isNotEmpty) {
      return ExploreProfileScreen(userId: id.trim());
    }

    final isLoggedIn = LocalStorage.instance.hasToken();
    return isLoggedIn ? const HomeScreen() : const WelcomeScreen();
  },

  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) =>
          LocalStorage.instance.hasToken() ? AppRoutes.home : AppRoutes.welcome,
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'] ??
            state.uri.queryParameters['profile_id'] ??
            state.uri.queryParameters['deep_link_value'];
        if (id != null && id.trim().isNotEmpty) {
          return ExploreProfileScreen(userId: id.trim());
        }
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/delete-account',
      redirect: (_, __) => AppRoutes.deleteAccount,
    ),
    GoRoute(
      path: '/delete_account',
      redirect: (_, __) => AppRoutes.deleteAccount,
    ),
    GoRoute(
      path: '/auth/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ??
            state.uri.queryParameters['deep_link_sub1'] ??
            state.uri.queryParameters['deep_link_sub2'] ??
            state.uri.queryParameters['otp'];
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(token: token, initialEmail: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ??
            state.uri.queryParameters['deep_link_sub1'] ??
            state.uri.queryParameters['deep_link_sub2'] ??
            state.uri.queryParameters['otp'];
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(token: token, initialEmail: email);
      },
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ??
            state.uri.queryParameters['deep_link_sub1'] ??
            state.uri.queryParameters['deep_link_sub2'] ??
            state.uri.queryParameters['otp'];
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(token: token, initialEmail: email);
      },
    ),
    GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),

    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ??
            state.uri.queryParameters['deep_link_sub1'] ??
            state.uri.queryParameters['deep_link_sub2'] ??
            state.uri.queryParameters['otp'];
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(token: token, initialEmail: email);
      },
    ),

    GoRoute(
      path: AppRoutes.changePassword,
      builder: (_, __) => const ChangePasswordScreen(),
    ),

    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (_, __) => const DeleteAccountScreen(),
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final extra = state.extra;
        final chat = extra is ChatModel ? extra : null;
        return ChatScreen(chat: chat);
      },
    ),

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
          return ApplyScreen(audition: extra);
        }

        // -----------------------------------------------------
        // EDIT APPLICATION
        // -----------------------------------------------------

        if (extra is ApplicationModel) {
          return ApplyScreen(application: extra);
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
          return AuditionDetails(audition: extra, auditionId: extra.id);
        }

        if (extra is String) {
          return AuditionDetails(auditionId: extra);
        }

        return const AuditionDetails();
      },
    ),

    // =========================================================
    // UPLOAD PHOTO
    // =========================================================
    GoRoute(
      path: AppRoutes.uploadPhoto,
      builder: (_, __) => const UploadPhotoScreen(),
    ),

    // =========================================================
    // UPLOAD VIDEO
    // =========================================================
    GoRoute(
      path: AppRoutes.uploadVideo,
      builder: (_, __) => const UploadVideoScreen(),
    ),

    // =========================================================
    // APPLIED AUDITIONS
    // =========================================================
    GoRoute(
      path: AppRoutes.appliedAuditions,
      builder: (_, __) => const AppliedAuditionsScreen(),
    ),

    // =========================================================
    // EXPLORE PROFILE (public view from explore tap)
    // =========================================================
    GoRoute(
      path: AppRoutes.exploreProfile,
      builder: (context, state) {
        final userId = (state.extra as String?) ??
            state.uri.queryParameters['userId'] ??
            state.uri.queryParameters['profile_id'] ??
            '';
        return ExploreProfileScreen(userId: userId);
      },
    ),

    // =========================================================
    // WATCH MEDIA / VIDEO SCREEN
    // =========================================================
    GoRoute(
      path: AppRoutes.watchVideo,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is FeedPostModel) {
          return WatchMediaScreen(post: extra);
        }
        // Notification tap passes a String post/video ID
        if (extra is String && extra.isNotEmpty) {
          return _PostLoaderScreen(postId: extra);
        }
        return const Scaffold(body: Center(child: Text('Media not found')));
      },
    ),

    // =========================================================
    // STORY UPLOAD SCREEN
    // =========================================================
    GoRoute(
      path: AppRoutes.storyUpload,
      builder: (_, __) => const StoryUploadScreen(),
    ),

    // =========================================================
    // LIVE STATS SCREEN
    // =========================================================
    GoRoute(
      path: AppRoutes.liveStats,
      builder: (_, __) => const LiveStatsScreen(),
    ),

    // =========================================================
    // MAIN SHELL
    // =========================================================
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },

      routes: [
        // -----------------------------------------------------
        // HOME
        // -----------------------------------------------------
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),

        // -----------------------------------------------------
        // EXPLORE
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.explore,
          builder: (_, __) => const ExploreScreen(),
        ),

        // -----------------------------------------------------
        // POST
        // -----------------------------------------------------
        GoRoute(path: AppRoutes.post, builder: (_, __) => const PostScreen()),

        // -----------------------------------------------------
        // AUDITIONS
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.auditions,
          builder: (_, __) => const AuditionScreen(),
        ),

        // -----------------------------------------------------
        // ACTIVITY
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.activity,
          builder: (_, __) => const ActivityScreen(),
        ),

        // -----------------------------------------------------
        // EDIT ARTIST PROFILE
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.editArtistProfile,
          builder: (_, __) => const EditProfileScreen(),
        ),

        // -----------------------------------------------------
        // COMPLETE ARTIST PROFILE
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.completeProfile,
          builder: (_, __) => const CompleteProfileScreen(),
        ),

        // -----------------------------------------------------
        // COMPLETE ARTIST PROFILE STEP 2
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.completeProfileStep2,
          builder: (_, __) => const CompleteProfileScreen(initialStep: 1),
        ),

        // -----------------------------------------------------
        // COMPLETE ARTIST PROFILE STEP 3
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.completeProfileStep3,
          builder: (_, __) => const CompleteProfileScreen(initialStep: 2),
        ),

        // -----------------------------------------------------
        // COMPLETE ARTIST PROFILE STEP 4
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.completeProfileStep4,
          builder: (_, __) => const CompleteProfileScreen(initialStep: 3),
        ),

        // -----------------------------------------------------
        // COMPLETE ARTIST PROFILE STEP 5
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.completeProfileStep5,
          builder: (_, __) => const CompleteProfileScreen(initialStep: 4),
        ),

        // -----------------------------------------------------
        // ARTIST PROFILE
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.artistProfile,
          builder: (_, __) => const ArtistProfileScreen(),
        ),

        // -----------------------------------------------------
        // SUBSCRIPTION
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.subscription,
          builder: (context, state) => const SubscriptionScreen(),
        ),

        // -----------------------------------------------------
        // CREATOR PROFILE
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.creatorProfile,
          builder: (_, __) => const CreatorProfileScreen(),
        ),

        // -----------------------------------------------------
        // MESSAGES
        // -----------------------------------------------------
        GoRoute(
          path: AppRoutes.messages,
          builder: (_, __) => const MessagesScreen(),
        ),
      ],
    ),
  ],
);

// ===========================================================
// MAIN SCREEN
// ===========================================================

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _messagePollTimer;

  @override
  void initState() {
    super.initState();

    // Fetch initial chat unread status on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MessagesProvider>().fetchChats(silent: true);
        context.read<NotificationsProvider>().fetchUnreadCount();
      }
    });

    // Background poll every 4 seconds so message badge reflects live incoming messages across all tabs
    _messagePollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        context.read<MessagesProvider>().fetchChats(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _messagePollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    if (isDesktop) {
      return DesktopShell(
        currentLocation: currentLocation,
        child: widget.child,
      );
    }

    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      drawer: const AppSidebar(),
      body: widget.child,
      bottomNavigationBar: CustomBottomNavbar(
        currentLocation: currentLocation,

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

// =========================================================
// POST LOADER SCREEN
// Used when navigation comes from notifications with only a post ID.
// Fetches the post from the API then pushes WatchMediaScreen.
// =========================================================

class _PostLoaderScreen extends StatefulWidget {
  final String postId;
  const _PostLoaderScreen({required this.postId});

  @override
  State<_PostLoaderScreen> createState() => _PostLoaderScreenState();
}

class _PostLoaderScreenState extends State<_PostLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final post = await sl<HomeRepository>().getVideoById(widget.postId);
      if (!mounted) return;
      if (post != null) {
        // Replace this loader with the actual watch screen
        context.pushReplacement(AppRoutes.watchVideo, extra: post);
      } else {
        _showError();
      }
    } catch (_) {
      if (mounted) _showError();
    }
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not load post. Please try again.'),
        backgroundColor: Colors.redAccent,
      ),
    );
    if (Navigator.of(context).canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF4AD0FB),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading post...',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
