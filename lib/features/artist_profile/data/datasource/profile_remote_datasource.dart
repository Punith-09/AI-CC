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

    final dynamic data = response['data'];

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
        final artist = ArtistModel.fromJson(data);
        if (artist.id.isNotEmpty) {
          _localStorage.saveUserId(artist.id);
        }
        if (artist.name.isNotEmpty) {
          _localStorage.saveUserName(artist.name);
        }
        if (artist.profileImage.isNotEmpty) {
          _localStorage.saveUserProfilePhoto(artist.profileImage);
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
        return ArtistModel.fromJson(data);
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
              item['creator_id']?.toString() ??
              '';
          final url = item['url']?.toString() ??
              item['image']?.toString() ??
              item['file']?.toString() ??
              '';

          // Filter by artist userId or include if match
          if (url.isNotEmpty && (userId.isEmpty || cId == userId || cId.isEmpty)) {
            media.add(PortfolioModel(
              id: item['id']?.toString() ?? '',
              image: url,
              title: item['title']?.toString(),
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
              item['creator_id']?.toString() ??
              '';
          final url = item['url']?.toString() ??
              item['video']?.toString() ??
              item['file']?.toString() ??
              '';
          final thumb = item['thumb']?.toString() ??
              item['thumbnail']?.toString() ??
              url;

          if (url.isNotEmpty && (userId.isEmpty || cId == userId || cId.isEmpty)) {
            media.add(PortfolioModel(
              id: item['id']?.toString() ?? '',
              image: thumb,
              videoUrl: url,
              title: item['title']?.toString(),
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
}