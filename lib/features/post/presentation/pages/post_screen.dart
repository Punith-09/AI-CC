import 'package:aicc/common/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auditions/data/models/create_audition_request.dart';
import '../../../auditions/presentation/providers/auditions_provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color borderColor = const Color(0xff32323A);

  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _payController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _langController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Film';

  final List<String> _categories = [
    'Film',
    'Ad',
    'Dancer',
    'TV',
    'Actor',
    'Singer',
    'Model',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _payController.dispose();
    _deadlineController.dispose();
    _langController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurpleAccent,
              onPrimary: Colors.white,
              surface: Color(0xff1F1F27),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final role = _roleController.text.trim();
    final location = _locationController.text.trim();
    final pay = _payController.text.trim();
    final deadline = _deadlineController.text.trim();
    final lang = _langController.text.trim();

    final request = CreateAuditionRequest(
      title: title,
      category: _selectedCategory,
      role: role,
      location: location,
      pay: pay,
      deadline: deadline,
      lang: lang,
      desc: desc,
    );

    final success =
        await context.read<AuditionsProvider>().createAudition(request);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audition posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.auditions);
      } else {
        final errorMsg =
            context.read<AuditionsProvider>().createErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg ?? 'Failed to post audition'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.lightText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Cancel + Post New Audition
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.auditions);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: IconButton(
                              icon: Icon(
                                LucideIcons.chevronLeft,
                                color: textColor,
                                size: 24,
                              ),
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.home);
                                }
                              },
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Post New Audition',
                            style: TextStyle(
                              fontSize: 20,
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Project Title
                  _buildLabel('Project Title'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _titleController,
                    hint: 'Action Movie 2026',
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter a project title'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Category Pills
                  _buildLabel('Category'),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.grey.shade400 : const Color(0xFF475569)),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Seeking
                  _buildLabel('Role Seeking'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _roleController,
                    hint: 'Hero (Male, 25-35)',
                    icon: Icons.people_outline,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter role seeking'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildLabel('Location'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _locationController,
                    hint: 'Mumbai',
                    icon: Icons.location_on_outlined,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter location'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Pay
                  _buildLabel('Pay'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _payController,
                    hint: '50000',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter pay amount'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Application Deadline
                  _buildLabel('Application Deadline'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildInputField(
                        controller: _deadlineController,
                        hint: 'Select date',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please select application deadline'
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.edit_calendar_outlined,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          onPressed: _selectDate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Language Requirement
                  _buildLabel('Language Requirement'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _langController,
                    hint: 'Hindi',
                    icon: Icons.translate_outlined,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter language requirement'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    maxLines: 5,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter description'
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Describe the role and requirements...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade500 : const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.danger,
                          width: 1.5,
                        ),
                      ),
                      errorStyle: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Publish Audition Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: AppColors.BtnGradient,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: auditionsProvider.isCreateLoading
                            ? null
                            : _submitPost,
                        child: auditionsProvider.isCreateLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Publish Audition',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isDark ? AppColors.white : AppColors.lightText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    Widget? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : const Color(0xFF94A3B8)),
        prefixIcon: icon != null
            ? Icon(icon, color: isDark ? Colors.grey : const Color(0xFF64748B), size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: icon != null ? 0 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}