class CreateAuditionRequest {
  final String title;
  final String category;
  final String role;
  final String location;
  final String pay;
  final String deadline;
  final String lang;
  final String desc;

  CreateAuditionRequest({
    required this.title,
    required this.category,
    required this.role,
    required this.location,
    required this.pay,
    required this.deadline,
    required this.lang,
    required this.desc,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'role': role,
        'location': location,
        'pay': pay,
        'deadline': deadline,
        'lang': lang,
        'desc': desc,
      };
}
