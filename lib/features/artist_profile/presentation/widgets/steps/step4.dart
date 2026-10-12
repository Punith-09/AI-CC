import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_form_data.dart';
import 'step_common_widgets.dart';

class Step4PortfolioExperience extends StatefulWidget {
  final ProfileFormData data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isSubmitting;

  const Step4PortfolioExperience({
    super.key,
    required this.data,
    required this.onNext,
    required this.onPrevious,
    this.isSubmitting = false,
  });

  @override
  State<Step4PortfolioExperience> createState() =>
      _Step4PortfolioExperienceState();
}

class _Step4PortfolioExperienceState
    extends State<Step4PortfolioExperience> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _previousWorkList = [
    'Movie',
    'OTT',
    'TV Serial',
    'Advertisement',
    'Short Film',
    'Theatre',
    'Music Video',
    'Fashion Show',
  ];

  Future<void> _pickImage({required bool isHeadshot}) async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isHeadshot) {
            widget.data.headshot = image.name.isNotEmpty ? image.name : image.path;
          } else {
            widget.data.fullBody = image.name.isNotEmpty ? image.name : image.path;
          }
        });
      }
    } catch (_) {
      try {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            if (isHeadshot) {
              widget.data.headshot = file.name;
            } else {
              widget.data.fullBody = file.name;
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          widget.data.introVideo = file.name;
        });
      }
    } catch (_) {
      try {
        final picker = ImagePicker();
        final XFile? video =
            await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          setState(() {
            widget.data.introVideo =
                video.name.isNotEmpty ? video.name : video.path;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          widget.data.resume = file.name;
        });
      }
    } catch (_) {}
  }

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
            title: 'Portfolio & Experience',
          ),

          // ── Headshot Upload ───────────────────────────────
          StepUploadButton(
            label: 'Headshot Upload',
            fileName: widget.data.headshot,
            onUpload: () => _pickImage(isHeadshot: true),
            onClear: () => setState(() => widget.data.headshot = null),
          ),

          // ── Full Body Photo ───────────────────────────────
          StepUploadButton(
            label: 'Full Body Photo',
            fileName: widget.data.fullBody,
            onUpload: () => _pickImage(isHeadshot: false),
            onClear: () => setState(() => widget.data.fullBody = null),
          ),

          // ── Introduction Video ────────────────────────────
          StepUploadButton(
            label: 'Introduction Video',
            fileName: widget.data.introVideo,
            onUpload: _pickVideo,
            onClear: () => setState(() => widget.data.introVideo = null),
          ),

          // ── Previous Work ─────────────────────────────────
          const StepFieldLabel(title: 'Previous Work', topPadding: 24),
          ..._previousWorkList.map(
            (p) => StepCheckboxItem(
              title: p,
              isSelected: widget.data.previousWork.contains(p),
              onTap: () {
                setState(() {
                  if (widget.data.previousWork.contains(p)) {
                    widget.data.previousWork.remove(p);
                  } else {
                    widget.data.previousWork.add(p);
                  }
                });
              },
            ),
          ),

          // ── Instagram URL ─────────────────────────────────
          const StepFieldLabel(
              title: 'Instagram URL', topPadding: 24),
          StepTextField(
            controller: widget.data.instagramController,
            hint: 'Enter Instagram URL',
            keyboardType: TextInputType.url,
          ),

          // ── YouTube URL ───────────────────────────────────
          const StepFieldLabel(
              title: 'YouTube URL', topPadding: 18),
          StepTextField(
            controller: widget.data.youtubeController,
            hint: 'Enter YouTube URL',
            keyboardType: TextInputType.url,
          ),

          // ── IMDb URL ──────────────────────────────────────
          const StepFieldLabel(
              title: 'IMDb URL', topPadding: 18),
          StepTextField(
            controller: widget.data.imdbController,
            hint: 'Enter IMDb URL',
            keyboardType: TextInputType.url,
          ),

          // ── Personal Website ──────────────────────────────
          const StepFieldLabel(
              title: 'Personal Website', topPadding: 18),
          StepTextField(
            controller: widget.data.websiteController,
            hint: 'Enter Personal Website',
            keyboardType: TextInputType.url,
          ),

          // ── Resume Upload (pdf) ───────────────────────────
          StepUploadButton(
            label: 'Resume Upload (pdf)',
            fileName: widget.data.resume,
            onUpload: _pickResume,
            onClear: () => setState(() => widget.data.resume = null),
          ),

          // ── Awards & Achievements ─────────────────────────
          const StepFieldLabel(
              title: 'Awards & Achievements',
              topPadding: 18),
          StepTextField(
            controller: widget.data.awardsController,
            hint: 'Enter Awards & Achievements',
          ),

          // ── Bio / About Me ────────────────────────────────
          const StepFieldLabel(title: 'Bio / About Me', topPadding: 18),
          StepTextField(
            controller: widget.data.bioController,
            hint: 'Maximum 500 Characters',
            maxLines: 4,
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
