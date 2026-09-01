import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MessagesProvider>().markChatAsRead(_chat!.id);
        _loadMessages();
      });

      // Poll messages every 3 seconds while in chat
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted && _chat != null) {
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
    if (_chat != null && (_chat!.participantName.isEmpty || _chat!.participantAvatar.isEmpty)) {
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
                final cId = (c['creatorId'] ?? c['creator_id'] ?? c['participantId'])?.toString() ?? '';
                final cName = (c['creatorName'] ?? c['creator_name'] ?? c['name'] ?? c['fullName'])?.toString() ?? '';
                final cPic = (c['creatorPic'] ?? c['creator_pic'] ?? c['profilePhoto'] ?? c['avatar'])?.toString() ?? '';
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

      if (resolvedUserId.isNotEmpty && (_chat?.participantName.isEmpty == true || _chat?.participantAvatar.isEmpty == true)) {
        try {
          final dioClient = GetIt.instance<DioClient>();
          final res = await dioClient.get(ApiEndpoints.userProfile(resolvedUserId));
          final data = res.data;
          Map<String, dynamic> p = {};
          if (data is Map<String, dynamic>) {
            if (data['data'] is Map<String, dynamic>) {
              final d = data['data'] as Map<String, dynamic>;
              p = d['user'] is Map<String, dynamic>
                  ? d['user'] as Map<String, dynamic>
                  : (d['talent'] is Map<String, dynamic> ? d['talent'] as Map<String, dynamic> : d);
            } else if (data['user'] is Map<String, dynamic>) {
              p = data['user'] as Map<String, dynamic>;
            } else if (data['talent'] is Map<String, dynamic>) {
              p = data['talent'] as Map<String, dynamic>;
            } else {
              p = data;
            }
          }
          final name = p['fullName']?.toString() ?? p['name']?.toString() ?? p['username']?.toString() ?? p['displayName'] ?? '';
          final avatar = p['profilePhoto']?.toString() ?? p['profileImage']?.toString() ?? p['profile_photo']?.toString() ?? p['avatar']?.toString() ?? p['pic'] ?? p['photo'] ?? '';
          final rawRole = p['role'] ?? p['roles'] ?? p['category'] ?? p['type'];
          final role = (rawRole is List && rawRole.isNotEmpty) ? rawRole.first.toString() : (rawRole?.toString() ?? '');

          if (mounted && (name.isNotEmpty || avatar.isNotEmpty || role.isNotEmpty)) {
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



  @override
  Widget build(BuildContext context) {
    final chat = _chat;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5A6A),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          chat?.participantName.isNotEmpty == true
              ? chat!.participantName
              : 'Chat',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.photo_camera_outlined, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),

      body: Container(
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
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile header (original widget, now dynamic)
              ProfileHeader(
                chat: chat,
                onViewProfile: () {
                  if (chat?.participantId.isNotEmpty == true) {
                    context.push(AppRoutes.exploreProfile, extra: chat!.participantId);
                  }
                },
              ),

              const Divider(color: Colors.white10, height: 1),

              // Messages list
              Expanded(
                child: chat == null
                    ? const Center(
                        child: Text(
                          'Open a conversation to start chatting.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : Consumer<MessagesProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoadingMessages &&
                              provider.messagesForChat(chat.id).isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white54),
                              ),
                            );
                          }

                          final messages = provider.messagesForChat(chat.id);

                          if (messages.isEmpty) {
                            return const Center(
                              child: Text(
                                'No messages yet.\nSay hello! 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white38, fontSize: 15),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            reverse: false,
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final isMe = msg.isMe ||
                                  (_currentUserId != null &&
                                      _currentUserId!.isNotEmpty &&
                                      msg.senderId == _currentUserId);

                              // Date separator
                              Widget? separator;
                              final curDay = _dayOf(msg.createdAt);
                              if (index == 0) {
                                separator = _DateChip(label: _dateLabel(msg.createdAt));
                              } else {
                                final prevDay = _dayOf(messages[index - 1].createdAt);
                                if (prevDay != curDay) {
                                  separator = _DateChip(label: _dateLabel(msg.createdAt));
                                }
                              }

                              return Column(
                                children: [
                                  ?separator,
                                  if (separator != null) const SizedBox(height: 8),
                                  MessageBubble(
                                    isSender: isMe,
                                    message: msg.content,
                                    time: _formatTime(msg.createdAt),
                                    participantAvatar: chat.participantAvatar,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            },
                          );
                        },
                      ),
              ),

              // Chat input (original widget, now with real send callback)
              Consumer<MessagesProvider>(
                builder: (context, provider, _) => ChatInput(
                  controller: _controller,
                  onSend: _sendMessage,
                  isSending: provider.isSending,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _parseDate(String iso) {
    if (iso.isEmpty) return DateTime.now();
    try {
      String cleaned = iso.trim();
      if (cleaned.endsWith('Z') || cleaned.endsWith('z')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }
      if (cleaned.contains('+')) {
        cleaned = cleaned.split('+').first;
      }
      return DateTime.parse(cleaned);
    } catch (_) {
      return DateTime.tryParse(iso) ?? DateTime.now();
    }
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
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'TODAY';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'YESTERDAY';
      }
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return '';
    }
  }
}

// ─── Date separator chip (matches original "TODAY" chip style) ───────────────

class _DateChip extends StatelessWidget {
  final String label;
  const _DateChip({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Chip(
        backgroundColor: const Color(0xFF0B1F2A),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }
}
