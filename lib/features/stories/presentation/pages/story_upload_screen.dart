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
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: isUploading ? null : () => context.pop(),
                    ),
                    Text(
                      'Add to Story',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                            : const Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Photos and videos disappear from your story after 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.65),
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
    return Material(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
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
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.send, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Share to Your Story',
                          style: TextStyle(
                            color: Colors.white,
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
}
