import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    final nameColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFFA8A8A8) : const Color(0xFF65676B);
    final btnBg = isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    final btnTextColor = isDark ? Colors.white : const Color(0xFF000000);
    final avatarBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final name = (chat?.participantName.isNotEmpty == true)
        ? chat!.participantName
        : 'Creator';
    final role = (chat?.participantRole.isNotEmpty == true)
        ? chat!.participantRole
        : 'Artist';
    final avatar = chat?.participantAvatar ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instagram Story Ring Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary
              // gradient: LinearGradient(
              //   colors: [
              //     Color(0xFFFBAA47),
              //     Color(0xFFD91A46),
              //     Color(0xFFA60F93),
              //   ],
              //   begin: Alignment.bottomLeft,
              //   end: Alignment.topRight,
              // ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.black : Colors.white,
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: avatarBg,
                child: avatar.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: ApiEndpoints.formatMediaUrl(avatar),
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorWidget: (ctx, url, err) => _fallback(name, isDark: isDark),
                        ),
                      )
                    : _fallback(name, isDark: isDark),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: nameColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 3),

          // Role / Category info
          Text(
            '$role ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          // const SizedBox(height: 3),
          //
          // Text(
          //   "You're connected on AI-CC",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     color: subtitleColor.withValues(alpha: 0.8),
          //     fontSize: 12,
          //   ),
          // ),

          const SizedBox(height: 14),

          // Instagram style "View Profile" button
          if (onViewProfile != null)
            GestureDetector(
              onTap: onViewProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: btnBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View Profile',
                  style: TextStyle(
                    color: btnTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
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
    final bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    return Container(
      color: bg,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
