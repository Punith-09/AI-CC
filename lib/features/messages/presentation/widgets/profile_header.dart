import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/chat_model.dart';

class ProfileHeader extends StatelessWidget {
  final ChatModel? chat;
  final VoidCallback? onViewProfile;

  const ProfileHeader({super.key, this.chat, this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    final name = (chat?.participantName.isNotEmpty == true)
        ? chat!.participantName
        : 'Creator';
    final role = (chat?.participantRole.isNotEmpty == true)
        ? chat!.participantRole
        : 'Artist';
    final avatar = chat?.participantAvatar ?? '';
    final isOnline = chat?.isOnline ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F5A6A), Color(0xFF123B4A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: avatar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ApiEndpoints.formatMediaUrl(avatar),
                          fit: BoxFit.cover,
                          errorWidget: (ctx, url, err) => _fallback(name),
                        )
                      : _fallback(name),
                ),
              ),
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.greenAccent : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff1F1F28), width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.greenAccent : Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IntrinsicWidth(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123B4A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: onViewProfile,
              child: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(String name) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      color: const Color(0xFF1F5A6A),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }
}
