class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    // Cloudflare tunnel — points to local backend (http://localhost:3000)
    // Replace this URL each time you restart the cloudflared tunnel.
    return 'https://eden-gym-tracks-larger.trycloudflare.com';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static const String exploreUsers = '/users/explore';
  static const String profileMe = '/profile/me';

  static String userProfile(String id) => '/users/$id';
  static String followUser(String id) => '/users/$id/follow';
  static const String auditions = "/auditions";
  static String auditionDetail(String id) => "/auditions/$id";
  static String applyAudition(String id) => "/auditions/$id/apply";

  static const String myApplications = "/applications/me";
  static String withdrawApplication(String id) => "/applications/$id";
  static String updateApplicationStatus(String id) => "/applications/$id/status";

  static const String photos = "/photos";
  static const String videos = "/videos";
  static const String uploadVideo = "/videos/upload";

  static String likeVideo(String id) => "/videos/$id/like";
  static String likePhoto(String id) => "/photos/$id/like";
  static String viewVideo(String id) => "/videos/$id/view";
  static String videoComments(String id) => "/videos/$id/comments";
  static String likeComment(String commentId) => "/videos/comments/$commentId/like";

  // Rewrites any localhost:3000 URLs returned by the backend to the tunnel URL.
  static String formatMediaUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('/')) return '$baseUrl$url';
    if (url.startsWith('http://localhost:3000')) {
      return url.replaceFirst('http://localhost:3000', baseUrl);
    }
    return url;
  }

  static const String chats = "/chats";
  static String startChat(String userId) => "/chats/start/$userId";
  static String chatMessages(String chatId) => "/chats/$chatId/messages";
}
