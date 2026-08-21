import 'package:dio/dio.dart';

import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ArtistModel> getProfileMe();

  Future<ArtistModel> getUserProfile(String id);

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

    // Case 1:
    // {
    //   "data": {
    //      "name": "Lokesh"
    //   }
    // }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    // Case 2:
    // {
    //   "name": "Lokesh"
    // }

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
        print('==============================');
        print('PROFILE ME API RESPONSE');
        print(response.data);
        print('==============================');

        final data = _extractData(response.data);

        print('PROFILE DATA AFTER EXTRACTION');
        print(data);

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
        'Failed to get profile. '
            'Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('PROFILE API ERROR');
      print(e.response?.data ?? e.message);

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to get profile',
      );
    } catch (e) {
      print('PROFILE PARSING ERROR: $e');

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
        print('==============================');
        print('USER PROFILE API RESPONSE');
        print(response.data);
        print('==============================');

        final data = _extractData(response.data);

        print('USER PROFILE DATA AFTER EXTRACTION');
        print(data);

        return ArtistModel.fromJson(data);
      }

      throw Exception(
        'Failed to get user profile. '
            'Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('USER PROFILE API ERROR');
      print(e.response?.data ?? e.message);

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to get user profile',
      );
    } catch (e) {
      print('USER PROFILE PARSING ERROR: $e');

      rethrow;
    }
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
          'Failed to follow user. '
              'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('FOLLOW USER API ERROR');
      print(e.response?.data ?? e.message);

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to follow user',
      );
    }
  }
}