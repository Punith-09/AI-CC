import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverImage;
  const ProfileHeader({super.key, this.coverImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: LucideIcons.chevronLeft,
            onTap: () {
              if (Navigator.canPop(context)) {
                context.pop();
              }
            },
          ),
          Builder(
            builder: (context) {
              return _CircleButton(
                icon: LucideIcons.ellipsisVertical,
                onTap: () async {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                  final position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(
                        button.size.bottomRight(Offset.zero),
                        ancestor: overlay,
                      ),
                    ),
                    Offset.zero & overlay.size,
                  );

                  final value = await showMenu<String>(
                    context: context,
                    position: position,
                    color: const Color(0xFF1E2A38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    items: const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (!context.mounted) return;

                  switch (value) {
                    case 'edit':
                      context.push(AppRoutes.editArtistProfile);
                      break;

                    case 'logout':
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.welcome);
                      }
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withOpacity(.08),
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}
