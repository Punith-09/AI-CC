import 'package:flutter/foundation.dart';

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
  });

  String get effectiveContact => director.isNotEmpty
      ? director
      : (contactName.isNotEmpty ? contactName : 'N/A');

  factory AuditionModel.fromJson(Map<String, dynamic> json) {
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
      };
}
