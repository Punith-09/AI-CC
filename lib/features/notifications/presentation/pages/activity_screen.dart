import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_end_text.dart';
import '../widgets/activity_tab_bar.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // force:true ensures we always load fresh on first visit;
      // subsequent back-and-forth navigations use cached data via _hasFetched guard.
      context.read<NotificationsProvider>().fetchNotifications(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        final allNotifications = provider.notifications;
        final displayList = switch (selectedTab) {
          1 => provider.unreadNotifications,
          2 => provider.readNotifications,
          _ => allNotifications,
        };

        Widget body;
        if (provider.isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (provider.error != null) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchNotifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (displayList.isEmpty) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 56,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "You're all caught up!",
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(force: true),
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayList.length + 1,
              separatorBuilder: (_, _a) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == displayList.length) {
                  return const ActivityEndText();
                }
                return ActivityCard(
                  notification: displayList[index],
                  onTap: () {
                    if (!displayList[index].isRead) {
                      provider.markAsRead(displayList[index].id);
                    }
                  },
                  onDelete: () => provider.deleteNotification(displayList[index].id),
                );
              },
            ),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            ActivityTabBar(
              selectedIndex: selectedTab,
              onChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(child: body),
          ],
        );
      },
    );

    Widget markAllAction() {
      return Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: provider.isActionLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: () async {
                      final success = await provider.markAllAsRead();
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.done_all_rounded,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        size: 20,
                      ),
                    ),
                  ),
          );
        },
      );
    }

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
          "Activity",
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          markAllAction(),
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) => PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onSelected: (value) async {
                if (value == 'clear_all') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear All Notifications'),
                      content: const Text(
                          'Are you sure you want to delete all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.clearAllNotifications();
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: content,
      ),
    );
  }
}
