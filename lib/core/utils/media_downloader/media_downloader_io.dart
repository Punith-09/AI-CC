import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String> downloadFile(String url, String fileName) async {
  final dio = Dio();
  final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');

  if (Platform.isAndroid) {
    try {
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (publicDownload.existsSync()) {
        final targetPath = '${publicDownload.path}/$sanitizedFileName';
        await dio.download(url, targetPath);
        return targetPath;
      }
    } catch (_) {}
  }

  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      final targetPath = '${downloads.path}/$sanitizedFileName';
      await dio.download(url, targetPath);
      return targetPath;
    }
  } catch (_) {}

  Directory dir;
  try {
    final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (extDirs != null && extDirs.isNotEmpty) {
      dir = extDirs.first;
    } else {
      dir = (await getExternalStorageDirectory()) ?? (await getApplicationDocumentsDirectory());
    }
  } catch (_) {
    dir = await getApplicationDocumentsDirectory();
  }

  final targetPath = '${dir.path}/$sanitizedFileName';
  await dio.download(url, targetPath);
  return targetPath;
}

