import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/photos_provider.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _imageBytes = bytes;

          if (_titleController.text.trim().isEmpty) {
            final rawName = pickedFile.name;
            final dotIndex = rawName.lastIndexOf('.');
            final cleanName = dotIndex != -1 ? rawName.substring(0, dotIndex) : rawName;
            _titleController.text = cleanName.isNotEmpty ? cleanName : 'Headshot - Portfolio Pic';
          }
        });
      }
    } catch (e) {
      // If native plugin channel isn't bound yet (requires full app restart after adding new plugin)
      if (source == ImageSource.gallery) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            setState(() {
              _selectedImage = XFile(file.path ?? file.name, name: file.name);
              _imageBytes = file.bytes;
              if (_titleController.text.trim().isEmpty) {
                final rawName = file.name;
                final dotIndex = rawName.lastIndexOf('.');
                final cleanName = dotIndex != -1 ? rawName.substring(0, dotIndex) : rawName;
                _titleController.text = cleanName.isNotEmpty ? cleanName : 'Headshot - Portfolio Pic';
              }
            });
            return;
          }
        } catch (_) {}
      }

      if (mounted) {
        final isChannelError = e.toString().contains('channel-error') ||
            e.toString().contains('MissingPluginException');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChannelError
                  ? 'Please stop and restart the app (full rebuild) to enable Camera & native picker.'
                  : (source == ImageSource.camera
                      ? 'Unable to access camera: $e'
                      : 'Unable to pick image: $e'),
            ),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangeSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E2E38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Select Photo Source',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(LucideIcons.folder, color: Color(0xFF8E3CF7)),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.camera, color: Color(0xFFE940B7)),
                  title: Text(
                    'Take a Photo with Camera',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
  }

  Future<void> _handleUpload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or capture a photo first.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a title for your photo.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final photosProvider = context.read<PhotosProvider>();

    final success = await photosProvider.uploadPhoto(
      title: title,
      description: description,
      fileName: _selectedImage?.name ?? 'photo.jpg',
      filePath: _selectedImage?.path,
      fileBytes: _imageBytes,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Photo uploaded successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (Navigator.of(context).canPop()) {
        context.pop();
      }
    } else {
      final errorMsg = photosProvider.errorMessage ?? 'Failed to upload photo';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = context.watch<PhotosProvider>().isUploading;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar (< Back and Centered "Upload Photo")
              _buildTopBar(context),

              // Scrollable Form Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upload Photo Box
                      _buildUploadBox(),

                      const SizedBox(height: 24),

                      // Title Label & Input
                      _buildSectionLabel('Title'),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _titleController,
                        hintText: 'Headshot - Portfolio Pic',
                        icon: LucideIcons.image,
                      ),

                      const SizedBox(height: 20),

                      // Description Label & Input
                      _buildSectionLabel('Description'),
                      const SizedBox(height: 8),
                      _buildTextArea(
                        controller: _descriptionController,
                        hintText: 'Describe this photo...',
                      ),

                      const SizedBox(height: 32),

                      // Upload Button
                      _buildUploadButton(isUploading),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.chevronLeft,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'Upload Photo',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(24),
      dashPattern: const [7, 5],
      color: AppColors.primary.withValues(alpha: 0.45),
      strokeWidth: 1.6,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          color: const Color(0xFF0F323D).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: _selectedImage == null ? _buildEmptyState() : _buildPreviewState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Camera Graphic with Sparkle
        _buildCameraGraphic(),

        const SizedBox(height: 16),

        Text(
          'Add your photo',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Choose from gallery or take a new one',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.greyText,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons: Gallery & Camera
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionPill(
              label: 'Gallery',
              icon: LucideIcons.folder,
              gradientColors: const [
                Color(0xFF8E3CF7),
                Color(0xFF6B21A8),
              ],
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(width: 14),
            _buildActionPill(
              label: 'Camera',
              icon: LucideIcons.camera,
              gradientColors: const [
                Color(0xFFE940B7),
                Color(0xFFD9278E),
              ],
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewState() {
    Widget imageWidget;
    if (_imageBytes != null) {
      imageWidget = Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 210,
      );
    } else if (!kIsWeb && _selectedImage?.path != null) {
      imageWidget = Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 210,
      );
    } else {
      imageWidget = Container(
        height: 160,
        color: AppColors.card,
        child: const Center(
          child: Icon(LucideIcons.image, color: AppColors.primary, size: 48),
        ),
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: _removeSelectedImage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedImage!.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _showChangeSourceSheet,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.primary),
              label: Text(
                'Change',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraGraphic() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Camera Body Container
        Container(
          width: 72,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2330),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2B3648),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 2.2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Camera Flash / Viewfinder bump
        Positioned(
          top: -6,
          child: Container(
            width: 26,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF263244),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
          ),
        ),

        // Yellow Sparkle Star on top
        Positioned(
          top: -12,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFFFD54F),
            size: 20,
            shadows: [
              Shadow(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F323D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.greyText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withValues(alpha: 0.8),
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F323D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.greyText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool isUploading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: AppColors.BtnGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isUploading ? null : _handleUpload,
          child: isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Upload Photo',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
