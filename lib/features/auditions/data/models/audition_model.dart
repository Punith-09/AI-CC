import 'package:flutter/foundation.dart';

@immutable
class AuditionModel {
  final String id;
  final String title;
  final String category;
  final String role;
  final String language;
  final String pay;
  final String location;
  final String deadline;
  final String description;
  final String director;
  final String phone;
  final String email;

  const AuditionModel({
    this.id = '',
    required this.title,
    required this.category,
    required this.role,
    required this.language,
    required this.pay,
    required this.location,
    required this.deadline,
    required this.description,
    required this.director,
    required this.phone,
    required this.email,
  });

  factory AuditionModel.fromJson(Map<String, dynamic> json) {
    return AuditionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      role: json['role'] as String? ?? '',
      language: json['language'] as String? ?? '',
      pay: json['pay'] as String? ?? '',
      location: json['location'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      director: json['director'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'role': role,
        'language': language,
        'pay': pay,
        'location': location,
        'deadline': deadline,
        'description': description,
        'director': director,
        'phone': phone,
        'email': email,
      };
}
