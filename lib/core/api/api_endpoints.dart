class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    // return 'http://localhost:3000';
    // return 'http://10.0.2.2:3000';
    return 'http://54.79.238.124';
    // return 'https://casting-be-1.onrender.com/';
    // return 'https://enrolled-plastic-sub-minerals.trycloudflare.com';
  }

  // ── OTP auth endpoints ──────────────────────────────────────
  static const String otpSend       = '/auth/otp/send';
  static const String otpResend     = '/auth/otp/resend';
  static const String otpVerify     = '/auth/otp/verify';
  static const String otpSignup     = '/auth/otp/signup';
  static const String otpLinkSend   = '/auth/otp/link/send';
  static const String otpLinkVerify = '/auth/otp/link/verify';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String deleteAccount = '/auth/account';
  static const String exploreUsers = '/users/explore';
  static const String profileMe = '/profile/me';
  static const String profileCompletion = '/profile/me/completion';

  static String userProfile(String id) => '/users/$id';
  static String followUser(String id) => '/users/$id/follow';
  static const String auditions = "/auditions";
  static const String myPostedAuditions = "/auditions/my-posted";
  static String auditionDetail(String id) => "/auditions/$id";
  static String deleteAudition(String id) => "/auditions/$id";
  static String applyAudition(String id) => "/auditions/$id/apply";

  static const String myApplications = "/applications/me";
  static String withdrawApplication(String id) => "/applications/$id";
  static String updateApplicationStatus(String id) => "/applications/$id/status";

  static const String mediaUpload = "/media/upload";
  static const String photos = "/photos";
  static const String videos = "/videos";
  static const String uploadVideo = "/videos/upload";

  static String likeVideo(String id) => "/videos/$id/like";
  static String likePhoto(String id) => "/photos/$id/like";
  static String deletePhoto(String id) => "/photos/$id";
  static String deleteVideo(String id) => "/videos/$id";
  static String viewVideo(String id) => "/videos/$id/view";
  static String videoComments(String id) => "/videos/$id/comments";
  static String likeComment(String commentId) => "/videos/comments/$commentId/like";

  // Rewrites any relative URLs or localhost:3000 URLs returned by the backend to the base URL.
  static String formatMediaUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (url.startsWith('http://localhost:3000')) {
        return url.replaceFirst('http://localhost:3000', baseUrl);
      }
      return url;
    }
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }

  /// Optimizes video URLs for fast mobile streaming.
  /// For Cloudinary video streams, injects dynamic mobile-friendly transformations:
  /// - `q_auto`: AI-based dynamic bitrate & compression (reduces size up to 80%)
  /// - `w_720,c_limit`: Caps resolution to 720p for fast buffer and decoder safety
  /// - `f_mp4`: Ensures standard H.264 MP4 container with moov atom at byte 0 (faststart)
  static String optimizeVideoUrl(String url) {
    if (url.isEmpty) return url;
    String formatted = formatMediaUrl(url).trim();

    // Optimize Cloudinary video URLs
    if (formatted.contains('/video/upload/')) {
      final uploadIndex = formatted.indexOf('/video/upload/');
      final afterUpload = formatted.substring(uploadIndex + '/video/upload/'.length);
      // Avoid re-injecting if already transformed
      if (!afterUpload.startsWith('q_') &&
          !afterUpload.startsWith('w_') &&
          !afterUpload.startsWith('f_') &&
          !afterUpload.startsWith('c_')) {
        formatted = formatted.replaceFirst(
          '/video/upload/',
          '/video/upload/q_auto,w_720,c_limit,f_mp4/',
        );
      }
    }

    return formatted;
  }

  /// Optimizes video URLs for fast, high-quality downloading to the device gallery.
  /// For Cloudinary video streams, injects dynamic mobile-friendly transformations:
  /// - `q_auto`: AI-based perceptual compression (~80% file size reduction)
  /// - `w_1080,c_limit`: Caps resolution to 1080p (prevents multi-gigabyte 4K downloads from stalling)
  /// - `f_mp4`: Guarantees universal standard H.264/AAC MP4 container for device galleries
  static String optimizeVideoDownloadUrl(String url) {
    if (url.isEmpty) return url;
    String formatted = formatMediaUrl(url).trim();

    // Optimize Cloudinary video URLs
    if (formatted.contains('/video/upload/')) {
      final uploadIndex = formatted.indexOf('/video/upload/');
      final afterUpload = formatted.substring(uploadIndex + '/video/upload/'.length);
      // Avoid re-injecting if already transformed
      if (!afterUpload.startsWith('q_') &&
          !afterUpload.startsWith('w_') &&
          !afterUpload.startsWith('f_') &&
          !afterUpload.startsWith('c_')) {
        formatted = formatted.replaceFirst(
          '/video/upload/',
          '/video/upload/q_auto,w_1080,c_limit,f_mp4/',
        );
      }
    }

    return formatted;
  }

  static const String chats = "/chats";
  static String startChat(String userId) => "/chats/start/$userId";
  static String chatMessages(String chatId) => "/chats/$chatId/messages";

  static const String paymentPlans = "/payments/plans";
  static const String paymentCheckout = "/payments/checkout";
  static const String paymentVerify = "/payments/verify";
  static const String subscriptionsMe = "/subscriptions/me";

  static const String stories = "/stories";
  static const String storiesFeed = "/stories/feed";
  static String storyView(String id) => "/stories/$id/views";
  static String deleteStory(String id) => "/stories/$id";
  static const String liveStats = "/stats";

  // Notifications
  static const String notifications = "/notifications";
  static const String clearAllNotifications = "/notifications";
  static const String notificationsUnreadCount = "/notifications/unread-count";
  static String markNotificationRead(String id) => "/notifications/$id/read";
  static const String markAllNotificationsRead = "/notifications/read-all";
  static String deleteNotification(String id) => "/notifications/$id";

  // FCM Device Token
  static const String fcmToken = "/notifications/fcm-token";
}
