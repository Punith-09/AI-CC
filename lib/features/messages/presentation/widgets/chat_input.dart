import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.controller,
    this.onSend,
    this.isSending = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1F5A6A),
              Color(0xFF123B4A),
              Color(0xFF0B1F2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Quick Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _QuickActionChip(icon: Icons.folder_open, title: "Portfolio"),
                  SizedBox(width: 10),
                  _QuickActionChip(icon: Icons.calendar_today, title: "Schedule"),
                  SizedBox(width: 10),
                  _QuickActionChip(icon: Icons.person_outline, title: "Profile"),
                  SizedBox(width: 10),
                  _QuickActionChip(icon: Icons.video_camera_back_outlined, title: "Audition"),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.white70),
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF123B4A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.onSend?.call(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: widget.isSending ? null : widget.onSend,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF123B4A), Color(0xFF0B1F2A)],
                      ),
                    ),
                    child: widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 6),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_none, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickActionChip({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF123B4A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurpleAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
