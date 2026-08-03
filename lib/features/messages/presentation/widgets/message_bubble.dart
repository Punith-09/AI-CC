import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isSender;
  final String message;
  final String time;

  const MessageBubble({
    super.key,
    required this.isSender,
    required this.message,
    required this.time,
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
            const CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
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
                          color: Colors.white.withOpacity(.7),
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
