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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().fetchChats();
    });
  }

  @override
  void dispose() {
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

              const SizedBox(height: 20),

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
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
        if (provider.isLoadingChats) {
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
              return _ChatTile(
                chat: chats[index],
                onTap: () async {
                  await context.push(
                    AppRoutes.chat,
                    extra: chats[index],
                  );
                  if (context.mounted) {
                    context.read<MessagesProvider>().fetchChats();
                  }
                },
              );
            },
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
// CHAT TILE
// ===========================================================

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F5A6A),
                        Color(0xFF276f8a),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: chat.participantAvatar.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ApiEndpoints.formatMediaUrl(chat.participantAvatar),
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) =>
                                _AvatarFallback(name: chat.participantName),
                          ),
                        )
                      : _AvatarFallback(name: chat.participantName),
                ),

                // Online indicator
                if (chat.isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
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

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.participantName.isNotEmpty
                              ? chat.participantName
                              : 'Unknown User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: TextStyle(
                          color: hasUnread
                              ? AppColors.primary
                              : Colors.white38,
                          fontSize: 11,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Last message + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : 'Start a conversation...',
                          style: TextStyle(
                            color: hasUnread
                                ? Colors.white70
                                : Colors.white38,
                            fontSize: 13,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.BtnGradient,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            chat.unreadCount > 99
                                ? '99+'
                                : '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Role badge
                  if (chat.participantRole.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          chat.participantRole,
                          style: const TextStyle(
                            color: AppColors.primary,
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
    try {
      String cleaned = isoString.trim();
      if (cleaned.endsWith('Z') || cleaned.endsWith('z')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }
      if (cleaned.contains('+')) {
        cleaned = cleaned.split('+').first;
      }
      return DateTime.parse(cleaned);
    } catch (_) {
      return DateTime.tryParse(isoString) ?? DateTime.now();
    }
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = _parseDate(isoString);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final hour = dt.hour;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      } else if (diff.inDays == 1 || (dt.day == now.day - 1 && dt.month == now.month && dt.year == now.year)) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}/${dt.month}/${dt.year % 100}';
      }
    } catch (_) {
      return '';
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

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
