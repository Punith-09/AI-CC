import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/features/notifications/data/models/notification_model.dart';
import 'package:aicc/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/activity_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications(force: true);
    });
  }

  // ── Time-grouping helpers ─────────────────────────────────────────────────

  /// Returns the section label for a notification's date.
  String? _sectionFor(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff <= 7) return 'Last 7 days';
    if (diff <= 30) return 'Last 30 days';
    return 'Older';
  }

  /// Splits a flat list into ordered (sectionLabel, items) pairs.
  List<MapEntry<String, List<NotificationModel>>> _group(
      List<NotificationModel> list) {
    final order = ['Today', 'Last 7 days', 'Last 30 days', 'Older'];
    final map = <String, List<NotificationModel>>{};
    for (final n in list) {
      final sec = _sectionFor(n.createdAt) ?? 'Older';
      map.putIfAbsent(sec, () => []).add(n);
    }
    return order
        .where((k) => map.containsKey(k))
        .map((k) => MapEntry(k, map[k]!))
        .toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        Widget body;

        if (provider.isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (provider.error != null) {
          body = _ErrorBody(
            message: provider.error!,
            onRetry: () => provider.fetchNotifications(),
            isDark: isDark,
          );
        } else if (provider.notifications.isEmpty) {
          body = _EmptyBody(isDark: isDark);
        } else {
          final groups = _group(provider.notifications);
          // Build a flat item list: [header, card, card…, header, card…]
          final items = <_ListItem>[];
          for (final entry in groups) {
            items.add(_ListItem.header(entry.key));
            for (final n in entry.value) {
              items.add(_ListItem.notification(n));
            }
          }

          body = RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(force: true),
            color: AppColors.primary,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.isHeader) {
                  return _SectionHeader(label: item.label!, isDark: isDark);
                }
                final n = item.notification!;
                return ActivityCard(
                  notification: n,
                  onTap: () {
                    if (!n.isRead) provider.markAsRead(n.id);
                  },
                  onDelete: () => provider.deleteNotification(n.id),
                );
              },
            ),
          );
        }

        return body;
      },
    );

    // ── AppBar actions ────────────────────────────────────────────────────

    Widget menuAction() {
      return Consumer<NotificationsProvider>(
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
            } else if (value == 'clear_read') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Read Notifications'),
                  content: const Text(
                      'Remove all read notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Clear Read',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                provider.clearReadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Read notifications cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } else if (value == 'clear_unread') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Unread Notifications'),
                  content: const Text(
                      'Remove all unread notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Clear Unread',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                provider.clearUnreadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unread notifications cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
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
            PopupMenuItem(
              value: 'clear_read',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Clear Read'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_unread',
              child: Row(
                children: [
                  Icon(Icons.mark_email_unread_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Clear Unread'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Desktop layout ────────────────────────────────────────────────────

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

    // ── Mobile layout ─────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkScaffold : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          menuAction(),
        ],
      ),
      body: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper data class for the flat ListView
// ─────────────────────────────────────────────────────────────────────────────

class _ListItem {
  final bool isHeader;
  final String? label;
  final NotificationModel? notification;

  const _ListItem._({required this.isHeader, this.label, this.notification});

  factory _ListItem.header(String label) =>
      _ListItem._(isHeader: true, label: label);

  factory _ListItem.notification(NotificationModel n) =>
      _ListItem._(isHeader: false, notification: n);
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header widget ("Today", "Last 7 days", …)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error and empty state widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorBody(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF94A3B8),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final bool isDark;

  const _EmptyBody({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 56,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF94A3B8),
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
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
