import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/api/api_endpoints.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _languagesController;
  late TextEditingController _qualificationController;

  String? _currentPhotoUrl;
  XFile? _selectedImage;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().currentProfile;

    // Split name into first name and surname
    final fullName = profile?.name ?? '';
    final nameParts = fullName.split(' ');
    _nameController = TextEditingController(text: nameParts.isNotEmpty ? nameParts[0] : '');
    _surnameController = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    _emailController = TextEditingController(text: profile?.email ?? '');
    _mobileController = TextEditingController(text: profile?.mobile ?? '');
    _stateController = TextEditingController(text: profile?.state ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _languagesController = TextEditingController(text: profile?.languages ?? '');
    _qualificationController = TextEditingController(text: profile?.experience ?? '');
    _currentPhotoUrl = profile?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _languagesController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _isUploadingPhoto = true;
      });

      try {
        final dioClient = GetIt.instance<DioClient>();
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          multipartFile = MultipartFile.fromBytes(bytes, filename: pickedFile.name);
        } else {
          multipartFile = await MultipartFile.fromFile(
            pickedFile.path,
            filename: pickedFile.name,
          );
        }
        final formData = FormData.fromMap({
          'file': multipartFile,
        });

        final photoRes = await dioClient.post(ApiEndpoints.mediaUpload, data: formData);

        String? photoUrl;
        if (photoRes.data is Map) {
          final map = Map<String, dynamic>.from(photoRes.data as Map);
          photoUrl = map['url'] as String? ??
              map['path'] as String? ??
              map['file'] as String? ??
              map['imageUrl'] as String? ??
              map['photoUrl'] as String? ??
              map['location'] as String? ??
              map['link'] as String? ??
              (map['data'] is Map
                  ? (map['data']['url'] ??
                          map['data']['path'] ??
                          map['data']['file'] ??
                          map['data']['imageUrl'] ??
                          map['data']['location'])
                      ?.toString()
                  : null);
        }

        if (photoUrl != null && photoUrl.isNotEmpty) {
          setState(() {
            _currentPhotoUrl = photoUrl;
          });
          context.read<ProfileProvider>().updateProfilePhotoLocally(photoUrl);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e'), backgroundColor: AppColors.danger),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingPhoto = false;
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final fullName = '${_nameController.text.trim()} ${_surnameController.text.trim()}'.trim();

    final data = {
      'fullName': fullName,
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'state': _stateController.text.trim(),
      'city': _cityController.text.trim(),
      'languages': _languagesController.text.trim(),
      'experience': _qualificationController.text.trim(),
      if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) ...{
        'profilePhoto': _currentPhotoUrl,
        'profile_image': _currentPhotoUrl,
        'profileImage': _currentPhotoUrl,
        'pic': _currentPhotoUrl,
        'avatar': _currentPhotoUrl,
      },
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // ─── Simple label above each field ─────────────────────────────
  Widget _buildLabel(String title) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── Underline-style text field matching the mockup ────────────
  Widget _buildUnderlineField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(color: textColor, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;

    final appBarTextColor = AppColors.getText(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: appBarTextColor),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: appBarTextColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile Photo ──────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickProfilePhoto,
                            child: _isUploadingPhoto
                                ? const CircleAvatar(
                                    radius: 48,
                                    backgroundColor: AppColors.textField,
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  )
                                : CircleAvatar(
                                    radius: 48,
                                    backgroundColor: AppColors.textField,
                                    backgroundImage: _selectedImage != null
                                        ? (kIsWeb
                                            ? NetworkImage(_selectedImage!.path)
                                            : FileImage(File(_selectedImage!.path))) as ImageProvider
                                        : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                                            ? NetworkImage(ApiEndpoints.formatMediaUrl(_currentPhotoUrl!))
                                            : null,
                                    child: (_selectedImage == null && (_currentPhotoUrl == null || _currentPhotoUrl!.isEmpty))
                                        ? Text(
                                            (_nameController.text.isNotEmpty ? _nameController.text[0] : 'U').toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Name ─────────────────────────────────
                        _buildLabel('Name'),
                        _buildUnderlineField(
                          controller: _nameController,
                          hint: 'Enter your Name',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                        ),

                        // ── Surname ──────────────────────────────
                        _buildLabel('Surname'),
                        _buildUnderlineField(
                          controller: _surnameController,
                          hint: 'Enter your Surname',
                        ),

                        // ── Email Id ─────────────────────────────
                        _buildLabel('Email Id'),
                        _buildUnderlineField(
                          controller: _emailController,
                          hint: 'Enter your mail',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        // ── Mobile Number ────────────────────────
                        _buildLabel('Mobile Number'),
                        _buildUnderlineField(
                          controller: _mobileController,
                          hint: '+91 89898 88989',
                          keyboardType: TextInputType.phone,
                        ),

                        // ── Present State ────────────────────────
                        _buildLabel('Present State'),
                        _buildUnderlineField(
                          controller: _stateController,
                          hint: 'Telangana',
                        ),

                        // ── Present City ─────────────────────────
                        _buildLabel('Present City'),
                        _buildUnderlineField(
                          controller: _cityController,
                          hint: 'Hyderabad',
                        ),

                        // ── Languages ────────────────────────────
                        _buildLabel('Languages'),
                        _buildUnderlineField(
                          controller: _languagesController,
                          hint: 'English, Telugu, Tamil',
                        ),

                        // ── Qualification ────────────────────────
                        _buildLabel('Qualification'),
                        _buildUnderlineField(
                          controller: _qualificationController,
                          hint: 'Btech',
                        ),

                        const SizedBox(height: 36),

                        // ── Save Changes Button ──────────────────
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.BtnGradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _saveProfile,
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
