import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';

class CompleteProfileStep3Screen extends StatefulWidget {
  const CompleteProfileStep3Screen({super.key});

  @override
  State<CompleteProfileStep3Screen> createState() => _CompleteProfileStep3ScreenState();
}

class _CompleteProfileStep3ScreenState extends State<CompleteProfileStep3Screen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String? _bodyType;
  String? _skinType;
  String? _hairColour;
  String? _eyeColour;

  final List<String> _preferredRoles = [];
  String? _travelAvailability;
  String? _nightShoots;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileAndNext() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();

    final data = <String, dynamic>{
      'height': _heightController.text.trim(),
      'weight': _weightController.text.trim(),
      if (_bodyType != null) 'bodyType': _bodyType,
      if (_skinType != null) 'skinType': _skinType,
      if (_hairColour != null) 'hairColour': _hairColour,
      if (_eyeColour != null) 'eyeColour': _eyeColour,
      'preferredRoles': _preferredRoles,
      if (_travelAvailability != null) 'travelAvailability': _travelAvailability,
      if (_nightShoots != null) 'availableForNightShoots': _nightShoots,
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal Details saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.push(AppRoutes.completeProfileStep4);
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

  Widget _buildOutlinedField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            width: 1,
          ),
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
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(color: textColor)),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: textColor, fontSize: 14),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.getTextSecondary(context),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    String title,
    String? groupValue,
    void Function(String) onChanged,
  ) {
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
                  color: groupValue == title
                      ? const Color(0xFFF19E39)
                      : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
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
              style: TextStyle(color: textColor, fontSize: 14),
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
                  color: isSelected
                      ? const Color(0xFFF19E39)
                      : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
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
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ],
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
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
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
                            '40% Complete',
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
                            value: 0.4,
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Step 3 of 5',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'Personal & Physical Details',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Height
                        _buildLabel('Height'),
                        _buildOutlinedField(
                          controller: _heightController,
                          hint: "e.g. 5'8\" or 173 cm",
                          keyboardType: TextInputType.text,
                        ),

                        // Weight
                        _buildLabel('Weight'),
                        _buildOutlinedField(
                          controller: _weightController,
                          hint: 'e.g. 65 kg',
                          keyboardType: TextInputType.text,
                        ),

                        // Body Type
                        _buildLabel('Body Type'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _bodyType,
                          items: [
                            'Athletic',
                            'Average',
                            'Muscular',
                            'Slim',
                            'Curvy',
                            'Plus Size'
                          ],
                          onChanged: (v) => setState(() => _bodyType = v),
                        ),

                        // Skin Type
                        _buildLabel('Skin Type'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _skinType,
                          items: [
                            'Fair',
                            'Medium',
                            'Olive',
                            'Brown',
                            'Dark',
                            'Very Dark'
                          ],
                          onChanged: (v) => setState(() => _skinType = v),
                        ),

                        // Hair Colour
                        _buildLabel('Hair Colour'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _hairColour,
                          items: [
                            'Black',
                            'Blonde',
                            'Brown',
                            'Red',
                            'Grey',
                            'White',
                            'Other'
                          ],
                          onChanged: (v) => setState(() => _hairColour = v),
                        ),

                        // Eye Colour
                        _buildLabel('Eye Colour'),
                        _buildDropdown(
                          hint: 'Select',
                          value: _eyeColour,
                          items: [
                            'Black',
                            'Brown',
                            'Blue',
                            'Green',
                            'Hazel',
                            'Grey',
                            'Other'
                          ],
                          onChanged: (v) => setState(() => _eyeColour = v),
                        ),

                        // Preferred Role
                        _buildLabel('Preferred Role'),
                        ...[
                          'Hero',
                          'Heroine',
                          'Villain',
                          'Supporting Artist',
                          'Character Artist',
                          'Model',
                          'Anchor',
                          'Background Artist',
                          'Child Artist',
                        ].map((role) =>
                            _buildCheckboxOption(role, _preferredRoles)),

                        // Travel Availability
                        _buildLabel('Travel Availability'),
                        ...[
                          'Anywhere',
                          'Within State',
                          'Within City',
                          'Not Willing',
                        ].map((ta) => _buildRadioOption(
                              ta,
                              _travelAvailability,
                              (v) => setState(() => _travelAvailability = v),
                            )),

                        // Available For Night Shoots
                        _buildLabel('Available For Night Shoots'),
                        Row(
                          children: [
                            _buildRadioOption(
                              'Yes',
                              _nightShoots,
                              (v) => setState(() => _nightShoots = v),
                            ),
                            const SizedBox(width: 32),
                            _buildRadioOption(
                              'No',
                              _nightShoots,
                              (v) => setState(() => _nightShoots = v),
                            ),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => context.pop(),
                                child: const Text(
                                  'Previous',
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
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
