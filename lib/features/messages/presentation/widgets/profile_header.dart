import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/chat_model.dart';

class ProfileHeader extends StatelessWidget {
  final ChatModel? chat;
  final VoidCallback? onViewProfile;

  const ProfileHeader({super.key, this.chat, this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final avatarBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final nameColor = isDark ? AppColors.darkText : const Color(0xFF111827);
    final roleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    final name = (chat?.participantName.isNotEmpty == true)
        ? chat!.participantName
        : 'Creator';
    final role = (chat?.participantRole.isNotEmpty == true)
        ? chat!.participantRole
        : 'Artist';
    final avatar = chat?.participantAvatar ?? '';
    final isOnline = chat?.isOnline ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: containerBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: avatarBg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: avatar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ApiEndpoints.formatMediaUrl(avatar),
                          fit: BoxFit.cover,
                          errorWidget: (ctx, url, err) => _fallback(name, isDark: isDark),
                        )
                      : _fallback(name, isDark: isDark),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: containerBg,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: nameColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: roleColor, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IntrinsicWidth(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: onViewProfile,
              child: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(String name, {bool isDark = false}) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    final bg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final textColor = isDark ? AppColors.darkText : const Color(0xFF111827);
    return Container(
      color: bg,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
