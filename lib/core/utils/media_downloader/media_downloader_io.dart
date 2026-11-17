import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

Future<String> downloadFile(
  String url,
  String fileName, {
  bool isVideo = false,
}) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 5),
      followRedirects: true,
      maxRedirects: 5,
    ),
  );
  final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');

  final ext = sanitizedFileName.toLowerCase();
  final isActuallyVideo = isVideo ||
      ext.endsWith('.mp4') ||
      ext.endsWith('.mov') ||
      ext.endsWith('.webm') ||
      ext.endsWith('.mkv') ||
      ext.endsWith('.avi') ||
      ext.endsWith('.3gp') ||
      ext.endsWith('.m4v');

  if (Platform.isAndroid || Platform.isIOS) {
    // 1. Download to temporary cache directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$sanitizedFileName';
    await dio.download(
      url,
      tempPath,
      deleteOnError: true,
    );

    try {
      // 2. Save directly to mobile device gallery (Photos / MediaStore)
      if (isActuallyVideo) {
        await Gal.putVideo(tempPath);
      } else {
        await Gal.putImage(tempPath);
      }
      return tempPath;
    } on GalException catch (e) {
      if (e.type == GalExceptionType.permissionDenied) {
        throw Exception('Permission denied to save media to gallery.');
      }
      throw Exception(e.type.message);
    } finally {
      // Clean up temporary file
      try {
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
    }
  }

  // Desktop platforms (Windows, macOS, Linux)
  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      final targetPath = '${downloads.path}/$sanitizedFileName';
      await dio.download(url, targetPath, deleteOnError: true);
      return targetPath;
    }
  } catch (_) {}

  final dir = await getApplicationDocumentsDirectory();
  final targetPath = '${dir.path}/$sanitizedFileName';
  await dio.download(url, targetPath, deleteOnError: true);
  return targetPath;
}
