import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/application_model.dart';
import '../../data/repository/apply_job_repository.dart';

class ApplyJobProvider extends ChangeNotifier {
  final ApplyJobRepository _repository;

  ApplyJobProvider(
      this._repository,
      );

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  bool _isFetchingApplications = false;
  bool get isFetchingApplications => _isFetchingApplications;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<ApplicationModel> _applications = [];

  List<ApplicationModel> get applications =>
      List.unmodifiable(_applications);

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<bool> submitApplication({
    required String auditionId,
    required String coverLetter,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      print('');
      print('========================================');
      print('📤 SUBMIT APPLICATION');
      print('========================================');
      print('AUDITION ID: $auditionId');
      print('========================================');

      final application =
      await _repository.applyForAudition(
        auditionId,
        coverLetter: coverLetter,
      );

      /*
      Store the returned APPLICATION.

      This is important because the application ID
      is different from the audition ID.
      */

      if (application.id.isNotEmpty) {
        _applications.removeWhere(
              (item) => item.id == application.id,
        );

        _applications.add(application);
      }

      _isLoading = false;

      notifyListeners();

      print('========================================');
      print('✅ APPLICATION SUCCESS');
      print('APPLICATION ID: ${application.id}');
      print('AUDITION ID: ${application.auditionId}');
      print('========================================');

      return true;
    } catch (e) {
      _isLoading = false;

      _errorMessage = _cleanErrorMessage(e);

      notifyListeners();

      print('');
      print('❌ APPLICATION FAILED');
      print(_errorMessage);

      return false;
    }
  }

  // =========================================================
  // GET MY APPLICATIONS
  // =========================================================

  Future<bool> fetchMyApplications() async {
    _isFetchingApplications = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getMyApplications();

      _applications = result;

      _isFetchingApplications = false;

      notifyListeners();

      print('');
      print('========================================');
      print('📋 APPLICATIONS LOADED');
      print('COUNT: ${_applications.length}');
      print('========================================');

      for (final application in _applications) {
        print(
          'Application ID: ${application.id} '
              '| Audition ID: ${application.auditionId}',
        );
      }

      return true;
    } catch (e) {
      _isFetchingApplications = false;

      _errorMessage = _cleanErrorMessage(e);

      notifyListeners();

      return false;
    }
  }

  // =========================================================
  // FIND APPLICATION FOR AUDITION
  // =========================================================

  ApplicationModel? getApplicationForAudition(
      String auditionId,
      ) {
    try {
      return _applications.firstWhere(
            (application) =>
        application.auditionId == auditionId,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // WITHDRAW APPLICATION
  // =========================================================

  Future<bool> deleteApplication({
    required String applicationId,
  }) async {
    /*
    IMPORTANT:

    This method name is kept as deleteApplication
    so you don't have to change all existing UI calls.

    But it DOES NOT delete an audition.

    It withdraws the user's APPLICATION.
    */

    if (applicationId.isEmpty) {
      _errorMessage =
      'Application ID is missing.';

      notifyListeners();

      return false;
    }

    _isDeleting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      print('');
      print('========================================');
      print('🗑️ WITHDRAW APPLICATION');
      print('========================================');
      print('APPLICATION ID: $applicationId');
      print('========================================');

      await _repository.withdrawApplication(
        applicationId,
      );

      /*
      Remove only the application from local state.

      The audition remains untouched.
      */

      _applications.removeWhere(
            (application) =>
        application.id == applicationId,
      );

      _isDeleting = false;

      notifyListeners();

      print('');
      print('========================================');
      print('✅ APPLICATION WITHDRAWN');
      print('========================================');

      return true;
    } catch (e) {
      _isDeleting = false;

      _errorMessage = _cleanErrorMessage(e);

      notifyListeners();

      return false;
    }
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _repository.updateApplicationStatus(
        applicationId,
        status,
      );

      final index = _applications.indexWhere(
            (item) => item.id == applicationId,
      );

      if (index != -1) {
        final old = _applications[index];

        _applications[index] = ApplicationModel(
          id: old.id,
          auditionId: old.auditionId,
          auditionTitle: old.auditionTitle,
          role: old.role,
          status: status,
          appliedDate: old.appliedDate,
          deadline: old.deadline,
          coverLetter: old.coverLetter,
          details: old.details,
          applicantName: old.applicantName,
          applicantCategory:
          old.applicantCategory,
          audition: old.audition,
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);

      notifyListeners();

      return false;
    }
  }

  // =========================================================
  // ERROR HANDLER
  // =========================================================

  String _cleanErrorMessage(
      Object error,
      ) {
    if (error is DioException) {
      final statusCode =
          error.response?.statusCode;

      final responseData =
          error.response?.data;

      print('');
      print('========================================');
      print('🔴 BACKEND ERROR');
      print('========================================');
      print('STATUS: $statusCode');
      print('RESPONSE: $responseData');
      print('========================================');

      if (responseData is Map<String, dynamic>) {
        final message =
        responseData['message'];

        if (message is String &&
            message.isNotEmpty) {
          return message;
        }

        if (message is List &&
            message.isNotEmpty) {
          return message.join('\n');
        }

        final errorMessage =
        responseData['error'];

        if (errorMessage is String &&
            errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }

      switch (statusCode) {
        case 400:
          return 'Invalid application data.';

        case 401:
          return 'Your session has expired. Please login again.';

        case 403:
          return 'You are not allowed to perform this action.';

        case 404:
          return 'Application not found.';

        case 409:
          return 'You have already applied for this audition.';

        case 500:
          return 'Server error. Please try again later.';
      }

      return error.message ??
          'Something went wrong.';
    }

    return error.toString();
  }

  // =========================================================
  // CLEAR ERROR
  // =========================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}