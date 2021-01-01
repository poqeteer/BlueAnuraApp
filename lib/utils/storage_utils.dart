import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class StorageUtils {
  static Directory buildFolderPath(String folderName) {
    return Directory("storage/emulated/0/$folderName");
  }
  static Future<String> createFolder(String folderName) async {
    final path = buildFolderPath(folderName);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }
}