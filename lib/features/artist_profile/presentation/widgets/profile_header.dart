import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverImage;
  final bool isOtherUser;

  const ProfileHeader({
    super.key,
    this.coverImage,
    this.isOtherUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isOtherUser)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: .35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: .08),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    LucideIcons.ellipsisVertical,
                    color: AppColors.white,
                    size: 22,
                  ),
                  color: const Color(0xFF1E2A38),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push(AppRoutes.editArtistProfile);
                    } else if (value == 'logout') {
                      try {
                        final authProvider = context.read<AuthProvider>();
                        final profileProvider = context.read<ProfileProvider>();
                        await authProvider.logout();
                        profileProvider.clear();
                      } catch (e) {
                        debugPrint('Logout error: $e');
                      } finally {
                        if (context.mounted) {
                          context.go(AppRoutes.welcome);
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
