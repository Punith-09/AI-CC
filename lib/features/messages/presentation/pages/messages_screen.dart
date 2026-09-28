import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/chat_model.dart';
import '../providers/messages_provider.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _pollingTimer;
  ChatModel? _selectedChat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().fetchChats();
    });

    // Auto-refresh chat list every 5 seconds so new incoming messages float to the top
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<MessagesProvider>().fetchChats(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Column: Conversations List
            SizedBox(
              width: 880,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildAppBar(context, isDesktop: true),
                    const SizedBox(height: 8),
                    _buildSearchBar(),
                    const SizedBox(height: 8),
                    Expanded(child: _buildChatsList(isDesktop: true)),
                  ],
                ),
              ),
            ),

            // Right Column: Active Conversation
            // Expanded(
            //   child: _selectedChat != null
            //       ? ChatScreen(
            //           key: ValueKey(_selectedChat!.id),
            //           chat: _selectedChat,
            //         )
            //       : _buildNoChatSelectedState(),
            // ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context, isDesktop: false),
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildChatsList(isDesktop: false)),
          ],
        ),
      ),
    );
  }

  // Widget _buildNoChatSelectedState() {
  //   return Container(
  //     color: const Color(0xFFF8FAFC),
  //     child: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 72,
  //             height: 72,
  //             decoration: BoxDecoration(
  //               color: AppColors.primary.withValues(alpha: 0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(
  //               LucideIcons.messageSquare,
  //               size: 32,
  //               color: AppColors.primary,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'Select a conversation',
  //             style: TextStyle(
  //               color: Color(0xFF111827),
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 6),
  //           const Text(
  //             'Choose a chat from the left panel to start messaging',
  //             style: TextStyle(
  //               color: Color(0xFF64748B),
  //               fontSize: 13.5,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAppBar(BuildContext context, {required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Back button on mobile
          if (!isDesktop) ...[
            InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF111827),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<MessagesProvider>(
                  builder: (context, provider, child) {
                    final unreadCount = provider.totalUnreadCount;
                    return Row(
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const Text(
                  'Your conversations',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Compose icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.buttonPrimary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.penSquare,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
          style: const TextStyle(color: Color(0xFF111827), fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
            prefixIcon: const Icon(
              LucideIcons.search,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CHATS LIST
  // =========================================================

  Widget _buildChatsList({required bool isDesktop}) {
    return Consumer<MessagesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingChats && provider.chats.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (provider.errorMessage != null && provider.chats.isEmpty) {
          return _buildErrorState(provider);
        }

        final chats = provider.chats.where((chat) {
          if (_searchQuery.isEmpty) return true;
          return chat.participantName.toLowerCase().contains(_searchQuery) ||
              chat.lastMessage.toLowerCase().contains(_searchQuery);
        }).toList();

        if (chats.isEmpty) {
          return _buildEmptyState();
        }

        // On desktop, auto-select first conversation if none selected
        if (isDesktop && _selectedChat == null && chats.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedChat == null) {
              setState(() => _selectedChat = chats.first);
            }
          });
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Colors.white,
          onRefresh: () => provider.fetchChats(),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            itemCount: chats.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isSelected = isDesktop && _selectedChat?.id == chat.id;

              return _ChatTile(
                chat: chat,
                isSelected: isSelected,
                onTap: () async {
                  provider.markChatAsRead(chat.id);
                  if (isDesktop) {
                    setState(() => _selectedChat = chat);
                  } else {
                    await context.push(
                      AppRoutes.chat,
                      extra: chat,
                    );
                    if (context.mounted) {
                      context.read<MessagesProvider>().fetchChats(silent: true);
                    }
                  }
                },
                onLongPress: () => _showChatOptions(context, chat),
              );
            },
          ),
        );
      },
    );
  }

  void _showChatOptions(BuildContext context, ChatModel chat) {
    final provider = context.read<MessagesProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        chat.participantName.isNotEmpty ? chat.participantName : 'Conversation',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    chat.isUnread ? LucideIcons.mailOpen : LucideIcons.mail,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    chat.isUnread ? 'Mark as read' : 'Mark as unread',
                    style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (chat.isUnread) {
                      provider.markChatAsRead(chat.id);
                    } else {
                      provider.markChatAsUnread(chat.id);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.user, color: Color(0xFF64748B)),
                  title: const Text(
                    'View Profile',
                    style: TextStyle(color: Color(0xFF111827), fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (chat.participantId.isNotEmpty) {
                      context.push(AppRoutes.exploreProfile, extra: chat.participantId);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.messageSquare,
              color: Color(0xFF94A3B8),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a conversation with a\ncreator or artist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState(MessagesProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFF94A3B8),
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            provider.errorMessage ?? 'Failed to load chats.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => provider.fetchChats(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// CHAT TILE
// ===========================================================

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ChatTile({
    required this.chat,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chat.isUnread;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isUnread ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnread ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isUnread ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: chat.participantAvatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiEndpoints.formatMediaUrl(chat.participantAvatar),
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) =>
                                _AvatarFallback(name: chat.participantName),
                          )
                        : _AvatarFallback(name: chat.participantName),
                  ),
                ),

                // Online indicator
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Participant Name + Timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.participantName.isNotEmpty
                              ? chat.participantName
                              : 'Creator',
                          style: TextStyle(
                            color: const Color(0xFF111827),
                            fontSize: 14.5,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: TextStyle(
                          color: isUnread
                              ? AppColors.primary
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Row 2: Last Message + Unread Dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : 'Tap to chat...',
                          style: TextStyle(
                            color: isUnread
                                ? const Color(0xFF111827)
                                : const Color(0xFF64748B),
                            fontSize: 12.5,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Role badge (if present)
                  if (chat.participantRole.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chat.participantRole,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String isoString) {
    if (isoString.isEmpty) return DateTime.now();
    final clean = isoString.trim();

    try {
      String iso = clean;
      if (iso.endsWith('Z') || iso.endsWith('z')) {
        iso = iso.substring(0, iso.length - 1);
      }
      if (iso.contains('+')) {
        iso = iso.split('+').first;
      }
      final parsed = DateTime.tryParse(iso) ?? DateTime.tryParse(clean);
      if (parsed != null) return parsed;
    } catch (_) {}

    final numVal = int.tryParse(clean);
    if (numVal != null) {
      if (numVal > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal);
      } else if (numVal > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal * 1000);
      }
    }

    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?').firstMatch(clean);
    if (timeMatch != null) {
      int hour = int.parse(timeMatch.group(1)!);
      final minute = int.parse(timeMatch.group(2)!);
      final period = timeMatch.group(3)?.toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    return DateTime.now();
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = _parseDate(isoString);
      final now = DateTime.now();

      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final hour = dt.hour;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }

      final diff = now.difference(dt);
      if (diff.inDays == 1 || (dt.day == now.day - 1 && dt.month == now.month && dt.year == now.year)) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}/${dt.month}/${dt.year % 100}';
      }
    } catch (_) {
      return isoString;
    }
  }
}

// ===========================================================
// AVATAR FALLBACK
// ===========================================================

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
