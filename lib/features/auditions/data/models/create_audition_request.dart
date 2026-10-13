class CreateAuditionRequest {
  final String title;
  final String category;
  final String role;
  final int? roleAgeMin;
  final int? roleAgeMax;
  final String? roleGender;
  final String location;
  final String? pay;
  final String deadline;
  final String lang;
  final String desc;

  CreateAuditionRequest({
    required this.title,
    required this.category,
    required this.role,
    this.roleAgeMin,
    this.roleAgeMax,
    this.roleGender,
    required this.location,
    this.pay,
    required this.deadline,
    required this.lang,
    required this.desc,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'role': role,
        if (roleAgeMin != null) 'roleAgeMin': roleAgeMin,
        if (roleAgeMax != null) 'roleAgeMax': roleAgeMax,
        if (roleGender != null && roleGender!.isNotEmpty) 'roleGender': roleGender,
        'location': location,
        if (pay != null && pay!.isNotEmpty) 'pay': pay,
        'deadline': deadline,
        'lang': lang,
        'desc': desc,
      };
}
