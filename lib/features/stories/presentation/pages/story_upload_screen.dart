import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/stories_provider.dart';

class StoryUploadScreen extends StatefulWidget {
  const StoryUploadScreen({super.key});

  @override
  State<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends State<StoryUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedFile;
  Uint8List? _mediaBytes;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  bool _isPicking = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        await _clearVideo();
        setState(() {
          _selectedFile = file;
          _mediaBytes = bytes;
          _isVideo = false;
        });
      }
    } catch (_) {
      // Fallback with FilePicker on gallery if native image_picker fails
      if (source == ImageSource.gallery) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            final f = result.files.first;
            await _clearVideo();
            setState(() {
              _selectedFile = XFile(f.path ?? f.name, name: f.name);
              _mediaBytes = f.bytes;
              _isVideo = false;
            });
          }
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        await _setupVideo(file, bytes);
      }
    } catch (_) {
      if (source == ImageSource.gallery) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.video,
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            final f = result.files.first;
            final xFile = XFile(f.path ?? f.name, name: f.name);
            await _setupVideo(xFile, f.bytes);
          }
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _setupVideo(XFile file, Uint8List? bytes) async {
    await _clearVideo();

    VideoPlayerController? controller;
    if (!kIsWeb && file.path.isNotEmpty) {
      controller = VideoPlayerController.file(File(file.path));
    } else if (kIsWeb && file.path.isNotEmpty) {
      try {
        controller = VideoPlayerController.networkUrl(Uri.parse(file.path));
      } catch (_) {}
    }

    if (controller != null) {
      try {
        await controller.initialize();
        controller.setLooping(true);
        controller.play();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _selectedFile = file;
        _mediaBytes = bytes;
        _isVideo = true;
        _videoController = controller;
      });
    }
  }

  Future<void> _clearVideo() async {
    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  void _resetSelection() {
    _clearVideo();
    setState(() {
      _selectedFile = null;
      _mediaBytes = null;
      _isVideo = false;
    });
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null && _mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image or video to upload as story.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final storiesProvider = context.read<StoriesProvider>();
    if (storiesProvider.isUploading) return;

    final fileName = _selectedFile?.name ??
        (_isVideo ? 'story_${DateTime.now().millisecondsSinceEpoch}.mp4' : 'story_${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      await storiesProvider.uploadStory(
        fileName: fileName,
        filePath: !kIsWeb ? _selectedFile?.path : null,
        fileBytes: _mediaBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story added successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share story: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesProvider = context.watch<StoriesProvider>();
    final isUploading = storiesProvider.isUploading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF1F5F9),
        body: SafeArea(
          child: _buildDesktopLayout(isDark, isUploading),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:  Icon(Icons.close_rounded, color: isDark?AppColors.white:AppColors.black, size: 28),
                      onPressed: isUploading ? null : () => context.pop(),
                    ),
                    Text(
                      'Add to Story',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:isDark?AppColors.white:AppColors.black,
                      ),
                    ),
                    if (_selectedFile != null || _mediaBytes != null)
                      TextButton(
                        onPressed: isUploading ? null : _handleUpload,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            :  Text(
                                'Share',
                                style: TextStyle(
                                  color: isDark?AppColors.white:AppColors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: _selectedFile == null && _mediaBytes == null
                    ? _buildPickerPrompt(isDark)
                    : _buildMediaPreview(isDark, isUploading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerPrompt(bool isDark) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Big circular gradient icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF3D00), Color(0xFFFFB800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_enhance_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Share a Moment',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark?AppColors.white:AppColors.black,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Photos and videos disappear from your story after 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color:isDark?AppColors.white:AppColors.black,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          // Options Grid
          _buildActionCard(
            icon: LucideIcons.image,
            title: 'Choose Photo from Gallery',
            subtitle: 'Share high quality audition photos or headshots',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 14),

          _buildActionCard(
            icon: LucideIcons.video,
            title: 'Choose Video from Gallery',
            subtitle: 'Share quick clips or audition reels (up to 60s)',
            onTap: () => _pickVideo(ImageSource.gallery),
          ),
          const SizedBox(height: 14),

          _buildActionCard(
            icon: LucideIcons.camera,
            title: 'Take a Photo with Camera',
            subtitle: 'Capture a selfie or current moment right now',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 14),

          _buildActionCard(
            icon: LucideIcons.film,
            title: 'Record a Video with Camera',
            subtitle: 'Record a quick intro or greeting',
            onTap: () => _pickVideo(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Material(
      color: isDark?AppColors.black:AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            border: Border.all(color:AppColors.hint),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark?AppColors.white:AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(bool isDark, bool isUploading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Preview Card
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: const Color(0xFF141414),
                    child: _isVideo
                        ? (_videoController != null && _videoController!.value.isInitialized
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.video, color: Colors.white54, size: 48),
                                    SizedBox(height: 8),
                                    Text('Video selected', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ))
                        : (_mediaBytes != null
                            ? Image.memory(
                                _mediaBytes!,
                                fit: BoxFit.cover,
                              )
                            : (!kIsWeb && _selectedFile != null
                                ? Image.file(
                                    File(_selectedFile!.path),
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.shrink())),
                  ),
                ),

                // Top Media Type Tag & Change Button
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isVideo ? LucideIcons.video : LucideIcons.image,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isVideo ? 'Video Story' : 'Photo Story',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isUploading ? null : _resetSelection,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        ),
                        tooltip: 'Choose different media',
                      ),
                    ],
                  ),
                ),

                // Video play/pause overlay
                if (_isVideo && _videoController != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _videoController!.value.isPlaying ? 0.0 : 0.85,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Expiry info at bottom of preview
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.clock, size: 14, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Disappears automatically after 24 hours',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Action: Share to Your Story
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isUploading ? null : _handleUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: isUploading
                  ?  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Uploading Story...',
                          style: TextStyle(
                            color:isDark?AppColors.white:AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  :  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.send, color: isDark?AppColors.white:AppColors.black, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Share to Your Story',
                          style: TextStyle(
                            color: isDark?AppColors.white:AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DESKTOP LAYOUT (Web / Wide Viewports)
  // =========================================================

  Widget _buildDesktopLayout(bool isDark, bool isUploading) {
    return Column(
      children: [
        _buildDesktopTopBar(isDark, isUploading),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: _selectedFile == null && _mediaBytes == null
                  ? _buildDesktopPickerPrompt(isDark)
                  : _buildDesktopMediaPreview(isDark, isUploading),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTopBar(bool isDark, bool isUploading) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C26) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF263040) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              InkWell(
                onTap: isUploading ? null : () => context.pop(),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back to Feed',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title Header
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add to Story',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Active for 24 hours on your profile',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              // Right action
              if (_selectedFile != null || _mediaBytes != null)
                TextButton.icon(
                  onPressed: isUploading ? null : _resetSelection,
                  icon: const Icon(LucideIcons.rotateCcw, size: 14),
                  label: const Text('Change Media'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                )
              else
                IconButton(
                  onPressed: isUploading ? null : () => context.pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    size: 22,
                  ),
                  tooltip: 'Close',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPickerPrompt(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161C26) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF263040) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A00), Color(0xFFFF3D00), Color(0xFFFFB800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.38),
                    blurRadius: 26,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_enhance_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 22),

            Text(
              'Share a Moment',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                'Photos and videos disappear from your story after 24 hours. Select media from your device to share.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2x2 Grid Options
            Row(
              children: [
                Expanded(
                  child: _buildDesktopOptionTile(
                    icon: LucideIcons.image,
                    title: 'Choose Photo',
                    subtitle: 'Upload high-res picture or headshot',
                    badge: 'Photo',
                    onTap: () => _pickImage(ImageSource.gallery),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDesktopOptionTile(
                    icon: LucideIcons.video,
                    title: 'Choose Video',
                    subtitle: 'Share quick clips or reels (up to 60s)',
                    badge: 'Video',
                    onTap: () => _pickVideo(ImageSource.gallery),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDesktopOptionTile(
                    icon: LucideIcons.camera,
                    title: 'Take Photo',
                    subtitle: 'Capture current moment via camera',
                    badge: 'Webcam',
                    onTap: () => _pickImage(ImageSource.camera),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDesktopOptionTile(
                    icon: LucideIcons.film,
                    title: 'Record Video',
                    subtitle: 'Record intro greeting or rehearsal',
                    badge: 'Record',
                    onTap: () => _pickVideo(ImageSource.camera),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recommendation badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vertical 9:16 portrait format works best for Stories',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFFB800) : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppColors.primary.withValues(alpha: 0.08),
        splashColor: AppColors.primary.withValues(alpha: 0.16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF263040) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 21),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopMediaPreview(bool isDark, bool isUploading) {
    final myName = LocalStorage.instance.getUserName() ?? 'You';
    final myPic = LocalStorage.instance.getUserProfilePhoto();

    // 9:16 portrait dimensions for clean desktop frame
    const double frameHeight = 620.0;
    const double frameWidth = frameHeight * 9 / 16;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Vertical Story Canvas (Phone Viewport)
          Container(
            width: frameWidth,
            height: frameHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Media content
                  _isVideo
                      ? (_videoController != null && _videoController!.value.isInitialized
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.video, color: Colors.white54, size: 48),
                                  SizedBox(height: 10),
                                  Text('Video selected', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ))
                      : (_mediaBytes != null
                          ? Image.memory(
                              _mediaBytes!,
                              fit: BoxFit.cover,
                            )
                          : (!kIsWeb && _selectedFile != null
                              ? Image.file(
                                  File(_selectedFile!.path),
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox.shrink())),

                  // Dark subtle top gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top User Pill & Story Tag
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.primary,
                          backgroundImage: (myPic != null && myPic.isNotEmpty) ? NetworkImage(myPic) : null,
                          child: (myPic == null || myPic.isEmpty)
                              ? Text(
                                  myName.isNotEmpty ? myName[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                myName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              const Text(
                                'Preview',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isVideo ? LucideIcons.video : LucideIcons.image,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isVideo ? 'Video' : 'Photo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Play / Pause Tap Overlay
                  if (_isVideo && _videoController != null)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _videoController!.value.isPlaying ? 0.0 : 0.85,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom subtle gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Bottom story badge inside canvas
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Disappears after 24 hours',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 36),

          // Right: Publishing Controls & Story Info Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161C26) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF263040) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Story Details',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 3.5,
                              backgroundColor: Color(0xFF10B981),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ready to share',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Divider(
                    color: isDark ? const Color(0xFF263040) : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  const SizedBox(height: 20),

                  // Info list
                  _buildDetailRow(
                    icon: _isVideo ? LucideIcons.video : LucideIcons.image,
                    label: 'Format',
                    value: _isVideo ? 'Video Story (MP4)' : 'Photo Story (High Res)',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: LucideIcons.users,
                    label: 'Audience',
                    value: 'All Followers & Profile Visitors',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: LucideIcons.clock,
                    label: 'Lifespan',
                    value: '24 hours from publication',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Tip box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F2937).withValues(alpha: 0.6)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.lightbulb,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your story appears at the top of the Home feed for your network. Tap "Share" to post instantly.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Primary Button: Share to Your Story
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isUploading ? null : _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Uploading Story...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.send, size: 18, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Share to Your Story',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary Button: Change Media
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: isUploading ? null : _resetSelection,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Choose Different Media'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : const Color(0xFF475569),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
