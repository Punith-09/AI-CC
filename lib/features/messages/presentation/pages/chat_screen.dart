import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/chat_model.dart';
import '../providers/messages_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/profile_header.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel? chat;

  const ChatScreen({super.key, this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  ChatModel? _chat;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
    _currentUserId = LocalStorage.instance.getUserId();
    if (_chat != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Ensure we have a valid currentUserId before loading messages
        if (_currentUserId == null || _currentUserId!.isEmpty) {
          try {
            final dioClient = GetIt.instance<DioClient>();
            final meRes = await dioClient.get(ApiEndpoints.profileMe);
            if (meRes.data is Map) {
              final meData = meRes.data['data'] ?? meRes.data['user'] ?? meRes.data;
              if (meData is Map) {
                final meId = meData['_id']?.toString() ??
                    meData['id']?.toString() ??
                    meData['userId']?.toString() ??
                    '';
                if (meId.isNotEmpty) {
                  await LocalStorage.instance.saveUserId(meId);
                  if (mounted) setState(() => _currentUserId = meId);
                }
              }
            }
          } catch (_) {}
        }
        if (mounted) {
          if (_chat!.id.isNotEmpty) {
            context.read<MessagesProvider>().markChatAsRead(_chat!.id);
            _loadMessages();
          } else if (_chat!.participantId.isNotEmpty) {
            final newChat =
                await context.read<MessagesProvider>().startChat(_chat!.participantId);
            if (newChat != null && mounted) {
              setState(() => _chat = newChat);
              _loadMessages();
            }
          }
        }
      });

      // Poll messages every 3 seconds while in chat
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted && _chat != null && _chat!.id.isNotEmpty) {
          context.read<MessagesProvider>().fetchMessages(_chat!.id, silent: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_chat == null) return;
    final provider = context.read<MessagesProvider>();
    await provider.fetchMessages(_chat!.id);
    _scrollToBottom();

    // Check if participant name is empty or needs resolution
    if (_chat != null &&
        (_chat!.participantName.isEmpty || _chat!.participantAvatar.isEmpty)) {
      String resolvedUserId = _chat!.participantId;
      if (resolvedUserId.isEmpty) {
        final msgs = provider.messagesForChat(_chat!.id);
        for (final m in msgs) {
          if (m.senderId.isNotEmpty && m.senderId != _currentUserId) {
            resolvedUserId = m.senderId;
            break;
          }
        }
      }

      if (resolvedUserId.isEmpty) {
        try {
          final dioClient = GetIt.instance<DioClient>();
          final chatsRes = await dioClient.get(ApiEndpoints.chats);
          final dynamic rawData = chatsRes.data;
          List<dynamic>? list;
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map) {
            final inner = rawData['data'] ?? rawData['chats'];
            if (inner is List) list = inner;
          }
          if (list != null) {
            for (final c in list) {
              if (c is Map && (c['id'] == _chat!.id || c['_id'] == _chat!.id)) {
                final cId = (c['creatorId'] ??
                        c['creator_id'] ??
                        c['participantId'])
                    ?.toString() ??
                    '';
                final cName = (c['creatorName'] ??
                        c['creator_name'] ??
                        c['name'] ??
                        c['fullName'])
                    ?.toString() ??
                    '';
                final cPic = (c['creatorPic'] ??
                        c['creator_pic'] ??
                        c['profilePhoto'] ??
                        c['avatar'])
                    ?.toString() ??
                    '';
                if (cId.isNotEmpty) resolvedUserId = cId;
                if (cName.isNotEmpty || cPic.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      _chat = _chat?.copyWith(
                        participantId: cId.isNotEmpty ? cId : null,
                        participantName: cName.isNotEmpty ? cName : null,
                        participantAvatar: cPic.isNotEmpty ? cPic : null,
                      );
                    });
                  }
                  break;
                }
              }
            }
          }
        } catch (_) {}
      }

      if (resolvedUserId.isNotEmpty &&
          (_chat?.participantName.isEmpty == true ||
              _chat?.participantAvatar.isEmpty == true)) {
        try {
          final dioClient = GetIt.instance<DioClient>();
          final res =
              await dioClient.get(ApiEndpoints.userProfile(resolvedUserId));
          final data = res.data;
          Map<String, dynamic> p = {};
          if (data is Map<String, dynamic>) {
            if (data['data'] is Map<String, dynamic>) {
              final d = data['data'] as Map<String, dynamic>;
              p = d['user'] is Map<String, dynamic>
                  ? d['user'] as Map<String, dynamic>
                  : (d['talent'] is Map<String, dynamic>
                      ? d['talent'] as Map<String, dynamic>
                      : d);
            } else if (data['user'] is Map<String, dynamic>) {
              p = data['user'] as Map<String, dynamic>;
            } else if (data['talent'] is Map<String, dynamic>) {
              p = data['talent'] as Map<String, dynamic>;
            } else {
              p = data;
            }
          }
          final name = p['fullName']?.toString() ??
              p['name']?.toString() ??
              p['username']?.toString() ??
              p['displayName'] ??
              '';
          final avatar = p['profilePhoto']?.toString() ??
              p['profileImage']?.toString() ??
              p['profile_photo']?.toString() ??
              p['avatar']?.toString() ??
              p['pic'] ??
              p['photo'] ??
              '';
          final rawRole =
              p['role'] ?? p['roles'] ?? p['category'] ?? p['type'];
          final role = (rawRole is List && rawRole.isNotEmpty)
              ? rawRole.first.toString()
              : (rawRole?.toString() ?? '');

          if (mounted &&
              (name.isNotEmpty || avatar.isNotEmpty || role.isNotEmpty)) {
            setState(() {
              _chat = _chat?.copyWith(
                participantId: resolvedUserId,
                participantName: name.isNotEmpty ? name : null,
                participantAvatar: avatar.isNotEmpty ? avatar : null,
                participantRole: role.isNotEmpty ? role : null,
              );
            });
          }
        } catch (_) {}
      }
    }
  }

  void _scrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chat == null) return;
    _controller.clear();
    final provider = context.read<MessagesProvider>();
    await provider.sendMessage(_chat!.id, text);
    _scrollToBottom(animated: true);
  }

  Widget _avatarFallback(String name, {bool isDark = false}) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    final bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    return Container(
      color: bg,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // Instagram / Facebook Messenger styling colors
    final bg = isDark ? Colors.black : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary =
        isDark ? const Color(0xFFA8A8A8) : const Color(0xFF65676B);
    final dividerColor =
        isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    final desktopScaffoldBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);

    // Instagram / Messenger Style AppBar
    final appBar = AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.messages);
          }
        },
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: textPrimary,
          size: 20,
        ),
      ),
      title: GestureDetector(
        onTap: () {
          if (chat?.participantId.isNotEmpty == true) {
            context.push(AppRoutes.exploreProfile, extra: chat!.participantId);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // Circular Avatar with online dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  child: chat?.participantAvatar.isNotEmpty == true
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ApiEndpoints.formatMediaUrl(
                                chat!.participantAvatar),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) => _avatarFallback(
                              chat.participantName,
                              isDark: isDark,
                            ),
                          ),
                        )
                      : _avatarFallback(
                          chat?.participantName ?? '',
                          isDark: isDark,
                        ),
                ),
                if (chat?.isOnline == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF31A24C),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bg,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chat?.participantName.isNotEmpty == true
                        ? chat!.participantName
                        : 'Chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     if (chat?.isOnline == true) ...[
                  //       Container(
                  //         width: 6,
                  //         height: 6,
                  //         margin: const EdgeInsets.only(right: 4),
                  //         decoration: const BoxDecoration(
                  //           color: Color(0xFF31A24C),
                  //           shape: BoxShape.circle,
                  //         ),
                  //       ),
                  //       const Text(
                  //         'Active now',
                  //         style: TextStyle(
                  //           color: Color(0xFF31A24C),
                  //           fontSize: 11.5,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ] else ...[
                  //       Text(
                  //         chat?.participantRole.isNotEmpty == true
                  //             ? chat!.participantRole
                  //             : 'Active recently',
                  //         style: TextStyle(
                  //           color: textSecondary,
                  //           fontSize: 11.5,
                  //           fontWeight: FontWeight.w400,
                  //         ),
                  //       ),
                  //     ],
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.call_outlined, color: textPrimary, size: 22),
      //   ),
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.videocam_outlined, color: textPrimary, size: 24),
      //   ),
      //   IconButton(
      //     onPressed: () {
      //       if (chat?.participantId.isNotEmpty == true) {
      //         context.push(AppRoutes.exploreProfile,
      //             extra: chat!.participantId);
      //       }
      //     },
      //     icon: Icon(Icons.info_outline, color: textPrimary, size: 22),
      //   ),
      //   const SizedBox(width: 4),
      // ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.8),
        child: Container(
          color: dividerColor,
          height: 0.8,
        ),
      ),
    );

    final chatContent = Column(
      children: [
        // Messages list
        Expanded(
          child: chat == null
              ? Center(
                  child: Text(
                    'Open a conversation to start chatting.',
                    style: TextStyle(color: textSecondary),
                  ),
                )
              : Consumer<MessagesProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingMessages &&
                        provider.messagesForChat(chat.id).isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Color(0xFF7000FF),
                          ),
                        ),
                      );
                    }

                    final messages = provider.messagesForChat(chat.id);

                    if (messages.isEmpty) {
                      return ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          ProfileHeader(
                            chat: chat,
                            onViewProfile: () {
                              if (chat.participantId.isNotEmpty) {
                                context.push(AppRoutes.exploreProfile,
                                    extra: chat.participantId);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'No messages yet.\nSay hello to start the conversation! 👋',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      itemCount: messages.length + 1,
                      itemBuilder: (context, index) {
                        // Top item is Instagram-style profile card
                        if (index == 0) {
                          return ProfileHeader(
                            chat: chat,
                            onViewProfile: () {
                              if (chat.participantId.isNotEmpty) {
                                context.push(AppRoutes.exploreProfile,
                                    extra: chat.participantId);
                              }
                            },
                          );
                        }

                        final msgIndex = index - 1;
                        final msg = messages[msgIndex];
                        final isMe = msg.isMe ||
                            (_currentUserId != null &&
                                _currentUserId!.isNotEmpty &&
                                msg.senderId == _currentUserId);

                        // Date separator
                        Widget? separator;
                        final curDay = _dayOf(msg.createdAt);
                        if (msgIndex == 0) {
                          separator =
                              _DateChip(label: _dateLabel(msg.createdAt));
                        } else {
                          final prevDay =
                              _dayOf(messages[msgIndex - 1].createdAt);
                          if (prevDay != curDay) {
                            separator =
                                _DateChip(label: _dateLabel(msg.createdAt));
                          }
                        }

                        return Column(
                          children: [
                            ?separator,
                            MessageBubble(
                              isSender: isMe,
                              message: msg.content,
                              time: _formatTime(msg.createdAt),
                              participantAvatar: chat.participantAvatar,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),

        // Instagram Style Chat input
        Consumer<MessagesProvider>(
          builder: (context, provider, _) => ChatInput(
            controller: _controller,
            onSend: _sendMessage,
            isSending: provider.isSending,
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: desktopScaffoldBg,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: dividerColor,
                    width: 0.8,
                  ),
                ),
              ),
              child: Scaffold(
                backgroundColor: bg,
                appBar: appBar,
                body: SafeArea(child: chatContent),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      body: SafeArea(
        child: chatContent,
      ),
    );
  }

  DateTime _parseDate(String iso) {
    if (iso.trim().isEmpty) return DateTime.now();
    final clean = iso.trim();

    final numVal = int.tryParse(clean);
    if (numVal != null) {
      if (numVal > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal, isUtc: true).toLocal();
      } else if (numVal > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal * 1000, isUtc: true).toLocal();
      }
    }

    try {
      if (clean.endsWith('Z') || clean.endsWith('z') || clean.contains('+')) {
        return DateTime.parse(clean).toLocal();
      }
      if (clean.contains('T') && clean.substring(clean.indexOf('T')).contains('-')) {
        return DateTime.parse(clean).toLocal();
      }
      if (clean.contains('T')) {
        return DateTime.parse('${clean}Z').toLocal();
      }
      final parsed = DateTime.tryParse(clean);
      if (parsed != null) return parsed.isUtc ? parsed.toLocal() : parsed;
    } catch (_) {}

    return DateTime.tryParse(clean)?.toLocal() ?? DateTime.now();
  }

  String _formatTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = _parseDate(iso);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _dayOf(String iso) {
    try {
      final dt = _parseDate(iso);
      return '${dt.year}-${dt.month}-${dt.day}';
    } catch (_) {
      return iso;
    }
  }

  String _dateLabel(String iso) {
    try {
      final dt = _parseDate(iso);
      final now = DateTime.now();
      final timeStr = DateFormat('h:mm a').format(dt).toUpperCase();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'TODAY $timeStr';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'YESTERDAY $timeStr';
      }
      return DateFormat('MMM d, y, h:mm a').format(dt).toUpperCase();
    } catch (_) {
      return '';
    }
  }
}

// ─── Instagram / Messenger Date Separator ─────────────────────────────────────

class _DateChip extends StatelessWidget {
  final String label;
  const _DateChip({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFFA8A8A8) : const Color(0xFF8E8E8E),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
