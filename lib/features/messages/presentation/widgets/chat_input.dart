import 'package:aicc/core/constants/app_colors.dart';
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
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _isComposing = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _isComposing) {
      setState(() {
        _isComposing = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Instagram / Messenger colors
    final barBg = isDark ? Colors.black : Colors.white;
    final pillBg = isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    final borderTop =
        isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final hintColor =
        isDark ? const Color(0xFFA8A8A8) : const Color(0xFF8E8E8E);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: BoxDecoration(
          color: barBg,
          border: Border(
            top: BorderSide(color: borderTop, width: 0.8),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: barBg,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (!widget.isSending) {
                      widget.onSend?.call();
                    }
                  },
                  cursorColor:
                      isDark ? AppColors.white : AppColors.black,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: "Message...",
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send Icon Button
              GestureDetector(
                onTap: widget.isSending ? null : widget.onSend,
                behavior: HitTestBehavior.opaque,
                child: AnimatedOpacity(
                  opacity: _isComposing ? 1.0 : 0.65,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration:  BoxDecoration(
                      color: Color(0xFFDC8B20),
                      shape: BoxShape.circle,
                      // gradient: LinearGradient(
                      //   colors: [
                      //     Color(0xFF7000FF),
                      //     Color(0xFFD9008F),
                      //   ],
                      //   begin: Alignment.bottomLeft,
                      //   end: Alignment.topRight,
                      // )

                    ),
                    child: widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
