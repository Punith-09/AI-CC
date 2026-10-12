import 'package:flutter/material.dart';
import 'profile_form_data.dart';
import 'step_common_widgets.dart';

class Step3PersonalPhysical extends StatefulWidget {
  final ProfileFormData data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isSubmitting;

  const Step3PersonalPhysical({
    super.key,
    required this.data,
    required this.onNext,
    required this.onPrevious,
    this.isSubmitting = false,
  });

  @override
  State<Step3PersonalPhysical> createState() =>
      _Step3PersonalPhysicalState();
}

class _Step3PersonalPhysicalState
    extends State<Step3PersonalPhysical> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _bodyTypes = [
    'Slim',
    'Athletic',
    'Average',
    'Muscular',
    'Heavy',
  ];

  final List<String> _skinTones = [
    'Fair',
    'Wheatish',
    'Dusky',
    'Dark',
  ];

  final List<String> _hairColors = [
    'Black',
    'Brown',
    'Blonde',
    'Grey',
    'Red',
    'Other',
  ];

  final List<String> _eyeColors = [
    'Black',
    'Brown',
    'Hazel',
    'Blue',
    'Green',
    'Grey',
    'Other',
  ];

  final List<String> _preferredRolesList = [
    'Hero',
    'Heroine',
    'Villain',
    'Supporting Artist',
    'Character Artist',
    'Model',
    'Anchor',
    'Background Artist',
    'Child Artist',
  ];

  final List<String> _travelOptions = [
    'Anywhere',
    'Within State',
    'Within City',
    'Not Willing',
  ];

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepSectionHeader(
            title: 'Personal & Physical Details',
          ),

          // ── Height ────────────────────────────────────────
          const StepFieldLabel(title: 'Height'),
          StepTextField(
            controller: widget.data.heightController,
            hint: 'Enter Height (e.g. 5\'10" or 178 cm)',
          ),

          // ── Weight ────────────────────────────────────────
          const StepFieldLabel(title: 'Weight', topPadding: 18),
          StepTextField(
            controller: widget.data.weightController,
            hint: 'Enter Weight (e.g. 68 kg)',
          ),

          // ── Body Type ─────────────────────────────────────
          const StepFieldLabel(title: 'Body Type', topPadding: 18),
          StepDropdown(
            hint: 'Select',
            value: widget.data.bodyType,
            items: _bodyTypes,
            onChanged: (v) => setState(() => widget.data.bodyType = v),
          ),

          // ── Skin Type / Tone ──────────────────────────────
          const StepFieldLabel(title: 'Skin Type', topPadding: 18),
          StepDropdown(
            hint: 'Select',
            value: widget.data.skinTone,
            items: _skinTones,
            onChanged: (v) => setState(() => widget.data.skinTone = v),
          ),

          // ── Hair Colour ───────────────────────────────────
          const StepFieldLabel(title: 'Hair Colour', topPadding: 18),
          StepDropdown(
            hint: 'Select',
            value: widget.data.hairColor,
            items: _hairColors,
            onChanged: (v) => setState(() => widget.data.hairColor = v),
          ),

          // ── Eye Colour ────────────────────────────────────
          const StepFieldLabel(title: 'Eye Colour', topPadding: 18),
          StepDropdown(
            hint: 'Select',
            value: widget.data.eyeColor,
            items: _eyeColors,
            onChanged: (v) => setState(() => widget.data.eyeColor = v),
          ),

          // ── Preferred Role ────────────────────────────────
          const StepFieldLabel(title: 'Preferred Role', topPadding: 24),
          ..._preferredRolesList.map(
            (r) => StepCheckboxItem(
              title: r,
              isSelected: widget.data.preferredRoles.contains(r),
              onTap: () {
                setState(() {
                  if (widget.data.preferredRoles.contains(r)) {
                    widget.data.preferredRoles.remove(r);
                  } else {
                    widget.data.preferredRoles.add(r);
                  }
                });
              },
            ),
          ),

          // ── Travel Availability ───────────────────────────
          const StepFieldLabel(
              title: 'Travel Availability', topPadding: 24),
          ..._travelOptions.map(
            (t) => StepRadioItem(
              title: t,
              isSelected: widget.data.travelAvailability == t,
              onTap: () =>
                  setState(() => widget.data.travelAvailability = t),
            ),
          ),

          // ── Available For Night Shoots ────────────────────
          const StepFieldLabel(
              title: 'Available For Night Shoots', topPadding: 20),
          Row(
            children: [
              Expanded(
                child: StepRadioItem(
                  title: 'Yes',
                  isSelected: widget.data.nightShoots == 'Yes',
                  onTap: () =>
                      setState(() => widget.data.nightShoots = 'Yes'),
                ),
              ),
              Expanded(
                child: StepRadioItem(
                  title: 'No',
                  isSelected: widget.data.nightShoots == 'No',
                  onTap: () =>
                      setState(() => widget.data.nightShoots = 'No'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          StepNavigationButtons(
            onNext: _submit,
            onPrevious: widget.onPrevious,
            prevLabel: 'Previous',
            nextLabel: 'Next',
            isSubmitting: widget.isSubmitting,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
