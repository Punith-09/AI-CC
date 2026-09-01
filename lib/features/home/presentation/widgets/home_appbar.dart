import "package:aicc/core/routes/app_routes.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../core/constants/app_colors.dart";
import "../../../messages/presentation/providers/messages_provider.dart";
// import "../../messages/presentation/providers/messages_provider.dart";

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 2.0),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.clapperboard,
              size: 26,
              color: AppColors.black,
            ),
          ),
          Row(
            children: [
              Consumer<MessagesProvider>(
                builder: (_, provider, __) {
                  final unread = provider.totalUnreadCount;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push(AppRoutes.messages);
                        },
                        icon: const Icon(
                          LucideIcons.messageCircleMore,
                          size: 26,
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
              const SizedBox(width: 15),
              IconButton(
                onPressed: () {
                  context.push(AppRoutes.activity);
                },
                icon: const Icon(LucideIcons.bell, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}