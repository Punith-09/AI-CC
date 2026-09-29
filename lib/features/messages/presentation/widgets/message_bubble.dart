import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final bool isSender;
  final String message;
  final String time;
  final String participantAvatar;

  const MessageBubble({
    super.key,
    required this.isSender,
    required this.message,
    required this.time,
    this.participantAvatar = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Receiver bubble colors
    final receiverBubbleBg = isDark ? AppColors.darkCard : const Color(0xFFF1F5F9);
    final receiverBubbleBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final receiverTextColor = isDark ? AppColors.darkText : const Color(0xFF111827);
    final receiverTimeColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final avatarBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final avatarIconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: avatarBg,
              child: participantAvatar.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: ApiEndpoints.formatMediaUrl(participantAvatar),
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => Icon(
                          Icons.person,
                          size: 15,
                          color: avatarIconColor,
                        ),
                      ),
                    )
                  : Icon(Icons.person, size: 15, color: avatarIconColor),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSender ? AppColors.buttonPrimary : receiverBubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isSender ? 18 : 4),
                  bottomRight: Radius.circular(isSender ? 4 : 18),
                ),
                border: Border.all(
                  color: isSender ? AppColors.buttonPrimary : receiverBubbleBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isSender ? Colors.white : receiverTextColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isSender
                              ? Colors.white.withValues(alpha: 0.8)
                              : receiverTimeColor,
                          fontSize: 11,
                        ),
                      ),
                      if (isSender) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
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
