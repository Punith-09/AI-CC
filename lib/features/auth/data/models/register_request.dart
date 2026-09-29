class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? fullName;
  final String role;
  final String mobile;
  final int age;
  final String gender;
  final String? stageName;
  final String? dob;
  final String? country;
  final String? state;
  final String? city;
  final String? profilePhoto;
  final String? category;
  final String? experience;
  final List<String>? skills;
  final List<String>? languages;
  final List<String>? preferredLanguage;
  final String? qualification;
  final String? institute;
  final String? occupation;
  final List<String>? availableFor;
  final String? union;
  final String? relocate;
  final int? height;
  final int? weight;
  final String? bodyType;
  final String? skinTone;
  final String? hairColor;
  final String? eyeColor;
  final List<String>? preferredRole;
  final String? travelAvailability;
  final String? nightShoots;
  final String? headshot;
  final String? fullBody;
  final String? introVideo;
  final List<String>? previousWork;
  final String? instagram;
  final String? youtube;
  final String? imdb;
  final String? website;
  final String? resume;
  final String? awards;
  final String? bio;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    required this.role,
    required this.mobile,
    required this.age,
    required this.gender,
    this.stageName,
    this.dob,
    this.country,
    this.state,
    this.city,
    this.profilePhoto,
    this.category,
    this.experience,
    this.skills,
    this.languages,
    this.preferredLanguage,
    this.qualification,
    this.institute,
    this.occupation,
    this.availableFor,
    this.union,
    this.relocate,
    this.height,
    this.weight,
    this.bodyType,
    this.skinTone,
    this.hairColor,
    this.eyeColor,
    this.preferredRole,
    this.travelAvailability,
    this.nightShoots,
    this.headshot,
    this.fullBody,
    this.introVideo,
    this.previousWork,
    this.instagram,
    this.youtube,
    this.imdb,
    this.website,
    this.resume,
    this.awards,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'mobile': mobile,
      'age': age,
      'gender': gender,
    };
    
    if (fullName != null) data['fullName'] = fullName;
    if (stageName != null) data['stageName'] = stageName;
    if (dob != null) data['dob'] = dob;
    if (country != null) data['country'] = country;
    if (state != null) data['state'] = state;
    if (city != null) data['city'] = city;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
    if (category != null) data['category'] = category;
    if (experience != null) data['experience'] = experience;
    if (skills != null) data['skills'] = skills;
    if (languages != null) data['languages'] = languages;
    if (preferredLanguage != null) data['preferredLanguage'] = preferredLanguage;
    if (qualification != null) data['qualification'] = qualification;
    if (institute != null) data['institute'] = institute;
    if (occupation != null) data['occupation'] = occupation;
    if (availableFor != null) data['availableFor'] = availableFor;
    if (union != null) data['union'] = union;
    if (relocate != null) data['relocate'] = relocate;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (bodyType != null) data['bodyType'] = bodyType;
    if (skinTone != null) data['skinTone'] = skinTone;
    if (hairColor != null) data['hairColor'] = hairColor;
    if (eyeColor != null) data['eyeColor'] = eyeColor;
    if (preferredRole != null) data['preferredRole'] = preferredRole;
    if (travelAvailability != null) data['travelAvailability'] = travelAvailability;
    if (nightShoots != null) data['nightShoots'] = nightShoots;
    if (headshot != null) data['headshot'] = headshot;
    if (fullBody != null) data['fullBody'] = fullBody;
    if (introVideo != null) data['introVideo'] = introVideo;
    if (previousWork != null) data['previousWork'] = previousWork;
    if (instagram != null) data['instagram'] = instagram;
    if (youtube != null) data['youtube'] = youtube;
    if (imdb != null) data['imdb'] = imdb;
    if (website != null) data['website'] = website;
    if (resume != null) data['resume'] = resume;
    if (awards != null) data['awards'] = awards;
    if (bio != null) data['bio'] = bio;

    return data;
  }
}
