import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/chat_model.dart';
import '../providers/messages_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _pollingTimer;

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backGroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------
              // APP BAR
              // -----------------------------------------------
              _buildAppBar(context),

              const SizedBox(height: 16),

              // -----------------------------------------------
              // SEARCH BAR
              // -----------------------------------------------
              _buildSearchBar(),

              const SizedBox(height: 16),

              // -----------------------------------------------
              // CHATS LIST
              // -----------------------------------------------
              Expanded(child: _buildChatsList()),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<MessagesProvider>(
                  builder: (_, provider, __) {
                    final unreadCount = provider.totalUnreadCount;
                    return Row(
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                              ),
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
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Compose icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.BtnGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: const Icon(
              LucideIcons.search,
              color: Colors.white38,
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
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CHATS LIST
  // =========================================================

  Widget _buildChatsList() {
    return Consumer<MessagesProvider>(
      builder: (context, provider, _) {
        // Loading
        if (provider.isLoadingChats && provider.chats.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        // Error
        if (provider.errorMessage != null && provider.chats.isEmpty) {
          return _buildErrorState(provider);
        }

        // Filter by search
        final chats = provider.chats.where((chat) {
          if (_searchQuery.isEmpty) return true;
          return chat.participantName.toLowerCase().contains(_searchQuery) ||
              chat.lastMessage.toLowerCase().contains(_searchQuery);
        }).toList();

        // Empty
        if (chats.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.card,
          onRefresh: () => provider.fetchChats(),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: chats.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white.withValues(alpha: 0.06),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatTile(
                chat: chat,
                onTap: () async {
                  // Mark as read immediately on open
                  provider.markChatAsRead(chat.id);
                  await context.push(
                    AppRoutes.chat,
                    extra: chat,
                  );
                  if (context.mounted) {
                    context.read<MessagesProvider>().fetchChats(silent: true);
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
      backgroundColor: const Color(0xFF131F2E),
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
                    color: Colors.white24,
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
                          color: Colors.white,
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
                    color: const Color(0xFF38BDF8),
                  ),
                  title: Text(
                    chat.isUnread ? 'Mark as read' : 'Mark as unread',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                  leading: const Icon(LucideIcons.user, color: Colors.white70),
                  title: const Text(
                    'View Profile',
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.messageSquare,
              color: Colors.white30,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with a\ncreator or artist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
              height: 1.5,
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
            color: Colors.white30,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage ?? 'Failed to load chats.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => provider.fetchChats(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.BtnGradient,
                ),
                borderRadius: BorderRadius.circular(12),
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
// CHAT TILE (Instagram Style Read/Unread)
// ===========================================================

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ChatTile({
    required this.chat,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chat.isUnread;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            // Avatar with Instagram-like unread ring
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: EdgeInsets.all(isUnread ? 2.5 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnread
                        ? const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF8E3CF7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: isUnread
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F1B27),
                    ),
                    padding: const EdgeInsets.all(1.5),
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
                ),

                // Online indicator
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0B1F2A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Content (Name, Last message, Time, Dot)
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
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: TextStyle(
                          color: isUnread
                              ? const Color(0xFF38BDF8)
                              : Colors.white38,
                          fontSize: 11.5,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Row 2: Last Message + Unread Blue Dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : 'Tap to chat...',
                          style: TextStyle(
                            color: isUnread
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 13.5,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Instagram Blue Unread Dot
                      if (isUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x8038BDF8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Role badge (if present)
                  if (chat.participantRole.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          chat.participantRole,
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 10.5,
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
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
