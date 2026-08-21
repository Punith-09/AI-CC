import 'package:flutter/foundation.dart';

import '../../../../features/auditions/data/models/audition_model.dart';

@immutable
class ApplicationModel {
  final String id;

  /// ID of the audition/job that this application belongs to.
  final String auditionId;

  final String auditionTitle;
  final String role;
  final String status;
  final String appliedDate;
  final String deadline;
  final String coverLetter;
  final String details;
  final String applicantName;
  final String applicantCategory;

  final AuditionModel? audition;

  const ApplicationModel({
    required this.id,
    required this.auditionId,
    this.auditionTitle = '',
    this.role = '',
    required this.status,
    this.appliedDate = '',
    this.deadline = '',
    this.coverLetter = '',
    this.details = '',
    this.applicantName = '',
    this.applicantCategory = '',
    this.audition,
  });

  factory ApplicationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    /*
    IMPORTANT

    Backend may return:

    {
      "id": "APPLICATION-ID",
      "auditionId": "AUDITION-ID"
    }

    OR:

    {
      "_id": "APPLICATION-ID",
      "auditionId": "AUDITION-ID"
    }

    OR:

    {
      "applicationId": "APPLICATION-ID",
      "auditionId": "AUDITION-ID"
    }

    We must NEVER use auditionId as application id.
    */

    final String applicationId = _string(
      json['id'] ??
          json['_id'] ??
          json['applicationId'],
    );

    String auditionId = _string(
      json['auditionId'] ??
          json['audition_id'],
    );

    /*
    Sometimes backend returns:

    "audition": {
       "id": "AUDITION-ID"
    }
    */

    final dynamic auditionJson = json['audition'];

    AuditionModel? auditionModel;

    if (auditionJson is Map<String, dynamic>) {
      auditionModel = AuditionModel.fromJson(
        auditionJson,
      );

      if (auditionId.isEmpty) {
        auditionId = _string(
          auditionJson['id'] ??
              auditionJson['_id'],
        );
      }
    }

    return ApplicationModel(
      id: applicationId,

      auditionId: auditionId,

      auditionTitle: _string(
        json['auditionTitle'] ??
            auditionModel?.title,
      ),

      role: _string(
        json['role'] ??
            auditionModel?.role,
      ),

      status: _string(
        json['status'],
      ),

      appliedDate: _string(
        json['appliedDate'] ??
            json['createdAt'],
      ),

      deadline: _string(
        json['deadline'] ??
            auditionModel?.deadline,
      ),

      coverLetter: _string(
        json['coverLetter'] ??
            json['message'],
      ),

      details: _string(
        json['details'] ??
            auditionModel?.description,
      ),

      applicantName: _string(
        json['applicantName'],
      ),

      applicantCategory: _string(
        json['applicantCategory'],
      ),

      audition: auditionModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auditionId': auditionId,
      'auditionTitle': auditionTitle,
      'role': role,
      'status': status,
      'appliedDate': appliedDate,
      'deadline': deadline,
      'coverLetter': coverLetter,
      'details': details,
      'applicantName': applicantName,
      'applicantCategory': applicantCategory,
      if (audition != null)
        'audition': audition!.toJson(),
    };
  }

  static String _string(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }
}