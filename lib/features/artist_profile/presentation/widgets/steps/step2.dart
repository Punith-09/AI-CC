import 'package:flutter/material.dart';
import '../../../../../core/constants/craft_constants.dart';
import 'profile_form_data.dart';
import 'step_common_widgets.dart';

class Step2ProfessionalProfile extends StatefulWidget {
  final ProfileFormData data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isSubmitting;

  const Step2ProfessionalProfile({
    super.key,
    required this.data,
    required this.onNext,
    required this.onPrevious,
    this.isSubmitting = false,
  });

  @override
  State<Step2ProfessionalProfile> createState() =>
      _Step2ProfessionalProfileState();
}

class _Step2ProfessionalProfileState
    extends State<Step2ProfessionalProfile> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = [
    ...kFilmCrafts,
    'Other',
  ];

  final List<String> _experienceLevels = [
    'Fresher',
    '1-2 Years',
    '3-5 Years',
    '5-10 Years',
    '10+ Years',
  ];

  final List<String> _skillsList = [
    'Acting',
    'Dancing',
    'Singing',
    'Modelling',
    'Martial Arts',
    'Comedy',
    'Mimicry',
    'Gym',
    'Swimming',
    'Driving',
    'Speaking',
    'Script Reading',
    'Other',
  ];

  final List<String> _languagesList = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Bengali',
    'Punjabi',
    'Gujarati',
    'Others',
  ];

  final List<String> _qualifications = [
    'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Diploma in Acting',
    'Doctorate',
    'Other',
  ];

  final List<String> _occupations = [
    'Full-time Artist',
    'Student',
    'Freelancer',
    'Employed',
    'Self-employed',
    'Other',
  ];

  final List<String> _availableForList = [
    'Movies',
    'OTT',
    'TV Serials',
    'Advertisements',
    'Music Videos',
    'Theatre',
    'Web Series',
    'Reality Shows',
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
            title: 'Professional Profile',
          ),

          // ── Category ──────────────────────────────────────
          const StepFieldLabel(title: 'Category'),
          ..._categories.map(
            (c) => StepRadioItem(
              title: c,
              isSelected: widget.data.category == c,
              onTap: () => setState(() => widget.data.category = c),
            ),
          ),

          // ── Experience ────────────────────────────────────
          const StepFieldLabel(title: 'Experience', topPadding: 24),
          ..._experienceLevels.map(
            (e) => StepRadioItem(
              title: e,
              isSelected: widget.data.experience == e,
              onTap: () => setState(() => widget.data.experience = e),
            ),
          ),

          // ── Skills ────────────────────────────────────────
          const StepFieldLabel(title: 'Skills', topPadding: 24),
          ..._skillsList.map(
            (s) => StepCheckboxItem(
              title: s,
              isSelected: widget.data.skills.contains(s),
              onTap: () {
                setState(() {
                  if (widget.data.skills.contains(s)) {
                    widget.data.skills.remove(s);
                  } else {
                    widget.data.skills.add(s);
                  }
                });
              },
            ),
          ),

          // ── Languages Known ───────────────────────────────
          const StepFieldLabel(title: 'Languages Known', topPadding: 24),
          ..._languagesList.map(
            (l) => StepCheckboxItem(
              title: l,
              isSelected: widget.data.languages.contains(l),
              onTap: () {
                setState(() {
                  if (widget.data.languages.contains(l)) {
                    widget.data.languages.remove(l);
                  } else {
                    widget.data.languages.add(l);
                  }
                });
              },
            ),
          ),

          // ── Preferred Acting Language ─────────────────────
          const StepFieldLabel(
              title: 'Preferred Acting Language', topPadding: 24),
          ..._languagesList.map(
            (l) => StepCheckboxItem(
              title: l,
              isSelected: widget.data.preferredLanguages.contains(l),
              onTap: () {
                setState(() {
                  if (widget.data.preferredLanguages.contains(l)) {
                    widget.data.preferredLanguages.remove(l);
                  } else {
                    widget.data.preferredLanguages.add(l);
                  }
                });
              },
            ),
          ),

          // ── Highest Qualification ─────────────────────────
          const StepFieldLabel(
              title: 'Highest Qualification', topPadding: 24),
          StepDropdown(
            hint: 'Select',
            value: widget.data.qualification,
            items: _qualifications,
            onChanged: (v) =>
                setState(() => widget.data.qualification = v),
          ),

          // ── Acting Institute ─────────────────────────────
          const StepFieldLabel(
              title: 'Acting Institute', topPadding: 20),
          StepTextField(
            controller: widget.data.instituteController,
            hint: 'Enter Acting Institute',
          ),

          // ── Current Occupation ────────────────────────────
          const StepFieldLabel(
              title: 'Current Occupation', topPadding: 20),
          StepDropdown(
            hint: 'Select',
            value: widget.data.occupation,
            items: _occupations,
            onChanged: (v) =>
                setState(() => widget.data.occupation = v),
          ),

          // ── Available For ─────────────────────────────────
          const StepFieldLabel(title: 'Available For', topPadding: 24),
          ..._availableForList.map(
            (a) => StepCheckboxItem(
              title: a,
              isSelected: widget.data.availableFor.contains(a),
              onTap: () {
                setState(() {
                  if (widget.data.availableFor.contains(a)) {
                    widget.data.availableFor.remove(a);
                  } else {
                    widget.data.availableFor.add(a);
                  }
                });
              },
            ),
          ),

          // ── Union Membership ──────────────────────────────
          const StepFieldLabel(
              title: 'Union Membership', topPadding: 24),
          Row(
            children: [
              Expanded(
                child: StepRadioItem(
                  title: 'Yes',
                  isSelected: widget.data.union == 'Yes',
                  onTap: () => setState(() => widget.data.union = 'Yes'),
                ),
              ),
              Expanded(
                child: StepRadioItem(
                  title: 'No',
                  isSelected: widget.data.union == 'No',
                  onTap: () => setState(() => widget.data.union = 'No'),
                ),
              ),
            ],
          ),

          // ── Willing to Relocate ───────────────────────────
          const StepFieldLabel(
              title: 'Willing to Relocate', topPadding: 20),
          Row(
            children: [
              Expanded(
                child: StepRadioItem(
                  title: 'Yes',
                  isSelected: widget.data.relocate == 'Yes',
                  onTap: () =>
                      setState(() => widget.data.relocate = 'Yes'),
                ),
              ),
              Expanded(
                child: StepRadioItem(
                  title: 'No',
                  isSelected: widget.data.relocate == 'No',
                  onTap: () =>
                      setState(() => widget.data.relocate = 'No'),
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
