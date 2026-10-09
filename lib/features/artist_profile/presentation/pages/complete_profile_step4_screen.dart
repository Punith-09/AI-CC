import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aicc/common/widgets/app_background.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';

class CompleteProfileStep4Screen extends StatefulWidget {
  const CompleteProfileStep4Screen({super.key});

  @override
  State<CompleteProfileStep4Screen> createState() =>
      _CompleteProfileStep4ScreenState();
}

class _CompleteProfileStep4ScreenState
    extends State<CompleteProfileStep4Screen> {
  // Track which media items are "added" (simulated — real upload uses file_picker)
  bool _headshotAdded = false;
  bool _fullBodyAdded = false;
  bool _introVideoAdded = false;

  // Previous work items (simulated list)
  final List<Map<String, String>> _previousWork = [];

  // Text controllers for previous work entries
  final TextEditingController _workTitleController = TextEditingController();
  final TextEditingController _workDescController = TextEditingController();

  // Acting reel / showreel link
  final TextEditingController _showreelController = TextEditingController();

  @override
  void dispose() {
    _workTitleController.dispose();
    _workDescController.dispose();
    _showreelController.dispose();
    super.dispose();
  }

  Future<void> _saveAndNext() async {
    final provider = context.read<ProfileProvider>();

    final data = <String, dynamic>{
      'showreelLink': _showreelController.text.trim(),
      'previousWork': _previousWork,
    };

    try {
      await provider.updateProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolio details saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.push(AppRoutes.completeProfileStep5);
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

  void _showAddWorkDialog() {
    _workTitleController.clear();
    _workDescController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        final textColor = AppColors.getText(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Previous Work',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _workTitleController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Project / Film Name',
                  hintStyle: TextStyle(
                      color:
                          AppColors.getTextSecondary(context).withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context)
                            .withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _workDescController,
                style: TextStyle(color: textColor),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Brief description / role played',
                  hintStyle: TextStyle(
                      color: AppColors.getTextSecondary(context)
                          .withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context)
                            .withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(
                      color: AppColors.getTextSecondary(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final title = _workTitleController.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _previousWork.add({
                      'title': title,
                      'description': _workDescController.text.trim(),
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String title) {
    final textColor = AppColors.getText(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMediaUploadCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isAdded,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final textColor = AppColors.getText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isAdded
        ? AppColors.primary
        : AppColors.getTextSecondary(context).withValues(alpha: 0.3);

    return GestureDetector(
      onTap: isAdded ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isAdded ? 1.5 : 1),
          color: isAdded
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isAdded
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAdded ? Icons.check_circle_rounded : icon,
                color: isAdded
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAdded ? 'Uploaded ✓' : subtitle,
                    style: TextStyle(
                      color: isAdded
                          ? AppColors.primary
                          : AppColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdded)
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.getTextSecondary(context),
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 22,
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
  }) {
    final textColor = AppColors.getText(context);
    final hintColor = AppColors.getTextSecondary(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      keyboardType: keyboardType,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────
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
                          '60% Complete',
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
                          value: 0.6,
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
                          'Step 4 of 5',
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          'Portfolio & Media',
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Upload photos and videos to showcase your talent. These will appear on your profile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      // ── Profile Photos ───────────────────────────────
                      _buildLabel('Profile Photos'),
                      _buildMediaUploadCard(
                        label: 'Headshot',
                        subtitle: 'Clear close-up photo of your face',
                        icon: Icons.face_rounded,
                        isAdded: _headshotAdded,
                        onTap: () => setState(() => _headshotAdded = true),
                        onRemove: () => setState(() => _headshotAdded = false),
                      ),
                      const SizedBox(height: 12),
                      _buildMediaUploadCard(
                        label: 'Full Body Photo',
                        subtitle: 'Standing photo showing full body',
                        icon: Icons.accessibility_new_rounded,
                        isAdded: _fullBodyAdded,
                        onTap: () => setState(() => _fullBodyAdded = true),
                        onRemove: () => setState(() => _fullBodyAdded = false),
                      ),

                      // ── Intro / Demo Reel ────────────────────────────
                      _buildLabel('Intro / Demo Reel'),
                      _buildMediaUploadCard(
                        label: 'Intro Video',
                        subtitle: 'Short 30–60 sec introduction video',
                        icon: Icons.videocam_rounded,
                        isAdded: _introVideoAdded,
                        onTap: () => setState(() => _introVideoAdded = true),
                        onRemove: () =>
                            setState(() => _introVideoAdded = false),
                      ),

                      // ── Showreel / YouTube Link ───────────────────────
                      _buildLabel('Showreel / YouTube Link'),
                      _buildOutlinedField(
                        controller: _showreelController,
                        hint: 'Paste YouTube or Vimeo link',
                        keyboardType: TextInputType.url,
                      ),

                      // ── Previous Work ─────────────────────────────────
                      _buildLabel('Previous Work'),
                      ..._previousWork.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final work = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                              color: AppColors.primary.withValues(alpha: 0.05),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        work['title'] ?? '',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (work['description']?.isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          work['description']!,
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(
                                                context),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                        () => _previousWork.removeAt(idx));
                                  },
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color:
                                        AppColors.getTextSecondary(context),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _showAddWorkDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add Previous Work',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Navigation Buttons ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1D3B5),
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _saveAndNext,
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
    );
  }
}
