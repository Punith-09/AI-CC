class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String role;
  final String mobile;
  final String stageName;
  final String dob;
  final String gender;
  final String country;
  final String state;
  final String city;
  final String profilePhoto;
  final String category;
  final String experience;

  final List<String> skills;
  final List<String> languages;
  final List<String> preferredLanguage;

  final String qualification;
  final String institute;
  final String occupation;

  final List<String> availableFor;

  final String union;
  final String relocate;

  final int height;
  final int weight;

  final String bodyType;
  final String skinTone;
  final String hairColor;
  final String eyeColor;

  final List<String> preferredRole;

  final String travelAvailability;
  final String nightShoots;

  final String headshot;
  final String fullBody;
  final String introVideo;

  final List<String> previousWork;

  final String instagram;
  final String youtube;
  final String imdb;
  final String website;

  final String resume;
  final String awards;
  final String bio;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.mobile,
    required this.stageName,
    required this.dob,
    required this.gender,
    required this.country,
    required this.state,
    required this.city,
    required this.profilePhoto,
    required this.category,
    required this.experience,
    required this.skills,
    required this.languages,
    required this.preferredLanguage,
    required this.qualification,
    required this.institute,
    required this.occupation,
    required this.availableFor,
    required this.union,
    required this.relocate,
    required this.height,
    required this.weight,
    required this.bodyType,
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.preferredRole,
    required this.travelAvailability,
    required this.nightShoots,
    required this.headshot,
    required this.fullBody,
    required this.introVideo,
    required this.previousWork,
    required this.instagram,
    required this.youtube,
    required this.imdb,
    required this.website,
    required this.resume,
    required this.awards,
    required this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
      'mobile': mobile,
      'stageName': stageName,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'city': city,
      'profilePhoto': profilePhoto,
      'category': category,
      'experience': experience,
      'skills': skills,
      'languages': languages,
      'preferredLanguage': preferredLanguage,
      'qualification': qualification,
      'institute': institute,
      'occupation': occupation,
      'availableFor': availableFor,
      'union': union,
      'relocate': relocate,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'skinTone': skinTone,
      'hairColor': hairColor,
      'eyeColor': eyeColor,
      'preferredRole': preferredRole,
      'travelAvailability': travelAvailability,
      'nightShoots': nightShoots,
      'headshot': headshot,
      'fullBody': fullBody,
      'introVideo': introVideo,
      'previousWork': previousWork,
      'instagram': instagram,
      'youtube': youtube,
      'imdb': imdb,
      'website': website,
      'resume': resume,
      'awards': awards,
      'bio': bio,
    };
  }
}