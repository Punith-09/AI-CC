import 'package:flutter/material.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';

/// Central form state shared across all 5 profile completion steps.
class ProfileFormData {
  // ── Step 1: Basic Information ─────────────────────────────
  late final TextEditingController fullNameController;
  late final TextEditingController stageNameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  String? dobDay;
  String? dobMonth;
  String? dobYear;
  String? gender;
  String? country;
  String? state;
  String? city;

  // ── Step 2: Professional Profile ──────────────────────────
  String? category;
  String? experience;
  final List<String> skills = [];
  final List<String> languages = [];
  final List<String> preferredLanguages = [];
  String? qualification;
  late final TextEditingController instituteController;
  String? occupation;
  final List<String> availableFor = [];
  String? union; // 'Yes' or 'No'
  String? relocate; // 'Yes' or 'No'

  // ── Step 3: Personal & Physical Details ───────────────────
  late final TextEditingController heightController;
  late final TextEditingController weightController;
  String? bodyType;
  String? skinTone;
  String? hairColor;
  String? eyeColor;
  final List<String> preferredRoles = [];
  String? travelAvailability;
  String? nightShoots; // 'Yes' or 'No'

  // ── Step 4: Portfolio & Experience ────────────────────────
  String? headshot;
  String? fullBody;
  String? introVideo;
  final List<String> previousWork = [];
  late final TextEditingController instagramController;
  late final TextEditingController youtubeController;
  late final TextEditingController imdbController;
  late final TextEditingController websiteController;
  String? resume;
  late final TextEditingController awardsController;
  late final TextEditingController bioController;

  // ── Step 5: Terms & Conditions ────────────────────────────
  bool agreeTerms = true;
  bool agreePrivacy = true;

  ProfileFormData({ArtistModel? initialProfile}) {
    fullNameController =
        TextEditingController(text: initialProfile?.name ?? '');
    stageNameController =
        TextEditingController(text: initialProfile?.stageName ?? '');
    mobileController =
        TextEditingController(text: initialProfile?.mobile ?? '');
    emailController =
        TextEditingController(text: initialProfile?.email ?? '');

    if (initialProfile?.gender != null && initialProfile!.gender.isNotEmpty) {
      gender = initialProfile.gender;
    }
    if (initialProfile?.country != null &&
        initialProfile!.country.isNotEmpty) {
      country = initialProfile.country;
    }
    if (initialProfile?.state != null && initialProfile!.state.isNotEmpty) {
      state = initialProfile.state;
    }
    if (initialProfile?.city != null && initialProfile!.city.isNotEmpty) {
      city = initialProfile.city;
    }

    if (initialProfile?.dob != null && initialProfile!.dob.isNotEmpty) {
      final parts = initialProfile.dob.split(RegExp(r'[-/]'));
      if (parts.length >= 3) {
        if (parts[0].length == 4) {
          dobYear = parts[0];
          dobMonth = parts[1].padLeft(2, '0');
          dobDay = parts[2].padLeft(2, '0');
        } else {
          dobDay = parts[0].padLeft(2, '0');
          dobMonth = parts[1].padLeft(2, '0');
          dobYear = parts[2];
        }
      }
    }

    if (initialProfile?.roles != null && initialProfile!.roles.isNotEmpty) {
      category = initialProfile.roles.first;
    }
    if (initialProfile?.experience != null &&
        initialProfile!.experience.isNotEmpty) {
      experience = initialProfile.experience;
    }
    if (initialProfile?.skills != null) {
      skills.addAll(initialProfile!.skills);
    }
    if (initialProfile?.languages != null &&
        initialProfile!.languages.isNotEmpty) {
      languages.addAll(initialProfile.languages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty));
    }
    if (initialProfile?.preferredLanguages != null) {
      preferredLanguages.addAll(initialProfile!.preferredLanguages);
    }

    instituteController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    instagramController = TextEditingController();
    youtubeController = TextEditingController();
    imdbController = TextEditingController();
    websiteController = TextEditingController();
    awardsController = TextEditingController(
      text: (initialProfile?.awards != null && initialProfile!.awards > 0)
          ? initialProfile.awards.toString()
          : '',
    );
    bioController = TextEditingController();
  }

  void dispose() {
    fullNameController.dispose();
    stageNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    instituteController.dispose();
    heightController.dispose();
    weightController.dispose();
    instagramController.dispose();
    youtubeController.dispose();
    imdbController.dispose();
    websiteController.dispose();
    awardsController.dispose();
    bioController.dispose();
  }

  String get dobFormatted {
    if (dobDay != null &&
        dobMonth != null &&
        dobYear != null &&
        dobDay!.isNotEmpty &&
        dobMonth!.isNotEmpty &&
        dobYear!.isNotEmpty) {
      return '$dobYear-$dobMonth-$dobDay';
    }
    return '';
  }

  int? _extractInt(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return null;
    final match = RegExp(r'\d+').firstMatch(clean);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  /// Builds payload up to the specified step [0..4].
  Map<String, dynamic> toMapUpToStep(int step) {
    final map = <String, dynamic>{};

    void addIfNotEmpty(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        map[key] = value.trim();
      }
    }

    void addListIfNotEmpty(String key, List<String> list) {
      if (list.isNotEmpty) {
        map[key] = list;
      }
    }

    // Step 0: Basic Information
    addIfNotEmpty('fullName', fullNameController.text);
    addIfNotEmpty('stageName', stageNameController.text);
    addIfNotEmpty('mobile', mobileController.text);
    addIfNotEmpty('email', emailController.text);

    if (dobFormatted.isNotEmpty) {
      map['dob'] = dobFormatted;
      if (dobYear != null && int.tryParse(dobYear!) != null) {
        final birthYear = int.parse(dobYear!);
        final calculatedAge = DateTime.now().year - birthYear;
        if (calculatedAge > 0 && calculatedAge < 120) {
          map['age'] = calculatedAge;
        }
      }
    }

    addIfNotEmpty('gender', gender);
    addIfNotEmpty('country', country);
    addIfNotEmpty('state', state);
    addIfNotEmpty('city', city);

    // Step 1: Professional Profile
    if (step >= 1) {
      addIfNotEmpty('category', category);
      addIfNotEmpty('experience', experience);
      addListIfNotEmpty('skills', skills);
      addListIfNotEmpty('languages', languages);
      addListIfNotEmpty('preferredLanguage', preferredLanguages);
      addIfNotEmpty('qualification', qualification);
      addIfNotEmpty('institute', instituteController.text);
      addIfNotEmpty('occupation', occupation);
      addListIfNotEmpty('availableFor', availableFor);
      addIfNotEmpty('union', union);
      addIfNotEmpty('relocate', relocate);
    }

    // Step 2: Personal & Physical Details
    if (step >= 2) {
      final hVal = _extractInt(heightController.text);
      if (hVal != null) {
        map['height'] = hVal;
      }
      final wVal = _extractInt(weightController.text);
      if (wVal != null) {
        map['weight'] = wVal;
      }
      addIfNotEmpty('bodyType', bodyType);
      addIfNotEmpty('skinTone', skinTone);
      addIfNotEmpty('hairColor', hairColor);
      addIfNotEmpty('eyeColor', eyeColor);
      addListIfNotEmpty('preferredRole', preferredRoles);
      addIfNotEmpty('travelAvailability', travelAvailability);
      addIfNotEmpty('nightShoots', nightShoots);
    }

    // Step 3: Portfolio & Experience
    if (step >= 3) {
      addIfNotEmpty('headshot', headshot);
      addIfNotEmpty('fullBody', fullBody);
      addIfNotEmpty('introVideo', introVideo);
      addListIfNotEmpty('previousWork', previousWork);
      addIfNotEmpty('instagram', instagramController.text);
      addIfNotEmpty('youtube', youtubeController.text);
      addIfNotEmpty('imdb', imdbController.text);
      addIfNotEmpty('website', websiteController.text);
      addIfNotEmpty('resume', resume);
      addIfNotEmpty('awards', awardsController.text);
      addIfNotEmpty('bio', bioController.text);
    }

    return map;
  }

  /// Builds payload matching PATCH /profile/me.
  /// Strictly omits empty strings, nulls, and empty lists to avoid backend SQL/Prisma schema violations.
  Map<String, dynamic> toMap() {
    return toMapUpToStep(4);
  }
}
