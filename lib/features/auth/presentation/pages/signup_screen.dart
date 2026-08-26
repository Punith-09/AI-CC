
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';

import '../../data/models/register_request.dart';

import '../../data/repository/auth_repository.dart';
import '../widgets/signup_step_header.dart';
import '../../../../core/utils/location_data.dart';

class SignUpWizardPage extends StatefulWidget {
  const SignUpWizardPage({super.key});

  @override
  State<SignUpWizardPage> createState() => _SignUpWizardPageState();
}

class _SignUpWizardPageState extends State<SignUpWizardPage> {
  bool _obscurePassword = true;
  // ============================================================
  // DEPENDENCY
  // ============================================================

  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  final PageController _pageController = PageController();

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

  int _currentStep = 0;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final _fullName = TextEditingController();

  final _stageName = TextEditingController();

  final _phone = TextEditingController();

  final _email = TextEditingController();

  final _password = TextEditingController();

  final _institute = TextEditingController();

  final _instagram = TextEditingController();

  final _youtube = TextEditingController();

  final _imdb = TextEditingController();

  final _website = TextEditingController();

  final _awards = TextEditingController();

  final _bio = TextEditingController();

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  String? _gender;
  String? _country;
  String? _state;
  String? _city;

  DateTime? _dob;

  // ============================================================
  // ============================================================
  // PROFESSIONAL PROFILE
  // ============================================================

  String? _category;
  String? _experience;
  String? _qualification;
  String? _occupation;

  // ============================================================
  // PERSONAL DETAILS
  // ============================================================

  String? _height;
  String? _weight;
  String? _bodyType;
  String? _skinTone;
  String? _hairColor;
  String? _eyeColor;

  String? _travelAvailability;

  // ============================================================
  // BOOLEAN VALUES
  // ============================================================

  bool _unionMember = false;
  bool _relocate = false;
  bool _nightShoots = false;

  // ============================================================
  // MULTI SELECT VALUES
  // ============================================================

  final Set<String> _skills = {};

  final Set<String> _languages = {};

  final Set<String> _actingLanguages = {};

  final Set<String> _availableFor = {};

  final Set<String> _roles = {};

  final Set<String> _previousWork = {};

  // ============================================================
  // UPLOAD STATE
  // Key = field identifier
  // ============================================================

  // Picked files (local)
  final Map<String, XFile> _selectedFiles = {};
  final Map<String, Uint8List> _selectedBytes = {};

  // Uploaded URLs returned by backend
  final Map<String, String> _uploadUrls = {};

  // Per-field uploading flag
  final Map<String, bool> _uploading = {};

  // Convenience field keys
  static const _kProfilePhoto = 'profilePhoto';
  static const _kHeadshot    = 'headshot';
  static const _kFullBody    = 'fullBody';
  static const _kIntroVideo  = 'introVideo';
  static const _kResume      = 'resume';

  // Image picker (same as post screens)
  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // LOADING
  // ============================================================

  bool _isSubmitting = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const _blue = Color(0xFF2F5BEA);

  static const _steps = [
    'Basic Information',
    'Professional Profile',
    'Personal Details',
    'Portfolio',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();

    for (final controller in [
      _fullName,
      _stageName,
      _phone,
      _email,
      _password,
      _institute,
      _instagram,
      _youtube,
      _imdb,
      _website,
      _awards,
      _bio,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<bool> _checkPhoneUnique(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (cleanPhone.isEmpty) return true;

    // 1. Check local persistent registry
    if (LocalStorage.instance.isPhoneLocallyRegistered(cleanPhone)) {
      return false;
    }

    try {
      final dioClient = GetIt.instance<DioClient>();
      final response = await dioClient.get(ApiEndpoints.exploreUsers);
      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('users')) {
        listData = (response.data as Map)['users'];
      } else if (response.data is Map && (response.data as Map).containsKey('talents')) {
        listData = (response.data as Map)['talents'];
      }

      if (listData is List) {
        for (final item in listData) {
          if (item is Map) {
            final userPhone = item['mobile']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
                item['phone']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
                item['phoneNumber']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
                '';
            if (userPhone.isNotEmpty && userPhone == cleanPhone) {
              return false;
            }
          }
        }
      }
    } catch (_) {}
    return true;
  }

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> _next() async {
    final isValid = _formKeys[_currentStep].currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (_currentStep == 0) {
      setState(() => _isSubmitting = true);
      final isUnique = await _checkPhoneUnique(_phone.text.trim());
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This mobile number is already registered. Please use another number.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    if (_currentStep == _steps.length - 1) {
      _submitProfile();
      return;
    }

    setState(() {
      _currentStep++;
    });

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // BACK
  // ============================================================

  void _back() {
    if (_currentStep == 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // REQUIRED VALIDATOR
  // ============================================================

  String? _required(String? value, [String label = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  // ============================================================
  // SUBMIT PROFILE
  // ============================================================

  Future<void> _submitProfile() async {
    final isValid = _formKeys[3].currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isUnique = await _checkPhoneUnique(_phone.text.trim());
      if (!isUnique) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This mobile number is already registered. Please use another number.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // ========================================================
      // HEIGHT
      // Example: "172 cm" -> 172
      // ========================================================

      final heightValue =
          int.tryParse(_height?.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0;

      // ========================================================
      // WEIGHT
      // Example: "64 kg" -> 64
      // ========================================================

      final weightValue =
          int.tryParse(_weight?.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0;

      // ========================================================
      // CREATE REGISTER REQUEST
      // ========================================================

      final request = RegisterRequest(
        email: _email.text.trim(),

        password: _password.text,

        fullName: _fullName.text.trim(),

        role: 'artist',

        mobile: _phone.text.trim(),

        stageName: _stageName.text.trim(),

        dob: _dob != null ? _dob!.toIso8601String().split('T').first : '',

        gender: _gender ?? '',

        country: _country ?? '',

        state: _state ?? '',

        city: _city ?? '',

        profilePhoto: _uploadUrls[_kProfilePhoto] ?? '',

        category: _category ?? '',

        experience: _experience ?? '',

        skills: _skills.toList(),

        languages: _languages.toList(),

        preferredLanguage: _actingLanguages.toList(),

        qualification: _qualification ?? '',

        institute: _institute.text.trim(),

        occupation: _occupation ?? '',

        availableFor: _availableFor.toList(),

        union: _unionMember ? 'Yes' : 'No',

        relocate: _relocate ? 'Yes' : 'No',

        height: heightValue,

        weight: weightValue,

        bodyType: _bodyType ?? '',

        skinTone: _skinTone ?? '',

        hairColor: _hairColor ?? '',

        eyeColor: _eyeColor ?? '',

        preferredRole: _roles.toList(),

        travelAvailability: _travelAvailability ?? '',

        nightShoots: _nightShoots ? 'Yes' : 'No',

        headshot: _uploadUrls[_kHeadshot] ?? '',

        fullBody: _uploadUrls[_kFullBody] ?? '',

        introVideo: _uploadUrls[_kIntroVideo] ?? '',

        previousWork: _previousWork.toList(),

        instagram: _instagram.text.trim(),

        youtube: _youtube.text.trim(),

        imdb: _imdb.text.trim(),

        website: _website.text.trim(),

        resume: _uploadUrls[_kResume] ?? '',

        awards: _awards.text.trim(),

        bio: _bio.text.trim(),
      );

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('REGISTERING USER');
      debugPrint('==========================================');
      debugPrint(request.toJson().toString());
      debugPrint('==========================================');

      // ========================================================
      // CALL API
      // ========================================================

      final response = await _authRepository.register(request);

      await LocalStorage.instance.recordRegisteredPhone(_phone.text.trim());

      // If backend didn't return an auth token directly on register,
      // log the user in immediately with their credentials.
      if (response.token.isEmpty) {
        await _authRepository.login(_email.text.trim(), _password.text);
      }

      // ========================================================
      // POST-AUTH FILE UPLOADS (Profile photo & portfolio)
      // ========================================================

      if (_selectedFiles[_kProfilePhoto] != null) {
        try {
          final file = _selectedFiles[_kProfilePhoto]!;
          final bytes = _selectedBytes[_kProfilePhoto];
          final dioClient = GetIt.instance<DioClient>();
          MultipartFile multipartFile;
          if (bytes != null) {
            multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
          } else if (!kIsWeb && file.path.isNotEmpty) {
            multipartFile = await MultipartFile.fromFile(file.path, filename: file.name);
          } else {
            multipartFile = MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name);
          }
          final formData = FormData.fromMap({
            'title': 'Profile Photo',
            'description': '',
            'file': multipartFile,
          });
          final photoRes = await dioClient.post(ApiEndpoints.photos, data: formData);
          String? photoUrl;
          if (photoRes.data is Map) {
            final map = Map<String, dynamic>.from(photoRes.data as Map);
            final inner = map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
            photoUrl = inner['url'] as String?;
          }
          if (photoUrl != null && photoUrl.isNotEmpty) {
            await LocalStorage.instance.saveUserProfilePhoto(photoUrl);
            try {
              await dioClient.patch(ApiEndpoints.profileMe, data: {'profilePhoto': photoUrl});
            } catch (_) {}
          }
        } catch (uploadErr) {
          debugPrint('Profile photo post-auth upload error: $uploadErr');
        }
      }

      for (final key in [_kHeadshot, _kFullBody, _kIntroVideo]) {
        if (_selectedFiles[key] != null) {
          try {
            final file = _selectedFiles[key]!;
            final bytes = _selectedBytes[key];
            final dioClient = GetIt.instance<DioClient>();
            final isVideo = key == _kIntroVideo;
            MultipartFile multipartFile;
            if (bytes != null) {
              multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
            } else if (!kIsWeb && file.path.isNotEmpty) {
              multipartFile = await MultipartFile.fromFile(file.path, filename: file.name);
            } else {
              multipartFile = MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name);
            }
            final formData = FormData.fromMap({
              'title': file.name,
              'description': key,
              'file': multipartFile,
            });
            await dioClient.post(isVideo ? ApiEndpoints.uploadVideo : ApiEndpoints.photos, data: formData);
          } catch (_) {}
        }
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // NAVIGATE TO HOME
      // ========================================================

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.home);
    } catch (e) {
      // ========================================================
      // ERROR
      // ========================================================

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('REGISTER FAILED');
      debugPrint('==========================================');
      debugPrint(e.toString());
      debugPrint('==========================================');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2A),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xFF0B1F2A),

        foregroundColor: Colors.white70,
        leading: IconButton(
            onPressed: (){
              context.go(AppRoutes.welcome);
            },
            icon:Icon(
              LucideIcons.chevronLeft,
              size: 24,
            ),
        ),

        title: const Text(
          'Create your artist profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // STEP HEADER
            // ==================================================
            SignUpStepHeader(currentStep: _currentStep),

            // ==================================================
            // PAGE CONTENT
            // ==================================================
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(14),

                decoration: const BoxDecoration(
                  color: Color(0xFF123B4A),

                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),

                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      labelStyle: TextStyle(color: Color(0xFFC5C8D0)),

                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF5E6472)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _blue, width: 2),
                      ),
                    ),

                    dropdownMenuTheme: const DropdownMenuThemeData(
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),

                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),

                    child: PageView(
                      controller: _pageController,

                      physics: const NeverScrollableScrollPhysics(),

                      children: [
                        _form(0, _basicInformation()),

                        _form(1, _professionalProfile()),

                        _form(2, _personalDetails()),

                        _form(3, _portfolio()),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // BOTTOM ACTIONS
            // ==================================================
            _bottomActions(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORM WRAPPER
  // ============================================================

  Widget _form(int index, Widget child) {
    return Form(
      key: _formKeys[index],

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),

        child: child,
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _title(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(subtitle, style: const TextStyle(color: Color(0xFFB0B6C4))),
        ],
      ),
    );
  }

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  Widget _basicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _title('Basic information', 'Tell casting teams about yourself.'),

        _text(_fullName, 'Full name', required: true),

        _text(_stageName, 'Stage name (optional)'),

        _text(
          _phone,
          'Mobile number',
          required: true,
          keyboard: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) {
            final requiredError = _required(v, 'Mobile number');

            if (requiredError != null) {
              return requiredError;
            }

            final digits = v!.replaceAll(RegExp(r'[^0-9]'), '').trim();

            if (digits.length != 10) {
              return 'Phone number must be exactly 10 digits';
            }

            return null;
          },
        ),

        _text(
          _email,
          'Email address',
          required: true,
          keyboard: TextInputType.emailAddress,
          validator: (v) {
            final requiredError = _required(v, 'Email address');

            if (requiredError != null) {
              return requiredError;
            }

            final clean = v!.trim().toLowerCase();
            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

            if (!emailRegex.hasMatch(clean)) {
              return 'Email must be a valid @gmail.com address';
            }

            return null;
          },
        ),

        _text(
          _password,
          'Password',
          required: true,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (v) {
            final requiredError = _required(v, 'Password');

            if (requiredError != null) {
              return requiredError;
            }

            if (v!.length < 8) {
              return 'Password must be at least 8 characters';
            }

            return null;
          },
        ),

        _dateField(),

        _choice(
          'Gender',
          ['Male', 'Female', 'Other', 'Prefer not to say'],
          _gender,
          (v) {
            setState(() {
              _gender = v;
            });
          },
          required: true,
        ),

        _dropdown(
          'Country',
          LocationData.statesByCountry.keys.toList(),
          _country,
          (v) {
            setState(() {
              _country = v;
              // Reset state and city when country changes
              _state = null;
              _city = null;
            });
          },
          required: true,
        ),

        _dropdown(
          'State',
          _country != null ? (LocationData.statesByCountry[_country] ?? ['Other']) : [],
          _state,
          _country != null ? (v) {
            setState(() {
              _state = v;
              // Reset city when state changes
              _city = null;
            });
          } : null,
          required: true,
        ),

        _dropdown(
          'City',
          _state != null ? (LocationData.citiesByState[_state] ?? ['Other']) : [],
          _city,
          _state != null ? (v) {
            setState(() {
              _city = v;
            });
          } : null,
          required: true,
        ),

        _upload(
          'Profile photo (optional)',
          Icons.person_outline,
          fieldKey: _kProfilePhoto,
          fileType: _typeImage,
        ),
      ],
    );
  }

  // ============================================================
  // PROFESSIONAL PROFILE
  // ============================================================

  Widget _professionalProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _title('Professional profile', 'Show us the work you want to do.'),

        _choice(
          'Category',
          [
            'Actor',
            'Actress',
            'Child Artist',
            'Model',
            'Dancer',
            'Singer',
            'Influencer',
          ],
          _category,
          (v) {
            setState(() {
              _category = v;
            });
          },
          required: true,
        ),

        _choice(
          'Experience',
          ['Fresher', '1–2 Years', '3–5 Years', '5–10 Years', '10+ Years'],
          _experience,
          (v) {
            setState(() {
              _experience = v;
            });
          },
          required: true,
        ),

        _multi(
          'Skills',
          [
            'Acting',
            'Dancing',
            'Singing',
            'Modelling',
            'Martial Arts',
            'Comedy',
            'Mimicry',
          ],
          _skills,
          required: true,
        ),

        _multi(
          'Languages known',
          [
            'English',
            'Hindi',
            'Telugu',
            'Tamil',
            'Kannada',
            'Malayalam',
            'Marathi',
            'Bengali',
          ],
          _languages,
          required: true,
        ),

        _multi('Preferred acting language', [
          'English',
          'Hindi',
          'Telugu',
          'Tamil',
          'Kannada',
          'Malayalam',
        ], _actingLanguages),

        _dropdown(
          'Highest qualification',
          [
            '10th',
            'Intermediate',
            'Diploma',
            'Graduate',
            'Postgraduate',
            'Other',
          ],
          _qualification,
          (v) {
            setState(() {
              _qualification = v;
            });
          },
        ),

        _text(_institute, 'Acting institute (optional)'),

        _dropdown(
          'Current occupation',
          [
            'Full-Time Artist',
            'Student',
            'Employee',
            'Freelancer',
            'Business',
            'Other',
          ],
          _occupation,
          (v) {
            setState(() {
              _occupation = v;
            });
          },
        ),

        _multi('Available for', [
          'Movies',
          'OTT',
          'TV Serials',
          'Advertisements',
          'Music Videos',
          'Theatre',
          'Web Series',
        ], _availableFor),

        _switchTile('Union membership', _unionMember, (v) {
          setState(() {
            _unionMember = v;
          });
        }),

        _switchTile('Willing to relocate', _relocate, (v) {
          setState(() {
            _relocate = v;
          });
        }),
      ],
    );
  }

  // ============================================================
  // PERSONAL DETAILS
  // ============================================================

  Widget _personalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _title(
          'Personal & physical details',
          'These details help find the right fit.',
        ),

        _dropdown(
          'Height',
          List.generate(25, (i) => '${150 + i * 3} cm'),
          _height,
          (v) {
            setState(() {
              _height = v;
            });
          },
          required: true,
        ),

        _dropdown(
          'Weight',
          List.generate(25, (i) => '${30 + i * 5} kg'),
          _weight,
          (v) {
            setState(() {
              _weight = v;
            });
          },
          required: true,
        ),

        _dropdown(
          'Body type',
          ['Slim', 'Athletic', 'Average', 'Heavy', 'Muscular'],
          _bodyType,
          (v) {
            setState(() {
              _bodyType = v;
            });
          },
        ),

        _dropdown(
          'Skin tone',
          ['Very Fair', 'Fair', 'Wheatish', 'Brown', 'Dark'],
          _skinTone,
          (v) {
            setState(() {
              _skinTone = v;
            });
          },
        ),

        _dropdown(
          'Hair color',
          ['Black', 'Brown', 'Blonde', 'Grey', 'Red', 'Dyed'],
          _hairColor,
          (v) {
            setState(() {
              _hairColor = v;
            });
          },
        ),

        _dropdown(
          'Eye color',
          ['Black', 'Brown', 'Blue', 'Green', 'Hazel', 'Grey'],
          _eyeColor,
          (v) {
            setState(() {
              _eyeColor = v;
            });
          },
        ),

        _multi('Preferred role', [
          'Hero',
          'Heroine',
          'Villain',
          'Supporting Artist',
          'Character Artist',
          'Child Artist',
        ], _roles),

        _choice(
          'Travel availability',
          ['Anywhere', 'Within State', 'Within City', 'Not Willing'],
          _travelAvailability,
          (v) {
            setState(() {
              _travelAvailability = v;
            });
          },
        ),

        _switchTile('Available for night shoots', _nightShoots, (v) {
          setState(() {
            _nightShoots = v;
          });
        }),
      ],
    );
  }

  // ============================================================
  // PORTFOLIO
  // ============================================================

  Widget _portfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _title(
          'Portfolio & experience',
          'Add the material that represents your work.',
        ),

        _upload(
          'Headshot upload',
          Icons.add_a_photo_outlined,
          fieldKey: _kHeadshot,
          fileType: _typeImage,
        ),

        _upload(
          'Full body photo',
          Icons.photo_camera_back_outlined,
          fieldKey: _kFullBody,
          fileType: _typeImage,
        ),

        _upload(
          'Introduction video (30–60 seconds)',
          Icons.video_camera_back_outlined,
          fieldKey: _kIntroVideo,
          fileType: _typeVideo,
        ),

        _multi('Previous work', [
          'Movie',
          'TV Serial',
          'OTT',
          'Advertisement',
          'Theatre',
          'Short Film',
          'Music Video',
        ], _previousWork),

        _text(
          _instagram,
          'Instagram URL (optional)',
          keyboard: TextInputType.url,
        ),

        _text(_youtube, 'YouTube URL (optional)', keyboard: TextInputType.url),

        _text(_imdb, 'IMDb URL (optional)', keyboard: TextInputType.url),

        _text(
          _website,
          'Personal website (optional)',
          keyboard: TextInputType.url,
        ),

        _upload(
          'Resume upload (PDF, optional)',
          Icons.upload_file_outlined,
          fieldKey: _kResume,
          fileType: _typeFile,
        ),

        _text(_awards, 'Awards & achievements (optional)', maxLines: 3),

        _text(
          _bio,
          'Bio / About me (maximum 500 characters)',
          maxLines: 5,
          maxLength: 500,
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================

  Widget _bottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

      decoration: const BoxDecoration(
        color: Color(0xFF0B1F2A),

        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),

      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              onPressed: _isSubmitting ? null : _back,

              child: const Text('Back'),
            ),

            const SizedBox(width: 12),
          ],

          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2F5BEA),

                padding: const EdgeInsets.symmetric(vertical: 15),
              ),

              onPressed: _isSubmitting ? null : _next,

              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 3 ? 'Submit profile' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _text(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
    int maxLines = 1,
    int? maxLength,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextFormField(
        controller: controller,

        keyboardType: keyboard,

        maxLines: obscureText ? 1 : maxLines,

        maxLength: maxLength,

        obscureText: obscureText,

        inputFormatters: inputFormatters,

        style: const TextStyle(color: Colors.white),

        validator: validator ?? (required ? (v) => _required(v, label) : null),

        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',

          suffixIcon: suffixIcon,

          counterText: '',

          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?>? onChanged, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: DropdownButtonFormField<String>(
        value: value,

        isExpanded: true,

        validator: required ? (v) => _required(v, label) : null,

        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',

          border: const OutlineInputBorder(),
        ),

        items: items.isEmpty
            ? [DropdownMenuItem(value: null, child: const Text(''))]
            : items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),

        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // CHOICE
  // ============================================================

  Widget _choice(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String> onChanged, {
    bool required = false,
  }) {
    return FormField<String>(
      validator: required
          ? (v) => value == null ? 'Please select $label' : null
          : null,

      builder: (state) => Padding(
        padding: const EdgeInsets.only(bottom: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              '$label${required ? ' *' : ''}',

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: options.map((item) {
                return ChoiceChip(
                  label: Text(item),

                  selected: value == item,

                  selectedColor: _blue.withValues(alpha: 0.14),

                  onSelected: (_) {
                    onChanged(item);

                    state.didChange(item);
                  },
                );
              }).toList(),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),

                child: Text(
                  state.errorText!,

                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MULTI SELECT
  // ============================================================

  Widget _multi(
    String label,
    List<String> options,
    Set<String> selected, {
    bool required = false,
  }) {
    return FormField<bool>(
      validator: (_) =>
          required && selected.isEmpty ? 'Select at least one option' : null,

      builder: (state) => Padding(
        padding: const EdgeInsets.only(bottom: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              '$label${required ? ' *' : ''}',

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: options.map((item) {
                return FilterChip(
                  label: Text(item),

                  selected: selected.contains(item),

                  selectedColor: _blue.withValues(alpha: 0.14),

                  onSelected: (on) {
                    setState(() {
                      if (on) {
                        selected.add(item);
                      } else {
                        selected.remove(item);
                      }
                    });

                    state.didChange(selected.isNotEmpty);
                  },
                );
              }).toList(),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),

                child: Text(
                  state.errorText!,

                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,

      title: Text(label),

      subtitle: Text(value ? 'Yes' : 'No'),

      value: value,

      activeColor: _blue,

      onChanged: onChanged,
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: FormField<DateTime>(
        validator: (v) => _dob == null ? 'Date of birth is required' : null,

        builder: (state) => InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,

              firstDate: DateTime(1940),

              lastDate: DateTime.now(),

              initialDate: DateTime(2000),
            );

            if (picked != null) {
              setState(() {
                _dob = picked;
              });

              state.didChange(picked);
            }
          },

          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of birth *',

              errorText: state.errorText,

              border: const OutlineInputBorder(),
            ),

            child: Text(
              _dob == null
                  ? 'Select date'
                  : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD BUTTON
  // Mirrors the pattern in upload_photo_screen / upload_video_screen:
  //   1. Pick file locally with image_picker / file_picker
  //   2. POST multipart/form-data to backend via DioClient
  //   3. Store returned URL string
  // ============================================================

  // Field type enum (image / video / file)
  static const _typeImage = 'image';
  static const _typeVideo = 'video';
  static const _typeFile  = 'file';

  Widget _upload(
    String label,
    IconData icon, {
    required String fieldKey,
    required String fileType, // _typeImage / _typeVideo / _typeFile
  }) {
    final isUploading = _uploading[fieldKey] == true;
    final selectedFile = _selectedFiles[fieldKey];
    final uploadedUrl  = _uploadUrls[fieldKey];

    final hasUploaded = uploadedUrl != null && uploadedUrl.isNotEmpty;
    final hasPicked   = selectedFile != null;

    // Display name: prefer the locally picked filename
    final displayName = hasPicked
        ? selectedFile.name
        : hasUploaded
            ? Uri.parse(uploadedUrl).pathSegments.lastOrNull ?? 'Uploaded'
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        decoration: BoxDecoration(
          border: Border.all(
            color: (hasUploaded || hasPicked)
                ? Colors.green.shade400
                : const Color(0xFF5E6472),
          ),

          borderRadius: BorderRadius.circular(8),
        ),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(8),

            onTap: isUploading
                ? null
                : () => _pickFile(fieldKey, fileType),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

              child: isUploading
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Text(
                            'Processing...',
                            style: TextStyle(color: Color(0xFFB0B6C4)),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          (hasUploaded || hasPicked)
                              ? Icons.check_circle_outline
                              : icon,
                          color: (hasUploaded || hasPicked)
                              ? Colors.green.shade400
                              : const Color(0xFFB0B6C4),
                          size: 22,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            displayName ?? label,
                            style: TextStyle(
                              color: (hasUploaded || hasPicked)
                                  ? Colors.green.shade300
                                  : const Color(0xFFB0B6C4),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        if (hasPicked || hasUploaded)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFiles.remove(fieldKey);
                                _selectedBytes.remove(fieldKey);
                                _uploadUrls.remove(fieldKey);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFB0B6C4),
                            ),
                          )
                        else
                          const Icon(
                            Icons.upload_rounded,
                            size: 18,
                            color: Color(0xFFB0B6C4),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STEP 1 — PICK FILE LOCALLY
  // ============================================================

  Future<void> _pickFile(String fieldKey, String fileType) async {
    try {
      XFile? picked;
      Uint8List? bytes;

      if (fileType == _typeImage) {
        picked = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (picked != null) {
          bytes = await picked.readAsBytes();
        }
      } else if (fileType == _typeVideo) {
        picked = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 10),
        );

        if (picked != null) {
          bytes = await picked.readAsBytes();
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          final f = result.files.first;
          picked = XFile(f.path ?? f.name, name: f.name);
          bytes  = f.bytes;
        }
      }

      if (picked == null) return;

      setState(() {
        _selectedFiles[fieldKey] = picked!;
        if (bytes != null) _selectedBytes[fieldKey] = bytes;
        _uploadUrls.remove(fieldKey);
      });
    } catch (e) {
      if (fileType == _typeImage) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            withData: true,
          );

          if (result != null && result.files.isNotEmpty) {
            final f = result.files.first;
            final xFile = XFile(f.path ?? f.name, name: f.name);
            final bytes = f.bytes;

            setState(() {
              _selectedFiles[fieldKey] = xFile;
              if (bytes != null) _selectedBytes[fieldKey] = bytes;
              _uploadUrls.remove(fieldKey);
            });
            return;
          }
        } catch (_) {}
       if (!mounted) return;

      final isChannelError = e.toString().contains('channel-error') ||
          e.toString().contains('MissingPluginException');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChannelError
                ? 'Please fully restart the app to enable the file picker.'
                : 'Could not pick file: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
}
