import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';

class CompleteProfileStep2Screen extends StatefulWidget {
  const CompleteProfileStep2Screen({super.key});

  @override
  State<CompleteProfileStep2Screen> createState() => _CompleteProfileStep2ScreenState();
}

class _CompleteProfileStep2ScreenState extends State<CompleteProfileStep2Screen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  String? _selectedExperience;
  final List<String> _selectedSkills = [];
  final List<String> _selectedLanguages = [];
  final List<String> _selectedPreferredLanguages = [];
  
  String? _selectedQualification;
  late TextEditingController _actingInstituteController;
  String? _selectedOccupation;
  final List<String> _selectedAvailableFor = [];
  
  String? _unionMembership;
  String? _willingToRelocate;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().currentProfile;

    if (profile?.roles != null && profile!.roles.isNotEmpty) {
      _selectedCategory = profile.roles.first;
    }
    _selectedExperience = (profile?.experience != null && profile!.experience.isNotEmpty) ? profile.experience : null;

    if (profile?.skills != null) {
      _selectedSkills.addAll(profile!.skills);
    }
    
    // languages might be a string like "English, Telugu"
    if (profile?.languages != null && profile!.languages.isNotEmpty) {
      final langs = profile.languages.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      _selectedLanguages.addAll(langs);
    }

    if (profile?.preferredLanguages != null) {
      _selectedPreferredLanguages.addAll(profile!.preferredLanguages);
    }

    _actingInstituteController = TextEditingController();
  }

  @override
  void dispose() {
    _actingInstituteController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileAndNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<ProfileProvider>();
    
    final data = <String, dynamic>{
      if (_selectedCategory != null) 'roles': [_selectedCategory!],
      if (_selectedExperience != null) 'experience': _selectedExperience,
      'skills': _selectedSkills,
      'languages': _selectedLanguages.join(', '),
      'preferredLanguage': _selectedPreferredLanguages,
      'highestQualification': _selectedQualification ?? '',
      'actingInstitute': _actingInstituteController.text.trim(),
      'currentOccupation': _selectedOccupation ?? '',
      'availableFor': _selectedAvailableFor,
      'unionMembership': _unionMembership ?? '',
      'willingToRelocate': _willingToRelocate ?? '',
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional Profile saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // For now, since there's no step 3 developed yet, we can pop back to profile
      // or if there's a step 3, navigate to it. Let's just pop for now or mock step 3.
      context.push(AppRoutes.completeProfileStep3);
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

  Widget _buildSectionTitle(String title, {bool isMandatory = false}) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (isMandatory)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, String? groupValue, void Function(String) onChanged) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => onChanged(title),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: groupValue == title ? const Color(0xFFF19E39) : AppColors.getTextSecondary(context).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: groupValue == title
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF19E39),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title, List<String> list) {
    final textColor = AppColors.getText(context);
    final isSelected = list.contains(title);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              list.remove(title);
            } else {
              list.add(title);
            }
          });
        },
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xFFF19E39) : AppColors.getTextSecondary(context).withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFF19E39) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final textColor = AppColors.getText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)))).toList(),
      onChanged: onChanged,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: textColor, fontSize: 14),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.getTextSecondary(context).withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildOutlinedField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.getTextSecondary(context).withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final textColor = AppColors.getText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        actions: [
            IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => context.pop(),
            )
        ],
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
                        Center(
                          child: Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Center(
                          child: Text(
                            '20% Complete',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.2, // 20%
                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Step 2 of 5',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: Text(
                            'Professional Profile',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Category
                        _buildSectionTitle('Category'),
                        ...['Actor', 'Actress', 'Child Artist', 'Model', 'Singer', 'Influencer', 'Voice Artist', 'Anchor', 'Theatre Artist', 'Musician', 'Comedian', 'Other']
                            .map((cat) => _buildRadioOption(cat, _selectedCategory, (v) => setState(() => _selectedCategory = v))),

                        // Experience
                        _buildSectionTitle('Experience'),
                        ...['Fresher', '1-2 Years', '3-5 Years', '5-10 Years', '10+ Years']
                            .map((exp) => _buildRadioOption(exp, _selectedExperience, (v) => setState(() => _selectedExperience = v))),

                        // Skills
                        _buildSectionTitle('Skills'),
                        ...['Acting', 'Dancing', 'Singing', 'Modelling', 'Martial Arts', 'Comedy', 'Mimicry', 'Gym', 'Swimming', 'Driving', 'Speaking', 'Script Reading', 'Other']
                            .map((skill) => _buildCheckboxOption(skill, _selectedSkills)),

                        // Languages Known
                        _buildSectionTitle('Languages Known'),
                        ...['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada', 'Malayalam', 'Marathi', 'Bengali', 'Punjabi', 'Gujarati', 'Others']
                            .map((lang) => _buildCheckboxOption(lang, _selectedLanguages)),

                        // Preferred Acting Language
                        _buildSectionTitle('Preferred Acting Language'),
                        ...['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada', 'Malayalam', 'Marathi', 'Bengali', 'Punjabi', 'Gujarati', 'Others']
                            .map((lang) => _buildCheckboxOption(lang, _selectedPreferredLanguages)),

                        // Highest Qualification
                        _buildSectionTitle('Highest Qualification'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _selectedQualification,
                          items: ['High School', 'Bachelor\'s Degree', 'Master\'s Degree', 'Diploma', 'Other'],
                          onChanged: (v) => setState(() => _selectedQualification = v),
                        ),

                        // Acting Institute
                        _buildSectionTitle('Acting Institute', isMandatory: true),
                        _buildOutlinedField(
                          controller: _actingInstituteController,
                          hint: 'Enter Institute Name', // The mockup says "Enter Your Stage Name", we corrected it contextually
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter institute' : null,
                        ),

                        // Current Occupation
                        _buildSectionTitle('Current Occupation'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _selectedOccupation,
                          items: ['Student', 'Employed', 'Self-employed', 'Freelancer', 'Unemployed'],
                          onChanged: (v) => setState(() => _selectedOccupation = v),
                        ),

                        // Available For
                        _buildSectionTitle('Available For'),
                        ...['Movies', 'OTT', 'TV Serials', 'Advertisements', 'Music Videos', 'Theatre', 'Web Series', 'Reality Shows']
                            .map((av) => _buildCheckboxOption(av, _selectedAvailableFor)),

                        // Union Membership
                        _buildSectionTitle('Union Membership'),
                        Row(
                          children: [
                            _buildRadioOption('Yes', _unionMembership, (v) => setState(() => _unionMembership = v)),
                            const SizedBox(width: 32),
                            _buildRadioOption('No', _unionMembership, (v) => setState(() => _unionMembership = v)),
                          ],
                        ),

                        // Willing to Relocate
                        _buildSectionTitle('Willing to Relocate'),
                        Row(
                          children: [
                            _buildRadioOption('Yes', _willingToRelocate, (v) => setState(() => _willingToRelocate = v)),
                            const SizedBox(width: 32),
                            _buildRadioOption('No', _willingToRelocate, (v) => setState(() => _willingToRelocate = v)),
                          ],
                        ),

                        const SizedBox(height: 36),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1D3B5), 
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  context.pop();
                                },
                                child: const Text(
                                  'Pervious', // Matching the mockup spelling text
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1D3B5), 
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _saveProfileAndNext,
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
