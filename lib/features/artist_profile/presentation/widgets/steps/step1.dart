import 'package:flutter/material.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/utils/location_data.dart';
import 'profile_form_data.dart';
import 'step_common_widgets.dart';

class Step1BasicInfo extends StatefulWidget {
  final ProfileFormData data;
  final VoidCallback onNext;
  final bool isSubmitting;

  const Step1BasicInfo({
    super.key,
    required this.data,
    required this.onNext,
    this.isSubmitting = false,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  final _formKey = GlobalKey<FormState>();

  List<String> get _countries => LocationData.getCountries();

  List<String> get _states {
    final country = widget.data.country;
    if (country == null || country.trim().isEmpty) {
      return const [];
    }
    final list = LocationData.getStatesForCountry(country);
    if (widget.data.state != null &&
        widget.data.state!.isNotEmpty &&
        !list.contains(widget.data.state)) {
      return [widget.data.state!, ...list];
    }
    return list;
  }

  List<String> get _cities {
    final state = widget.data.state;
    if (state == null || state.trim().isEmpty) {
      return const [];
    }
    final list = LocationData.getCitiesForState(state);
    if (widget.data.city != null &&
        widget.data.city!.isNotEmpty &&
        !list.contains(widget.data.city)) {
      return [widget.data.city!, ...list];
    }
    return list;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(2000, 1, 1);
    if (widget.data.dobYear != null &&
        widget.data.dobMonth != null &&
        widget.data.dobDay != null) {
      final y = int.tryParse(widget.data.dobYear!) ?? 2000;
      final m = int.tryParse(widget.data.dobMonth!) ?? 1;
      final d = int.tryParse(widget.data.dobDay!) ?? 1;
      initialDate = DateTime(y, m, d);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        final isDark = AppColors.isDark(context);
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        widget.data.dobDay = picked.day.toString().padLeft(2, '0');
        widget.data.dobMonth = picked.month.toString().padLeft(2, '0');
        widget.data.dobYear = picked.year.toString();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final borderColor =
        isDark ? Colors.white24 : const Color(0xFFD1D5DB);
    final subTextColor = AppColors.getTextSecondary(context);
    final textColor = AppColors.getText(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepSectionHeader(
            title: 'Basic Information',
            subtitle:
                'Let\'s start with your basic details. This helps us personalize your experience.',
          ),

          // Full Name
          const StepFieldLabel(title: 'Full Name'),
          StepTextField(
            controller: widget.data.fullNameController,
            hint: 'Enter Your Full Name',
          ),

          // Stage Name
          const StepFieldLabel(title: 'Stage Name'),
          StepTextField(
            controller: widget.data.stageNameController,
            hint: 'Enter Your Stage Name',
          ),

          // Mobile Number
          const StepFieldLabel(title: 'Mobile Number'),
          StepTextField(
            controller: widget.data.mobileController,
            hint: '+91 00000 00000',
            keyboardType: TextInputType.phone,
          ),

          // Email address
          const StepFieldLabel(title: 'Email address'),
          StepTextField(
            controller: widget.data.emailController,
            hint: 'Enter Your e mail',
            keyboardType: TextInputType.emailAddress,
          ),

          // Date of Birth
          const StepFieldLabel(title: 'Date of Birth'),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 9,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.data.dobDay ?? '00',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.data.dobDay != null
                                ? textColor
                                : subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 28, color: borderColor),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Month',
                          style: TextStyle(
                            fontSize: 9,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.data.dobMonth ?? '00',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.data.dobMonth != null
                                ? textColor
                                : subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 28, color: borderColor),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Year',
                          style: TextStyle(
                            fontSize: 9,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.data.dobYear ?? '0000',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.data.dobYear != null
                                ? textColor
                                : subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Gender
          const StepFieldLabel(title: 'Gender'),
          StepRadioItem(
            title: 'Male',
            isSelected: widget.data.gender == 'Male',
            onTap: () => setState(() => widget.data.gender = 'Male'),
          ),
          StepRadioItem(
            title: 'Female',
            isSelected: widget.data.gender == 'Female',
            onTap: () => setState(() => widget.data.gender = 'Female'),
          ),
          StepRadioItem(
            title: 'Others',
            isSelected: widget.data.gender == 'Others',
            onTap: () => setState(() => widget.data.gender = 'Others'),
          ),
          StepRadioItem(
            title: 'Prefer not to say',
            isSelected: widget.data.gender == 'Prefer not to say',
            onTap: () => setState(
                () => widget.data.gender = 'Prefer not to say'),
          ),

          // Country
          const StepFieldLabel(title: 'Country'),
          StepDropdown(
            hint: 'Select Country',
            value: widget.data.country,
            items: _countries,
            onChanged: (v) {
              setState(() {
                widget.data.country = v;
                final availableStates = LocationData.getStatesForCountry(v);
                if (widget.data.state != null &&
                    !availableStates.contains(widget.data.state)) {
                  widget.data.state = null;
                  widget.data.city = null;
                }
              });
            },
          ),

          // State
          const StepFieldLabel(title: 'State'),
          StepDropdown(
            hint: widget.data.country == null || widget.data.country!.isEmpty
                ? 'Select Country first'
                : 'Select State',
            value: widget.data.state,
            items: _states,
            onChanged: (v) {
              setState(() {
                widget.data.state = v;
                final availableCities = LocationData.getCitiesForState(v);
                if (widget.data.city != null &&
                    !availableCities.contains(widget.data.city)) {
                  widget.data.city = null;
                }
              });
            },
          ),

          // City
          const StepFieldLabel(title: 'City'),
          StepDropdown(
            hint: widget.data.state == null || widget.data.state!.isEmpty
                ? 'Select State first'
                : 'Select City',
            value: widget.data.city,
            items: _cities,
            onChanged: (v) => setState(() => widget.data.city = v),
          ),

          const SizedBox(height: 36),

          StepNavigationButtons(
            onNext: _submit,
            showPrevious: false,
            nextLabel: 'Next',
            isSubmitting: widget.isSubmitting,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
