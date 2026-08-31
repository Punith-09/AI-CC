import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/api/api_endpoints.dart';

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
              backgroundColor: const Color(0xFF123B4A),
              child: participantAvatar.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: ApiEndpoints.formatMediaUrl(participantAvatar),
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => const Icon(
                          Icons.person,
                          size: 15,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : const Icon(Icons.person, size: 15, color: Colors.white54),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSender
                    ? const LinearGradient(
                        colors: [Color(0xFF123B4A), Color(0xFF0B1F2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSender ? null : const Color(0xFF0B1F2A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSender ? 20 : 6),
                  bottomRight: Radius.circular(isSender ? 6 : 20),
                ),
                border: Border.all(color: const Color(0xFF123B4A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                      if (isSender) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 15,
                          color: Color(0xFF123B4A),
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
