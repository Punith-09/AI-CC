import 'package:dio/dio.dart';

import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ArtistModel> getProfileMe();

  Future<ArtistModel> getUserProfile(String id);

  Future<List<PortfolioModel>> getUserMedia(String userId);

  Future<void> followUser(String id);

  Future<ArtistModel> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  ProfileRemoteDataSourceImpl(
    this._dioClient,
    this._localStorage,
  );

  // ----------------------------------------------------------
  // Authorization headers
  // ----------------------------------------------------------

  Options _getOptions() {
    final token = _localStorage.getToken();

    return Options(
      headers: token != null && token.isNotEmpty
          ? {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            }
          : {
              'Content-Type': 'application/json',
            },
    );
  }

  // ----------------------------------------------------------
  // Extract profile data from API response
  // ----------------------------------------------------------

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is! Map) {
      throw Exception(
        'Invalid profile response format',
      );
    }

    final Map<String, dynamic> response =
        Map<String, dynamic>.from(responseData);

    final dynamic data = response['data'] ?? response['user'] ?? response['profile'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  // ----------------------------------------------------------
  // Get my profile
  // ----------------------------------------------------------

  @override
  Future<ArtistModel> getProfileMe() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.profileMe,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        var artist = ArtistModel.fromJson(data);
        if (artist.id.isNotEmpty) {
          _localStorage.saveUserId(artist.id);
        }
        if (artist.name.isNotEmpty) {
          _localStorage.saveUserName(artist.name);
        }
        if (artist.profileImage.isNotEmpty) {
          _localStorage.saveUserProfilePhoto(artist.profileImage);
        }

        // If followers is 0 or empty, try discovering from API endpoints
        if (artist.followers == '0' || artist.followers.isEmpty) {
          final resolved = await _fetchFollowersCount(artist.id, userName: artist.name);
          if (resolved != null && resolved != '0') {
            artist = artist.copyWith(followers: resolved);
          }
        }

        return artist;
      }

      throw Exception(
        'Failed to get profile. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to get profile',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // Get another user's profile
  // ----------------------------------------------------------

  @override
  Future<ArtistModel> getUserProfile(String id) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.userProfile(id),
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        var artist = ArtistModel.fromJson(data);

        // If followers is 0 or empty, try discovering from API endpoints
        if (artist.followers == '0' || artist.followers.isEmpty) {
          final resolved = await _fetchFollowersCount(id, userName: artist.name);
          if (resolved != null && resolved != '0') {
            artist = artist.copyWith(followers: resolved);
          }
        }

        return artist;
      }

      throw Exception(
        'Failed to get user profile. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to get user profile',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // Fetch followers helper
  // ----------------------------------------------------------

  Future<String?> _fetchFollowersCount(String userId, {String? userName}) async {
    if (userId.isEmpty) return null;

    // 1. Try /users/$userId/followers
    try {
      final fResp = await _dioClient.get(
        '/users/$userId/followers',
        options: _getOptions(),
      );
      if (fResp.statusCode == 200 && fResp.data != null) {
        final dynamic raw = fResp.data;
        if (raw is List) {
          return raw.length.toString();
        } else if (raw is Map) {
          final list = raw['followers'] ?? raw['data'] ?? raw['users'];
          if (list is List) return list.length.toString();
          final count = raw['count'] ?? raw['total'] ?? raw['followersCount'] ?? raw['followers_count'];
          if (count != null) return count.toString();
        }
      }
    } catch (_) {}

    // 2. Try /users/$userId
    try {
      final uResp = await _dioClient.get(
        ApiEndpoints.userProfile(userId),
        options: _getOptions(),
      );
      if (uResp.statusCode == 200 && uResp.data != null) {
        final uData = _extractData(uResp.data);
        final fVal = ArtistModel.followersValueFromMap(uData);
        if (fVal != '0' && fVal.isNotEmpty) {
          return fVal;
        }
      }
    } catch (_) {}

    // 3. Try /users/explore
    try {
      final exResp = await _dioClient.get(
        ApiEndpoints.exploreUsers,
        options: _getOptions(),
      );
      final dynamic exData = exResp.data;
      List<dynamic> list = [];
      if (exData is List) {
        list = exData;
      } else if (exData is Map && exData['data'] is List) {
        list = exData['data'];
      } else if (exData is Map && exData['users'] is List) {
        list = exData['users'];
      }
      for (final item in list) {
        if (item is Map) {
          final itemId = (item['id'] ?? item['_id'])?.toString();
          final itemName = (item['fullName'] ?? item['name'] ?? item['stageName'])?.toString();
          if ((itemId != null && itemId == userId) ||
              (userName != null && userName.isNotEmpty && itemName != null && itemName.toLowerCase() == userName.toLowerCase())) {
            final fVal = ArtistModel.followersValueFromMap(Map<String, dynamic>.from(item));
            if (fVal != '0' && fVal.isNotEmpty) {
              return fVal;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  // ----------------------------------------------------------
  // Get photos and videos posted by user
  // ----------------------------------------------------------

  @override
  Future<List<PortfolioModel>> getUserMedia(String userId) async {
    final List<PortfolioModel> media = [];

    try {
      final results = await Future.wait([
        _dioClient.get(ApiEndpoints.photos),
        _dioClient.get(ApiEndpoints.videos),
      ]);

      // 1. Photos
      final dynamic photosRaw = results[0].data;
      List<dynamic> photosList = [];
      if (photosRaw is List) {
        photosList = photosRaw;
      } else if (photosRaw is Map && photosRaw['data'] is List) {
        photosList = photosRaw['data'];
      } else if (photosRaw is Map && photosRaw['photos'] is List) {
        photosList = photosRaw['photos'];
      }

      for (final item in photosList) {
        if (item is Map) {
          final cId = item['creatorId']?.toString() ??
              item['userId']?.toString() ??
              item['user_id']?.toString() ??
              item['creator_id']?.toString() ??
              (item['creator'] is Map ? (item['creator']['_id'] ?? item['creator']['id'])?.toString() : null) ??
              (item['creator'] is String ? item['creator'] as String : null) ??
              '';
          final url = item['url']?.toString() ??
              item['image']?.toString() ??
              item['file']?.toString() ??
              '';

          // Filter by artist userId or include if match
          if (url.isNotEmpty && (userId.isEmpty || cId == userId || cId.isEmpty)) {
            final model = PortfolioModel.fromJson(Map<String, dynamic>.from(item));
            media.add(model.copyWith(
              id: (item['id'] ?? item['_id'])?.toString() ?? model.id,
              image: url,
              isVideo: false,
            ));
          }
        }
      }

      // 2. Videos
      final dynamic videosRaw = results[1].data;
      List<dynamic> videosList = [];
      if (videosRaw is List) {
        videosList = videosRaw;
      } else if (videosRaw is Map && videosRaw['data'] is List) {
        videosList = videosRaw['data'];
      } else if (videosRaw is Map && videosRaw['videos'] is List) {
        videosList = videosRaw['videos'];
      }

      for (final item in videosList) {
        if (item is Map) {
          final cId = item['creatorId']?.toString() ??
              item['userId']?.toString() ??
              item['user_id']?.toString() ??
              item['creator_id']?.toString() ??
              (item['creator'] is Map ? (item['creator']['_id'] ?? item['creator']['id'])?.toString() : null) ??
              (item['creator'] is String ? item['creator'] as String : null) ??
              '';
          final url = item['url']?.toString() ??
              item['video']?.toString() ??
              item['file']?.toString() ??
              '';
          final thumb = item['thumb']?.toString() ??
              item['thumbnail']?.toString() ??
              url;

          if (url.isNotEmpty && (userId.isEmpty || cId == userId || cId.isEmpty)) {
            final model = PortfolioModel.fromJson(Map<String, dynamic>.from(item));
            media.add(model.copyWith(
              id: (item['id'] ?? item['_id'])?.toString() ?? model.id,
              image: thumb,
              videoUrl: url,
              isVideo: true,
            ));
          }
        }
      }
    } catch (_) {}

    return media;
  }

  // ----------------------------------------------------------
  // Follow user
  // ----------------------------------------------------------

  @override
  Future<void> followUser(String id) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.followUser(id),
        options: _getOptions(),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception(
          'Failed to follow user. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to follow user',
      );
    }
  }

  // ----------------------------------------------------------
  // Update my profile
  // ----------------------------------------------------------

  @override
  Future<ArtistModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch(
        ApiEndpoints.profileMe,
        data: data,
        options: _getOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('==============================');
        print('UPDATE PROFILE API RESPONSE');
        print(response.data);
        print('==============================');

        final responseData = _extractData(response.data);
        return ArtistModel.fromJson(responseData);
      }

      throw Exception(
        'Failed to update profile. '
            'Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('UPDATE PROFILE API ERROR: ${e.response?.data ?? e.message}');
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            e.message ??
            'Failed to update profile',
      );
    }
  }
}