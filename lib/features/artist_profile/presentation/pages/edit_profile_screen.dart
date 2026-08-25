import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aicc/core/utils/location_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _experienceController;
  late TextEditingController _languagesController;
  int _awardsCount = 0;

  String? _country;
  String? _state;
  String? _city;



  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().currentProfile;
    
    _nameController = TextEditingController(text: profile?.name ?? 'Lokesh Gapagari');
    _state = profile?.state;
    _city = profile?.city;
    
    // Attempt to infer country based on state
    if (_state != null) {
      for (var entry in LocationData.statesByCountry.entries) {
        if (entry.value.contains(_state)) {
          _country = entry.key;
          break;
        }
      }
    }

    _experienceController = TextEditingController(text: profile?.experience ?? '2 Years');
    _languagesController = TextEditingController(text: profile?.languages ?? '');
    _awardsCount = profile?.awards ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    super.dispose();
  }



  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<ProfileProvider>();

    final data = {
      'fullName': _nameController.text.trim(),
      'country': _country ?? '',
      'city': _country != null && _state != null ? (_city ?? '') : '',
      'state': _country != null ? (_state ?? '') : '',
      'experience': _experienceController.text.trim(),
      'languages': _languagesController.text.trim(),
      'awards': _awardsCount,
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

  Widget _buildTextField(TextEditingController controller, {Widget? prefixIcon, Widget? suffixIcon, TextInputType? keyboardType}) {
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
          keyboardType: keyboardType,
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

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?>? onChanged,
  }) {
    List<String> effectiveItems = List.from(items);
    if (value != null && value.isNotEmpty && !effectiveItems.contains(value)) {
      effectiveItems.insert(0, value);
    }
    
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
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(hint, style: TextStyle(color: AppColors.white.withOpacity(0.5), fontSize: 14)),
            ),
            dropdownColor: AppColors.background,
            icon: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 20),
            ),
            items: effectiveItems.isEmpty
                ? [const DropdownMenuItem(value: null, child: Text(''))]
                : effectiveItems.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(item, style: const TextStyle(color: AppColors.white, fontSize: 14)),
                      ),
                    );
                  }).toList(),
            onChanged: onChanged,
          ),
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

                        _buildSectionLabel(Icons.domain, 'Country'),
                        _buildDropdown(
                          value: _country,
                          items: LocationData.statesByCountry.keys.toList(),
                          hint: 'Select Country',
                          onChanged: (v) {
                            setState(() {
                              _country = v;
                              _state = null;
                              _city = null;
                            });
                          },
                        ),

                        _buildSectionLabel(Icons.location_on_outlined, 'State'),
                        _buildDropdown(
                          value: _state,
                          items: _country != null ? (LocationData.statesByCountry[_country] ?? ['Other']) : [],
                          hint: _country != null ? 'Select State' : '',
                          onChanged: _country != null ? (v) {
                            setState(() {
                              _state = v;
                              _city = null;
                            });
                          } : null,
                        ),

                        _buildSectionLabel(Icons.location_city, 'City'),
                        _buildDropdown(
                          value: _city,
                          items: _state != null ? (LocationData.citiesByState[_state] ?? ['Other']) : [],
                          hint: _state != null ? 'Select City' : '',
                          onChanged: _state != null ? (v) {
                            setState(() {
                              _city = v;
                            });
                          } : null,
                        ),

                        _buildSectionLabel(Icons.work_outline, 'Experience'),
                        _buildTextField(_experienceController),

                        _buildSectionLabel(Icons.language, 'Languages Known'),
                        _buildTextField(_languagesController),

                        _buildSectionLabel(Icons.emoji_events_outlined, 'Awards Count'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Awards', style: TextStyle(color: AppColors.white, fontSize: 14)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: AppColors.white),
                                      onPressed: () {
                                        if (_awardsCount > 0) setState(() => _awardsCount--);
                                      },
                                    ),
                                    SizedBox(
                                      width: 30,
                                      child: Text(
                                        '$_awardsCount',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, color: AppColors.white),
                                      onPressed: () {
                                        setState(() => _awardsCount++);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
