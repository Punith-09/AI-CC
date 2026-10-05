import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.darkCard : Colors.white;
    final borderTopColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final inputFieldBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final inputBorder = isDark ? AppColors.primary : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.darkText : const Color(0xFF111827);
    final hintColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);
    final attachIconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final micBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final micBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final micIconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: containerBg,
          border: Border(
            top: BorderSide(color: borderTopColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Quick Actions
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       _QuickActionChip(icon: Icons.folder_open, title: "Portfolio", isDark: isDark),
            //       const SizedBox(width: 8),
            //       _QuickActionChip(icon: Icons.calendar_today, title: "Schedule", isDark: isDark),
            //       const SizedBox(width: 8),
            //       _QuickActionChip(icon: Icons.person_outline, title: "Profile", isDark: isDark),
            //       const SizedBox(width: 8),
            //       _QuickActionChip(icon: Icons.video_camera_back_outlined, title: "Audition", isDark: isDark),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 12),

            Row(
              children: [
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.attach_file, color: attachIconColor),
                // ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputFieldBg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.onSend?.call(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: hintColor),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        // suffixIcon: IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(
                        //     Icons.emoji_emotions_outlined,
                        //     color: hintColor,
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: widget.isSending ? null : widget.onSend,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.buttonPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonPrimary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),

                // const SizedBox(width: 6),

                // Container(
                //   decoration: BoxDecoration(
                //     color: micBg,
                //     borderRadius: BorderRadius.circular(24),
                //     border: Border.all(color: micBorder),
                //   ),
                //   child: IconButton(
                //     onPressed: () {},
                //     icon: Icon(Icons.mic_none, color: micIconColor, size: 20),
                //   ),
                // ),
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
  final bool isDark;

  const _QuickActionChip({required this.icon, required this.title, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final chipBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.darkText : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
