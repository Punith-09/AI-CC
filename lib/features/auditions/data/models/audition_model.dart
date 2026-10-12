import 'package:flutter/foundation.dart';

@immutable
class ApplicantModel {
  final String id;
  final String applicantId;
  final String userId;
  final String name;
  final String category;
  final String status;
  final String appliedDate;
  final String coverLetter;
  final String details;
  final String profilePicture;

  const ApplicantModel({
    this.id = '',
    this.applicantId = '',
    this.userId = '',
    this.name = '',
    this.category = '',
    this.status = 'PENDING',
    this.appliedDate = '',
    this.coverLetter = '',
    this.details = '',
    this.profilePicture = '',
  });

  /// The resolved user ID to navigate to their profile
  String get targetUserId {
    if (userId.isNotEmpty) return userId;
    if (applicantId.isNotEmpty) return applicantId;
    return id;
  }

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic val) {
      if (val == null) return '';
      if (val is String) return val.trim();
      if (val is Map) return (val['id'] ?? val['_id'] ?? '').toString().trim();
      return val.toString().trim();
    }

    String parsedUserId = '';
    if (json['userId'] != null) {
      parsedUserId = extractId(json['userId']);
    } else if (json['user_id'] != null) {
      parsedUserId = extractId(json['user_id']);
    } else if (json['user'] != null) {
      parsedUserId = extractId(json['user']);
    }

    String parsedApplicantId = '';
    if (json['applicantId'] != null) {
      parsedApplicantId = extractId(json['applicantId']);
    } else if (json['applicant_id'] != null) {
      parsedApplicantId = extractId(json['applicant_id']);
    } else if (json['applicant'] != null) {
      parsedApplicantId = extractId(json['applicant']);
    } else if (json['artistId'] != null) {
      parsedApplicantId = extractId(json['artistId']);
    }

    final parsedId = (json['id'] ?? json['_id'] ?? '').toString().trim();

    if (parsedUserId.isEmpty && parsedApplicantId.isNotEmpty) {
      parsedUserId = parsedApplicantId;
    } else if (parsedApplicantId.isEmpty && parsedUserId.isNotEmpty) {
      parsedApplicantId = parsedUserId;
    }

    String parsedName = '';
    if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      parsedName = json['name'].toString().trim();
    } else if (json['applicantName'] != null && json['applicantName'].toString().trim().isNotEmpty) {
      parsedName = json['applicantName'].toString().trim();
    } else if (json['user'] is Map) {
      final u = json['user'] as Map;
      parsedName = (u['name'] ?? u['fullName'] ?? u['username'] ?? '').toString().trim();
    } else if (json['applicant'] is Map) {
      final a = json['applicant'] as Map;
      parsedName = (a['name'] ?? a['fullName'] ?? a['username'] ?? '').toString().trim();
    }
    if (parsedName.isEmpty) {
      parsedName = 'Applicant';
    }

    String parsedCategory = '';
    if (json['category'] != null) {
      parsedCategory = json['category'].toString().trim();
    } else if (json['user'] is Map) {
      final u = json['user'] as Map;
      parsedCategory = (u['category'] ?? u['role'] ?? u['profession'] ?? '').toString().trim();
    } else if (json['applicant'] is Map) {
      final a = json['applicant'] as Map;
      parsedCategory = (a['category'] ?? a['role'] ?? a['profession'] ?? '').toString().trim();
    }

    String parsedPicture = '';
    if (json['profilePicture'] != null) {
      parsedPicture = json['profilePicture'].toString().trim();
    } else if (json['avatar'] != null) {
      parsedPicture = json['avatar'].toString().trim();
    } else if (json['user'] is Map) {
      final u = json['user'] as Map;
      parsedPicture = (u['profilePicture'] ?? u['avatar'] ?? u['image'] ?? u['photo'] ?? '').toString().trim();
    } else if (json['applicant'] is Map) {
      final a = json['applicant'] as Map;
      parsedPicture = (a['profilePicture'] ?? a['avatar'] ?? a['image'] ?? a['photo'] ?? '').toString().trim();
    }

    return ApplicantModel(
      id: parsedId,
      applicantId: parsedApplicantId,
      userId: parsedUserId,
      name: parsedName,
      category: parsedCategory,
      status: (json['status'] ?? 'PENDING').toString().trim(),
      appliedDate: (json['appliedDate'] ?? json['applied_date'] ?? json['createdAt'] ?? json['created_at'] ?? '').toString().trim(),
      coverLetter: (json['coverLetter'] ?? json['cover_letter'] ?? '').toString().trim(),
      details: (json['details'] ?? '').toString().trim(),
      profilePicture: parsedPicture,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'applicantId': applicantId,
        'userId': userId,
        'name': name,
        'category': category,
        'status': status,
        'appliedDate': appliedDate,
        'coverLetter': coverLetter,
        'details': details,
        'profilePicture': profilePicture,
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
  final String auditionDate;
  final String age;
  final String gender;
  final String experience;
  final String skills;

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
    this.auditionDate = '',
    this.age = '',
    this.gender = '',
    this.experience = '',
    this.skills = '',
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
      auditionDate: (json['auditionDate'] ?? json['audition_date'] ?? json['date']) as String? ?? '',
      age: json['age'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      skills: json['skills'] as String? ?? '',
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
        'auditionDate': auditionDate,
        'age': age,
        'gender': gender,
        'experience': experience,
        'skills': skills,
      };
}
