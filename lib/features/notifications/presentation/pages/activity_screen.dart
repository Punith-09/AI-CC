import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/activity_tab_bar.dart';
import '../../data/models/notification_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> all,
    int tab,
  ) {
    switch (tab) {
      case 1: // Matches
        return all
            .where((n) =>
                n.type.toLowerCase().contains('match') ||
                n.type.toLowerCase().contains('ai'))
            .toList();
      case 2: // Updates
        return all
            .where((n) =>
                n.type.toLowerCase() == 'application' ||
                n.type.toLowerCase() == 'verification' ||
                n.type.toLowerCase() == 'audition')
            .toList();
      default: // All
        return all;
    }
  }

  Future<void> _onMarkAllRead(BuildContext context) async {
    await context.read<NotificationsProvider>().markAllAsRead();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<NotificationsProvider>().clearAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        final filtered =
            _filterNotifications(provider.notifications, _selectedTab);

        return Column(
          children: [
            const SizedBox(height: 16),
            ActivityTabBar(
              selectedIndex: _selectedTab,
              onChanged: (index) {
                setState(() => _selectedTab = index);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildBody(
                context,
                provider: provider,
                filtered: filtered,
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (_, provider, __) {
              if (provider.isActing) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                onSelected: (value) {
                  if (value == 'mark_read') _onMarkAllRead(context);
                  if (value == 'clear_all') _onClearAll(context);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded,
                            size: 18, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text('Clear all',
                            style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: content,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required NotificationsProvider provider,
    required List<NotificationModel> filtered,
    required bool isDark,
  }) {
    // Loading
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error
    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () =>
                    provider.fetchNotifications(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You're all caught up!",
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      onRefresh: () => provider.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtered.length + 1, // +1 for end text
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return const _EndText();
          }
          return NotificationCard(notification: filtered[index]);
        },
      ),
    );
  }
}

class _EndText extends StatelessWidget {
  const _EndText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(
          'You\'re all caught up!',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }
}
