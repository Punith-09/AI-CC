import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/models/register_request.dart';
import '../../data/repository/auth_repository.dart';
import '../widgets/signup_button.dart';
import '../widgets/signup_dropdown.dart';
import '../widgets/signup_header.dart';
import '../widgets/signup_textfield.dart';
import '../../../../core/utils/location_data.dart';

class AudienceSignUpScreen extends StatefulWidget {
  const AudienceSignUpScreen({super.key});

  @override
  State<AudienceSignUpScreen> createState() =>
      _AudienceSignUpScreenState();
}

class _AudienceSignUpScreenState extends State<AudienceSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? _gender;
  String? _country;
  String? _state;
  String? _city;

  bool _obscurePassword = true;
  bool _isSubmitting = false;



  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
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
      final dioClient = sl<DioClient>();
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

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isPhoneUnique = await _checkPhoneUnique(_phone.text.trim());
      if (!isPhoneUnique) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This phone number is already registered. Please use another number."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final authRepository = sl<AuthRepository>();

      final request = RegisterRequest(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
        role: 'audience',
        mobile: _phone.text.trim(),
        stageName: '',
        dob: '',
        gender: _gender ?? '',
        country: _country ?? '',
        state: _state ?? '',
        city: _city ?? '',
        profilePhoto: '',
        category: '',
        experience: '',
        skills: const [],
        languages: const [],
        preferredLanguage: const [],
        qualification: '',
        institute: '',
        occupation: '',
        availableFor: const [],
        union: 'No',
        relocate: 'No',
        height: 0,
        weight: 0,
        bodyType: '',
        skinTone: '',
        hairColor: '',
        eyeColor: '',
        preferredRole: const [],
        travelAvailability: '',
        nightShoots: 'No',
        headshot: '',
        fullBody: '',
        introVideo: '',
        previousWork: const [],
        instagram: '',
        youtube: '',
        imdb: '',
        website: '',
        resume: '',
        awards: '',
        bio: '',
      );

      final response = await authRepository.register(request);

      await LocalStorage.instance.recordRegisteredPhone(_phone.text.trim());


      if (response.token.isEmpty) {
        await authRepository.login(_email.text.trim(), _password.text);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Audience account created successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.isNotEmpty ? errorMsg : "Registration failed. Please try again."),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F5A6A),
            Color(0xFF123B4A),
            Color(0xFF0B1F2A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            "Audience Sign Up",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SignupHeader(
                title: "Audience Registration",
                subtitle: "Complete your audience profile",
                icon: Icons.person,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123B4A),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Basic Information",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          SignupTextField(
                            controller: _fullName,
                            label: "Full Name",
                            requiredField: true,
                          ),
                          SignupTextField(
                            controller: _email,
                            label: "Email",
                            keyboardType: TextInputType.emailAddress,
                            requiredField: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              final clean = value.trim().toLowerCase();
                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                              if (!emailRegex.hasMatch(clean)) {
                                return "Email must be a valid @gmail.com address";
                              }
                              return null;
                            },
                          ),
                          SignupTextField(
                            controller: _password,
                            label: "Password",
                            obscureText: _obscurePassword,
                            requiredField: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              return null;
                            },
                          ),
                          SignupTextField(
                            controller: _phone,
                            label: "Phone Number",
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            requiredField: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              final clean = value.replaceAll(RegExp(r'[^0-9]'), '').trim();
                              if (clean.length != 10) {
                                return "Phone number must be exactly 10 digits";
                              }
                              return null;
                            },
                          ),
                          SignupDropdown(
                            label: "Gender",
                            items: const [
                              "Male",
                              "Female",
                              "Other",
                            ],
                            value: _gender,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                          SignupDropdown(
                            label: "Country",
                            items: LocationData.statesByCountry.keys.toList(),
                            value: _country,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _country = value;
                                _state = null;
                                _city = null;
                              });
                            },
                          ),
                          SignupDropdown(
                            label: "State",
                            items: _country != null
                                ? (LocationData.statesByCountry[_country!] ?? ['Other'])
                                : [],
                            value: _state,
                            requiredField: true,
                            onChanged: _country != null ? (value) {
                              setState(() {
                                _state = value;
                                _city = null;
                              });
                            } : null,
                          ),
                          SignupDropdown(
                            label: "City",
                            items: _state != null
                                ? (LocationData.citiesByState[_state!] ?? ['Other'])
                                : [],
                            value: _city,
                            requiredField: true,
                            onChanged: _state != null ? (value) {
                              setState(() {
                                _city = value;
                              });
                            } : null,
                          ),
                          const SizedBox(height: 30),
                          SignupButton(
                            text: "Create Account",
                            isLoading: _isSubmitting,
                            onPressed: _createAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}