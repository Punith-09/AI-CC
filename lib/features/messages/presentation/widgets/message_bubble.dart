import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';

class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Instagram / Messenger colors
    final receiverBubbleBg =
        isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    final receiverTextColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF000000);
    final receiverTimeColor =
        isDark ? const Color(0xFFA8A8A8) : const Color(0xFF8E8E8E);
    final avatarBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final avatarIconColor =
        isDark ? const Color(0xFFA8A8A8) : const Color(0xFF64748B);

    return Align(
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: widget.isSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Receiver avatar
            if (!widget.isSender) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: avatarBg,
                child: widget.participantAvatar.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: ApiEndpoints.formatMediaUrl(
                              widget.participantAvatar),
                          width: 28,
                          height: 28,
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
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        // gradient: widget.isSender
                        //     ? const LinearGradient(
                        //         colors: [
                        //           Color(0xFF7000FF),
                        //           Color(0xFFD9008F),
                        //
                        //         ],
                        //         begin: Alignment.bottomLeft,
                        //         end: Alignment.topRight,
                        //       )
                        //     : null,
                        color: widget.isSender
                            ? AppColors.primary
                            : receiverBubbleBg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft:
                              Radius.circular(widget.isSender ? 20 : 5),
                          bottomRight:
                              Radius.circular(widget.isSender ? 5 : 20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: widget.isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.isSender
                                  ? Colors.white
                                  : receiverTextColor,
                              fontSize: 15,
                              height: 1.35,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.time,
                                style: TextStyle(
                                  color: widget.isSender
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : receiverTimeColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (widget.isSender) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.done_all,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Instagram Double-tap Heart Reaction Badge
                    if (_isLiked)
                      Positioned(
                        bottom: -7,
                        right: widget.isSender ? 8 : null,
                        left: widget.isSender ? null : 8,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Text(
                              '❤️',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
