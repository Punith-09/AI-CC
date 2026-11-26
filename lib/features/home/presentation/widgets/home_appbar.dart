import "package:aicc/core/routes/app_routes.dart";
import "package:aicc/core/utils/scaffold_key.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../core/constants/app_colors.dart";
import "../../../messages/presentation/providers/messages_provider.dart";
import "../../../notifications/presentation/providers/notifications_provider.dart";

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.white : AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => mainScaffoldKey.currentState?.openDrawer(),
                icon: Icon(
                  LucideIcons.menu,
                  color: iconColor,
                  size: 26,
                ),
              ),
              Image.asset(
                'assets/images/treekologo.png',
                width: 47,
                height: 38,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/images/TreeKo.png',
                width: 104,
                height: 34,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Row(
            children: [
              // ─── Notification Bell with badge ───
              Consumer<NotificationsProvider>(
                builder: (ctx, notifProvider, _) {
                  final unreadNotif = notifProvider.unreadNotifications.length;
                  final currentIconColor =
                      Theme.of(ctx).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.black;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push(AppRoutes.activity);
                        },
                        icon: Icon(
                          LucideIcons.bell,
                          size: 26,
                          color: currentIconColor,
                        ),
                      ),
                      if (unreadNotif > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                unreadNotif > 9 ? '9+' : '$unreadNotif',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // ─── Messages icon with badge ───
              Consumer<MessagesProvider>(
                builder: (ctx, provider, _) {
                  final unread = provider.totalUnreadCount;
                  final currentIconColor =
                      Theme.of(ctx).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.black;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push(AppRoutes.messages);
                        },
                        icon: Icon(
                          LucideIcons.messageCircleMore,
                          size: 26,
                          color: currentIconColor,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
