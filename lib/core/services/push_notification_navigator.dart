import 'package:flutter/foundation.dart';

import '../../features/messages/data/models/chat_model.dart';
import '../../features/messages/data/repository/messages_repository.dart';
import '../di/injection_container.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage.dart';
import 'push_notification_payload.dart';

/// Maps a push payload onto existing [GoRouter] routes.
///
/// Navigation is deferred until [appRouter] has a navigator and the user is
/// logged in. Missing IDs fall back to the Activity screen instead of guessing.
class PushNotificationNavigator {
  PushNotificationNavigator._();

  static PushNotificationPayload? _pending;
  static bool _routerReady = false;
  static bool _navigating = false;

  static void markRouterReady() {
    _routerReady = true;
    final pending = _pending;
    if (pending != null) {
      _pending = null;
      open(pending);
    }
  }

  static Future<void> open(PushNotificationPayload payload) async {
    if (!_routerReady || rootNavigatorKey.currentContext == null) {
      _pending = payload;
      return;
    }

    if (!LocalStorage.instance.hasToken()) {
      _pending = payload;
      return;
    }

    if (_navigating) {
      _pending = payload;
      return;
    }

    _navigating = true;
    try {
      await _openInternal(payload);
    } catch (e) {
      debugPrint('Push navigation failed: $e');
      _goActivity();
    } finally {
      _navigating = false;
      final queued = _pending;
      if (queued != null && queued.dedupeKey != payload.dedupeKey) {
        _pending = null;
        open(queued);
      }
    }
  }

  static Future<void> _openInternal(PushNotificationPayload payload) async {
    final type = payload.type.toUpperCase();
    final entityType = (payload.entityType ?? '').toUpperCase();
    final entityId = payload.entityId ?? '';
    final actorId = payload.actorId ?? '';
    final chatId = payload.chatId ?? '';

    // ── Chat / Messages ─────────────────────────────────────────────────────
    if (type == 'MESSAGE' || type == 'NEW_MESSAGE' ||
        entityType == 'CHAT' || chatId.isNotEmpty) {
      final opened = await _openChat(
        chatId: chatId.isNotEmpty
            ? chatId
            : (entityType == 'CHAT' ? entityId : ''),
        participantId: actorId,
      );
      if (!opened) _goActivity();
      return;
    }

    // ── Follow / New Follower ────────────────────────────────────────────────
    if (type == 'FOLLOW' || type == 'NEW_FOLLOWER' || type == 'SOCIAL') {
      // For NEW_FOLLOWER, actorId is the follower's userId
      final profileId = actorId.isNotEmpty ? actorId : entityId;
      if (profileId.isNotEmpty) {
        appRouter.push(AppRoutes.exploreProfile, extra: profileId);
      } else {
        _goActivity();
      }
      return;
    }

    // ── Video / Photo posts ──────────────────────────────────────────────────
    if (type == 'POST_LIKED' ||
        type == 'POST_COMMENTED' ||
        type == 'POST_SHARED' ||
        type == 'COMMENT_LIKED' ||
        entityType == 'VIDEO' ||
        entityType == 'PHOTO' ||
        entityType == 'POST') {
      if (entityId.isNotEmpty) {
        appRouter.push(AppRoutes.watchVideo, extra: entityId);
      } else {
        _goActivity();
      }
      return;
    }

    // ── Stories ─────────────────────────────────────────────────────────────
    if (type == 'STORY_LIKED' ||
        type == 'STORY_REPLIED' ||
        entityType == 'STORY') {
      if (entityId.isNotEmpty) {
        appRouter.push(AppRoutes.storyViewer, extra: entityId);
      } else {
        _goActivity();
      }
      return;
    }

    // ── Application statuses ─────────────────────────────────────────────────
    if (type == 'APPLICATION_SHORTLISTED' ||
        type == 'APPLICATION_ACCEPTED' ||
        type == 'APPLICATION_REJECTED' ||
        type == 'APPLICATION_STATUS_UPDATED' ||
        entityType == 'APPLICATION') {
      // Navigate to my applications list; pass applicationId as extra
      appRouter.push(AppRoutes.appliedAuditions, extra: entityId.isNotEmpty ? entityId : null);
      return;
    }

    // ── Auditions ────────────────────────────────────────────────────────────
    if (type == 'AUDITION' ||
        type == 'AUDITION_APPLIED' ||
        type == 'AUDITION_SHORTLISTED' ||
        type == 'AUDITION_CANCELLED' ||
        type == 'AUDITION_UPDATED' ||
        entityType == 'AUDITION') {
      if (entityId.isNotEmpty &&
          type != 'AUDITION_CANCELLED' &&
          type != 'AUDITION_UPDATED') {
        appRouter.push(AppRoutes.auditionDetails, extra: entityId);
      } else {
        appRouter.go(AppRoutes.auditions);
      }
      return;
    }

    // ── Fallback ─────────────────────────────────────────────────────────────
    _goActivity();
  }

  static Future<bool> _openChat({
    required String chatId,
    required String participantId,
  }) async {
    if (chatId.isNotEmpty) {
      appRouter.push(
        AppRoutes.chat,
        extra: ChatModel(id: chatId, participantId: participantId),
      );
      return true;
    }

    if (participantId.isEmpty || !sl.isRegistered<MessagesRepository>()) {
      return false;
    }

    try {
      final chat = await sl<MessagesRepository>().startChat(participantId);
      appRouter.push(AppRoutes.chat, extra: chat);
      return true;
    } catch (e) {
      debugPrint('Push chat open failed: $e');
      return false;
    }
  }

  static void _goActivity() {
    appRouter.go(AppRoutes.activity);
  }
}
