import 'package:aicc/core/api/api_endpoints.dart';
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
    final cleanCover = coverImage != null
        ? ApiEndpoints.formatMediaUrl(coverImage!)
        : '';
    final isNetwork =
        cleanCover.startsWith('http://') || cleanCover.startsWith('https://');
    final isAsset = cleanCover.startsWith('assets/');

    return SizedBox(
      height: 300,

      child: Stack(
        children: [
          // Bottom fade into app background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xff1c5362).withOpacity(.15),
                    Color(0xff1c5362).withOpacity(.25),
                    Color(0xff143c49).withOpacity(.55),
                    Color(0xff11343e),
                  ],
                  stops: const [0.0, 0.35, 0.55, 0.72, 0.88, 1.0],
                ),
              ),
            ),
          ),

          // Side vignette (makes edges blend nicely)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.background.withOpacity(.45),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background.withOpacity(.25),
                  ],
                ),
              ),
            ),
          ),
          // Top buttons
          Positioned(
            top: 18,
            left: 16,
            child: _CircleButton(
              icon: LucideIcons.chevronLeft,
              onTap: () => context.pop(),
            ),
          ),

          Positioned(
            top: 18,
            right: 16,
            child: Builder(
              builder: (context) {
                return _CircleButton(
                  icon: LucideIcons.ellipsisVertical,
                  onTap: () async {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;

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

                    switch (value) {
                      case 'edit':
                        context.push(AppRoutes.editArtistProfile);
                        break;

                      case 'logout':
                        // Clear token first, THEN navigate.
                        // Without this the router redirect sees a valid
                        // token and immediately bounces back to /home.
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          context.go(AppRoutes.welcome);
                        }
                        break;
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(.35),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withOpacity(.08)),
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }
}
