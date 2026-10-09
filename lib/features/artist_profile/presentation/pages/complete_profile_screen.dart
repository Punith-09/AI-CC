import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _stageNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  String? _dobDay;
  String? _dobMonth;
  String? _dobYear;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().currentProfile;

    _fullNameController = TextEditingController(text: profile?.name ?? '');
    _stageNameController = TextEditingController(text: profile?.stageName ?? '');
    _mobileController = TextEditingController(text: profile?.mobile ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');

    _selectedGender = (profile?.gender != null && profile!.gender.isNotEmpty) ? profile.gender : null;
    _selectedCountry = (profile?.country != null && profile!.country.isNotEmpty) ? profile.country : null;
    _selectedState = (profile?.state != null && profile!.state.isNotEmpty) ? profile.state : null;
    _selectedCity = (profile?.city != null && profile!.city.isNotEmpty) ? profile.city : null;

    if (profile?.dob != null && profile!.dob.isNotEmpty) {
      final parts = profile.dob.split('-');
      if (parts.length >= 3) {
        // assuming YYYY-MM-DD or DD-MM-YYYY, let's keep it simple
        _dobDay = parts[2].length == 2 ? parts[2] : parts[0];
        _dobMonth = parts[1];
        _dobYear = parts[0].length == 4 ? parts[0] : parts[2];
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _stageNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileAndNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    // In actual implementation, we might navigate to step 2. 
    // Here we save and go back.
    final provider = context.read<ProfileProvider>();
    
    String dob = '';
    if (_dobDay != null && _dobMonth != null && _dobYear != null) {
      dob = '$_dobYear-$_dobMonth-$_dobDay';
    }

    final data = {
      'fullName': _fullNameController.text.trim(),
      'stageName': _stageNameController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'dob': dob,
      'gender': _selectedGender ?? '',
      'country': _selectedCountry ?? '',
      'state': _selectedState ?? '',
      'city': _selectedCity ?? '',
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.push(AppRoutes.completeProfileStep2);
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

  Widget _buildLabel(String title, {bool isMandatory = false}) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
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

  Widget _buildOutlinedField({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.getTextSecondary(context).withValues(alpha: 0.3), width: 1),
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
          borderSide: BorderSide(color: AppColors.getTextSecondary(context).withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final textColor = AppColors.getText(context);
    final subTextColor = AppColors.getTextSecondary(context);
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
                            '0% Complete',
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
                            value: 0.0,
                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Step 1 of 5',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: Text(
                            'Basic Information',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Let\'s start with your basic details. This helps us personalize your experience.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildLabel('Full Name'),
                        _buildOutlinedField(
                          controller: _fullNameController,
                          hint: 'Enter Your Full Name',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                        ),

                        _buildLabel('Stage Name', isMandatory: true),
                        _buildOutlinedField(
                          controller: _stageNameController,
                          hint: 'Enter Your Stage Name',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your stage name' : null,
                        ),

                        _buildLabel('Mobile Number'),
                        _buildOutlinedField(
                          controller: _mobileController,
                          hint: '+91 00000 00000',
                          keyboardType: TextInputType.phone,
                        ),

                        _buildLabel('Email address', isMandatory: true),
                        _buildOutlinedField(
                          controller: _emailController,
                          hint: 'Enter Your e mail',
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your email' : null,
                        ),

                        _buildLabel('Date of Birth'),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDobDropdown('Date', '00', _dobDay, (v) => setState(() => _dobDay = v), List.generate(31, (i) => (i+1).toString().padLeft(2, '0'))),
                              Container(width: 1, height: 24, color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
                              _buildDobDropdown('Month', '00', _dobMonth, (v) => setState(() => _dobMonth = v), List.generate(12, (i) => (i+1).toString().padLeft(2, '0'))),
                              Container(width: 1, height: 24, color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
                              _buildDobDropdown('Year', '0000', _dobYear, (v) => setState(() => _dobYear = v), List.generate(100, (i) => (2024-i).toString())),
                            ],
                          ),
                        ),

                        _buildLabel('Gender'),
                        _buildGenderRadio('Male'),
                        _buildGenderRadio('Female'),
                        _buildGenderRadio('Others'),
                        _buildGenderRadio('Prefer not to say'),

                        _buildLabel('Country'),
                        _buildDropdown(
                          hint: 'Select Country',
                          value: _selectedCountry,
                          items: ['India', 'USA', 'UK', 'Australia', 'Canada'], 
                          onChanged: (val) => setState(() => _selectedCountry = val),
                        ),

                        _buildLabel('State'),
                        _buildDropdown(
                          hint: 'Select State',
                          value: _selectedState,
                          items: ['Telangana', 'Maharashtra', 'Karnataka', 'Delhi', 'New York'], 
                          onChanged: (val) => setState(() => _selectedState = val),
                        ),

                        _buildLabel('City'),
                        _buildDropdown(
                          hint: 'Select City',
                          value: _selectedCity,
                          items: ['Hyderabad', 'Mumbai', 'Bangalore', 'New Delhi'], 
                          onChanged: (val) => setState(() => _selectedCity = val),
                        ),

                        const SizedBox(height: 36),

                        SizedBox(
                          width: double.infinity,
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDobDropdown(String label, String hint, String? value, void Function(String?) onChanged, List<String> items) {
    final textColor = AppColors.getText(context);
    final subTextColor = AppColors.getTextSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Flexible(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(label, style: TextStyle(fontSize: 8, color: subTextColor)),
               Text(hint, style: TextStyle(color: subTextColor, fontSize: 14)),
            ],
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)))).toList(),
          onChanged: onChanged,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          icon: const SizedBox.shrink(),
          isExpanded: true,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildGenderRadio(String title) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = title),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedGender == title ? const Color(0xFFF19E39) : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: _selectedGender == title
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
}
