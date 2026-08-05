import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../widgets/signup_step_header.dart';

class SignUpWizardPage extends StatefulWidget {
  const SignUpWizardPage({super.key});

  @override
  State<SignUpWizardPage> createState() => _SignUpWizardPageState();
}

class _SignUpWizardPageState extends State<SignUpWizardPage> {
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys =
      List.generate(4, (_) => GlobalKey<FormState>());
  int _currentStep = 0;

  final _fullName = TextEditingController();
  final _stageName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _institute = TextEditingController();
  final _instagram = TextEditingController();
  final _youtube = TextEditingController();
  final _imdb = TextEditingController();
  final _website = TextEditingController();
  final _awards = TextEditingController();
  final _bio = TextEditingController();

  String? _gender, _country, _state, _city;
  String? _category, _experience, _qualification, _occupation;
  String? _height, _weight, _bodyType, _skinTone, _hairColor, _eyeColor;
  String? _travelAvailability;
  bool _unionMember = false, _relocate = false, _nightShoots = false;
  final Set<String> _skills = {};
  final Set<String> _languages = {};
  final Set<String> _actingLanguages = {};
  final Set<String> _availableFor = {};
  final Set<String> _roles = {};

  static const _blue = Color(0xFF2F5BEA);
  static const _steps = [
    'Basic Information',
    'Professional Profile',
    'Personal Details',
    'Portfolio',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in [
      _fullName,
      _stageName,
      _phone,
      _email,
      _institute,
      _instagram,
      _youtube,
      _imdb,
      _website,
      _awards,
      _bio,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (!(_formKeys[_currentStep].currentState?.validate() ?? false)) return;
    if (_currentStep == _steps.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile submitted successfully!')),
      );
      return;
    }
    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  String? _required(String? value, [String label = 'This field']) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B1F2A),
        foregroundColor: Colors.white70,
        title: const Text(
          'Create your artist profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          SignUpStepHeader(currentStep: _currentStep),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF123B4A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(color: Color(0xFFC5C8D0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF5E6472))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _blue, width: 2)),
                  ),
                  dropdownMenuTheme: const DropdownMenuThemeData(
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _form(0, _basicInformation()),
                      _form(1, _professionalProfile()),
                      _form(2, _personalDetails()),
                      _form(3, _portfolio()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _bottomActions(),
        ]),
      ),
    );
  }

  Widget _form(int index, Widget child) => Form(
        key: _formKeys[index],
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: child,
        ),
      );

  Widget _title(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6C7484))),
        ]),
      );

  Widget _basicInformation() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Basic information', 'Tell casting teams about yourself.'),
          _text(_fullName, 'Full name', required: true),
          _text(_stageName, 'Stage name (optional)'),
          _text(_phone, 'Mobile number',
              required: true,
              keyboard: TextInputType.phone,
              validator: (v) =>
                  _required(v, 'Mobile number') ??
                  ((v?.replaceAll(RegExp(r'[^0-9]'), '').length ?? 0) < 10
                      ? 'Enter a valid mobile number'
                      : null)),
          _text(_email, 'Email address (optional)',
              keyboard: TextInputType.emailAddress),
          _dateField(),
          _choice('Gender', ['Male', 'Female', 'Other', 'Prefer not to say'],
              _gender, (v) => setState(() => _gender = v),
              required: true),
          _dropdown(
              'Country',
              ['India', 'United States', 'United Kingdom', 'Other'],
              _country,
              (v) => setState(() => _country = v),
              required: true),
          _dropdown(
              'State',
              [
                'Andhra Pradesh',
                'Karnataka',
                'Maharashtra',
                'Tamil Nadu',
                'Telangana',
                'Other'
              ],
              _state,
              (v) => setState(() => _state = v),
              required: true),
          _dropdown(
              'City',
              [
                'Bengaluru',
                'Chennai',
                'Hyderabad',
                'Mumbai',
                'New Delhi',
                'Other'
              ],
              _city,
              (v) => setState(() => _city = v),
              required: true),
          _upload('Profile photo (optional)', Icons.person_outline),
        ],
      );

  Widget _professionalProfile() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Professional profile', 'Show us the work you want to do.'),
          _choice(
              'Category',
              [
                'Actor',
                'Actress',
                'Child Artist',
                'Model',
                'Dancer',
                'Singer',
                'Influencer'
              ],
              _category,
              (v) => setState(() => _category = v),
              required: true),
          _choice('Experience',
              ['Fresher', '1–2 Years', '3–5 Years', '5–10 Years', '10+ Years'],
              _experience, (v) => setState(() => _experience = v),
              required: true),
          _multi(
              'Skills',
              [
                'Acting',
                'Dancing',
                'Singing',
                'Modelling',
                'Martial Arts',
                'Comedy',
                'Mimicry'
              ],
              _skills,
              required: true),
          _multi(
              'Languages known',
              [
                'English',
                'Hindi',
                'Telugu',
                'Tamil',
                'Kannada',
                'Malayalam',
                'Marathi',
                'Bengali'
              ],
              _languages,
              required: true),
          _multi(
              'Preferred acting language',
              [
                'English',
                'Hindi',
                'Telugu',
                'Tamil',
                'Kannada',
                'Malayalam'
              ],
              _actingLanguages),
          _dropdown(
              'Highest qualification',
              [
                '10th',
                'Intermediate',
                'Diploma',
                'Graduate',
                'Postgraduate',
                'Other'
              ],
              _qualification,
              (v) => setState(() => _qualification = v)),
          _text(_institute, 'Acting institute (optional)'),
          _dropdown(
              'Current occupation',
              [
                'Full-Time Artist',
                'Student',
                'Employee',
                'Freelancer',
                'Business',
                'Other'
              ],
              _occupation,
              (v) => setState(() => _occupation = v)),
          _multi(
              'Available for',
              [
                'Movies',
                'OTT',
                'TV Serials',
                'Advertisements',
                'Music Videos',
                'Theatre',
                'Web Series'
              ],
              _availableFor),
          _switchTile('Union membership', _unionMember,
              (v) => setState(() => _unionMember = v)),
          _switchTile('Willing to relocate', _relocate,
              (v) => setState(() => _relocate = v)),
        ],
      );

  Widget _personalDetails() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Personal & physical details',
              'These details help find the right fit.'),
          _dropdown(
              'Height',
              List.generate(25, (i) => '${150 + i * 3} cm'),
              _height,
              (v) => setState(() => _height = v),
              required: true),
          _dropdown(
              'Weight',
              List.generate(25, (i) => '${30 + i * 5} kg'),
              _weight,
              (v) => setState(() => _weight = v),
              required: true),
          _dropdown('Body type',
              ['Slim', 'Athletic', 'Average', 'Heavy', 'Muscular'], _bodyType,
              (v) => setState(() => _bodyType = v)),
          _dropdown('Skin tone',
              ['Very Fair', 'Fair', 'Wheatish', 'Brown', 'Dark'], _skinTone,
              (v) => setState(() => _skinTone = v)),
          _dropdown(
              'Hair color',
              ['Black', 'Brown', 'Blonde', 'Grey', 'Red', 'Dyed'],
              _hairColor,
              (v) => setState(() => _hairColor = v)),
          _dropdown(
              'Eye color',
              ['Black', 'Brown', 'Blue', 'Green', 'Hazel', 'Grey'],
              _eyeColor,
              (v) => setState(() => _eyeColor = v)),
          _multi(
              'Preferred role',
              [
                'Hero',
                'Heroine',
                'Villain',
                'Supporting Artist',
                'Character Artist',
                'Child Artist'
              ],
              _roles),
          _choice(
              'Travel availability',
              ['Anywhere', 'Within State', 'Within City', 'Not Willing'],
              _travelAvailability,
              (v) => setState(() => _travelAvailability = v)),
          _switchTile('Available for night shoots', _nightShoots,
              (v) => setState(() => _nightShoots = v)),
        ],
      );

  Widget _portfolio() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Portfolio & experience',
              'Add the material that represents your work.'),
          _upload('Headshot upload', Icons.add_a_photo_outlined),
          _upload('Full body photo', Icons.photo_camera_back_outlined),
          _upload('Introduction video (30–60 seconds)',
              Icons.video_camera_back_outlined),
          _multi(
              'Previous work',
              [
                'Movie',
                'TV Serial',
                'OTT',
                'Advertisement',
                'Theatre',
                'Short Film',
                'Music Video'
              ],
              _availableFor),
          _text(_instagram, 'Instagram URL (optional)',
              keyboard: TextInputType.url),
          _text(_youtube, 'YouTube URL (optional)',
              keyboard: TextInputType.url),
          _text(_imdb, 'IMDb URL (optional)', keyboard: TextInputType.url),
          _text(_website, 'Personal website (optional)',
              keyboard: TextInputType.url),
          _upload('Resume upload (PDF, optional)', Icons.upload_file_outlined),
          _text(_awards, 'Awards & achievements (optional)', maxLines: 3),
          _text(_bio, 'Bio / About me (maximum 500 characters)',
              maxLines: 5, maxLength: 500),
        ],
      );

  Widget _bottomActions() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
            color: Color(0xFF0B1F2A),
            boxShadow: [
              BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, -3))
            ]),
        child: Row(children: [
          if (_currentStep > 0) ...[
            OutlinedButton(onPressed: _back, child: const Text('Back')),
            const SizedBox(width: 12),
          ],
          Expanded(
              child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF123B4A),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: () {
              if (_currentStep == _steps.length - 1) {
                if (!(_formKeys[_currentStep].currentState?.validate() ??
                    false)) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile submitted successfully!'),
                  ),
                );

                Future.delayed(const Duration(milliseconds: 500), () {
                  context.go(AppRoutes.home);
                });
              } else {
                _next();
              }
            },
            child: Text(_currentStep == 3 ? 'Submit profile' : 'Continue'),
          )),
        ]),
      );

  Widget _text(TextEditingController controller, String label,
          {bool required = false,
          TextInputType? keyboard,
          int maxLines = 1,
          int? maxLength,
          String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            maxLength: maxLength,
            validator:
                validator ?? (required ? (v) => _required(v, label) : null),
            decoration: InputDecoration(
                labelText: '$label${required ? ' *' : ''}',
                border: const OutlineInputBorder())),
      );

  Widget _dropdown(String label, List<String> items, String? value,
          ValueChanged<String?> onChanged,
          {bool required = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            validator: required ? (v) => _required(v, label) : null,
            decoration: InputDecoration(
                labelText: '$label${required ? ' *' : ''}',
                border: const OutlineInputBorder()),
            items: items
                .map((item) =>
                    DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged),
      );

  Widget _choice(String label, List<String> options, String? value,
          ValueChanged<String> onChanged,
          {bool required = false}) =>
      FormField<String>(
        validator: required
            ? (v) => (value == null ? 'Please select $label' : null)
            : null,
        builder: (state) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$label${required ? ' *' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options
                    .map((item) => ChoiceChip(
                        label: Text(item),
                        selected: value == item,
                        selectedColor: _blue.withValues(alpha: 0.14),
                        onSelected: (_) {
                          onChanged(item);
                          state.didChange(item);
                        }))
                    .toList()),
            if (state.hasError)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
          ]),
        ),
      );

  Widget _multi(String label, List<String> options, Set<String> selected,
          {bool required = false}) =>
      FormField<bool>(
        validator: (_) =>
            required && selected.isEmpty ? 'Select at least one option' : null,
        builder: (state) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$label${required ? ' *' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options
                    .map((item) => FilterChip(
                        label: Text(item),
                        selected: selected.contains(item),
                        selectedColor: _blue.withValues(alpha: 0.14),
                        onSelected: (on) {
                          setState(() =>
                              on ? selected.add(item) : selected.remove(item));
                          state.didChange(selected.isNotEmpty);
                        }))
                    .toList()),
            if (state.hasError)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
          ]),
        ),
      );

  Widget _switchTile(
          String label, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: Text(value ? 'Yes' : 'No'),
          value: value,
          activeColor: _blue,
          onChanged: onChanged);

  Widget _dateField() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FormField<DateTime>(
          validator: (v) => v == null ? 'Date of birth is required' : null,
          builder: (state) => InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                  initialDate: DateTime(2000));
              if (picked != null) state.didChange(picked);
            },
            child: InputDecorator(
                decoration: InputDecoration(
                    labelText: 'Date of birth *',
                    errorText: state.errorText,
                    border: const OutlineInputBorder()),
                child: Text(state.value == null
                    ? 'Select date'
                    : '${state.value!.day}/${state.value!.month}/${state.value!.year}')),
          ),
        ),
      );

  Widget _upload(String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft)),
      );
}
