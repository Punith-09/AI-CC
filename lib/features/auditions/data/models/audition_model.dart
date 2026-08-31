import 'package:flutter/foundation.dart';

@immutable
class ApplicantModel {
  final String id;
  final String applicantId;
  final String name;
  final String category;
  final String status;
  final String appliedDate;
  final String coverLetter;
  final String details;

  const ApplicantModel({
    this.id = '',
    this.applicantId = '',
    this.name = '',
    this.category = '',
    this.status = 'PENDING',
    this.appliedDate = '',
    this.coverLetter = '',
    this.details = '',
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['id'] as String? ?? '',
      applicantId: json['applicantId'] as String? ?? '',
      name: json['name'] as String? ?? json['applicantName'] as String? ?? 'Applicant',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      appliedDate: json['appliedDate'] as String? ?? '',
      coverLetter: json['coverLetter'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'applicantId': applicantId,
        'name': name,
        'category': category,
        'status': status,
        'appliedDate': appliedDate,
        'coverLetter': coverLetter,
        'details': details,
      };
}

@immutable
class AuditionModel {
  final String id;
  final String creatorId;
  final String title;
  final String category;
  final String role;
  final String language;
  final String pay;
  final String location;
  final String deadline;
  final String description;
  final String director;
  final String contactName;
  final String createdAt;
  final bool applied;
  final bool createdByMe;
  final String phone;
  final String email;
  final List<ApplicantModel> applicants;

  const AuditionModel({
    this.id = '',
    this.creatorId = '',
    required this.title,
    required this.category,
    required this.role,
    required this.language,
    required this.pay,
    required this.location,
    required this.deadline,
    required this.description,
    this.director = '',
    this.contactName = '',
    this.createdAt = '',
    this.applied = false,
    this.createdByMe = false,
    this.phone = '',
    this.email = '',
    this.applicants = const [],
  });

  int get applicantsCount => applicants.length;

  String get effectiveContact => director.isNotEmpty
      ? director
      : (contactName.isNotEmpty ? contactName : 'N/A');

  factory AuditionModel.fromJson(Map<String, dynamic> json) {
    List<ApplicantModel> parsedApplicants = [];
    if (json['applicants'] is List) {
      for (final item in json['applicants'] as List) {
        if (item is Map<String, dynamic>) {
          parsedApplicants.add(ApplicantModel.fromJson(item));
        } else if (item is Map) {
          parsedApplicants.add(ApplicantModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return AuditionModel(
      id: json['id'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      role: json['role'] as String? ?? '',
      language: (json['lang'] ?? json['language']) as String? ?? '',
      pay: json['pay'] as String? ?? '',
      location: json['location'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      description: (json['desc'] ?? json['description']) as String? ?? '',
      director: json['director'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      createdByMe: json['createdByMe'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      applicants: parsedApplicants,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'creatorId': creatorId,
        'title': title,
        'category': category,
        'role': role,
        'lang': language,
        'pay': pay,
        'location': location,
        'deadline': deadline,
        'desc': description,
        'director': director,
        'contactName': contactName,
        'createdAt': createdAt,
        'applied': applied,
        'createdByMe': createdByMe,
        'phone': phone,
        'email': email,
        'applicants': applicants.map((e) => e.toJson()).toList(),
      };
}
