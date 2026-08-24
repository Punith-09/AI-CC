import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _experienceController;
  late TextEditingController _languagesController;

  // Mock social links controllers to match UI visually
  final _instagramController = TextEditingController(text: 'https://instagram.com/yourprofile');
  final _youtubeController = TextEditingController(text: 'https://youtube.com/yourchannel');
  final _facebookController = TextEditingController(text: 'https://facebook.com/yourprofile');
  final _twitterController = TextEditingController(text: 'https://twitter.com/yourprofile');

  // Languages data
  List<String> languages = ['Telugu', 'English', 'Hindi'];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().currentProfile;
    
    _nameController = TextEditingController(text: profile?.name ?? 'Lokesh Gapagari');
    _cityController = TextEditingController(text: profile?.city ?? 'Hyderabad');
    _stateController = TextEditingController(text: profile?.state ?? 'Telangana');
    _experienceController = TextEditingController(text: profile?.experience ?? '2 Years');
    _languagesController = TextEditingController(text: profile?.languages ?? 'Telugu, English, Hindi');

    if (profile?.languages != null && profile!.languages!.isNotEmpty) {
      languages = profile.languages!.split(',').map((e) => e.trim()).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<ProfileProvider>();
    
    _languagesController.text = languages.join(', ');

    final data = {
      'fullName': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'experience': _experienceController.text.trim(),
      'languages': _languagesController.text.trim(),
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

  Widget _buildSectionLabel(IconData icon, String title, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.textField,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isOptional) ...[
            const SizedBox(width: 8),
            const Text(
              '(Optional)',
              style: TextStyle(
                color: AppColors.hint,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {Widget? prefixIcon, Widget? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.BtnGradient),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10.5),
        ),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialPrefix(IconData icon, List<Color> gradientColors) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Icon(icon, color: AppColors.white, size: 16)),
    );
  }

  Widget _buildLanguageChip(String lang) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.BtnGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang, style: const TextStyle(color: AppColors.white, fontSize: 13)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                setState(() => languages.remove(lang));
              },
              child: const Icon(Icons.close, color: AppColors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar Section
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(colors: AppColors.BtnGradient),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 54,
                                      backgroundColor: AppColors.textField,
                                      // Defaulting to network mock image for visual consistency with screenshot
                                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), 
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: AppColors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: AppColors.BtnGradient,
                                ).createShader(bounds),
                                child: const Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        _buildSectionLabel(Icons.person_outline, 'Full Name'),
                        _buildTextField(_nameController),

                        _buildSectionLabel(Icons.domain, 'City'),
                        _buildTextField(_cityController),

                        _buildSectionLabel(Icons.location_on_outlined, 'State'),
                        _buildTextField(
                          _stateController,
                          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 20),
                        ),

                        _buildSectionLabel(Icons.work_outline, 'Experience'),
                        _buildTextField(_experienceController),

                        _buildSectionLabel(Icons.language, 'Languages Known'),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...languages.map((lang) => _buildLanguageChip(lang)),
                            DottedBorder(
                              color: AppColors.purple,
                              strokeWidth: 1.5,
                              dashPattern: const [6, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add, color: AppColors.purple, size: 16),
                                    const SizedBox(width: 4),
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: AppColors.BtnGradient,
                                      ).createShader(bounds),
                                      child: const Text('Add Language', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        _buildSectionLabel(Icons.emoji_events_outlined, 'Awards & Achievements'),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.BtnGradient),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10.5),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Best Performer Award - 2024', style: TextStyle(color: AppColors.white, fontSize: 13, height: 2.2)),
                                Text('Best Supporting Artist - 2023', style: TextStyle(color: AppColors.white, fontSize: 13, height: 2.2)),
                                Text('State Level Drama Competition Winner - 2022', style: TextStyle(color: AppColors.white, fontSize: 13, height: 2.2)),
                                Text('Youth Cultural Excellence Award - 2021', style: TextStyle(color: AppColors.white, fontSize: 13, height: 2.2)),
                              ],
                            ),
                          ),
                        ),

                        _buildSectionLabel(Icons.link, 'Social Links', isOptional: true),
                        _buildTextField(
                          _instagramController,
                          prefixIcon: _buildSocialPrefix(FontAwesomeIcons.instagram, [AppColors.warning, AppColors.pink, AppColors.purple]),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _youtubeController,
                          prefixIcon: _buildSocialPrefix(FontAwesomeIcons.youtube, [AppColors.danger, AppColors.danger]),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _facebookController,
                          prefixIcon: _buildSocialPrefix(FontAwesomeIcons.facebookF, [AppColors.primary, AppColors.primary]),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _twitterController,
                          prefixIcon: _buildSocialPrefix(FontAwesomeIcons.twitter, [AppColors.primary, AppColors.primary]),
                        ),

                        const SizedBox(height: 32),
                        Container(
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
