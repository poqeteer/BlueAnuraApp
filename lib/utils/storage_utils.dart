import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static Directory buildFolderPath(String folderName) {
    return Directory("${getExternalStorageDirectory()}/$folderName");
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
      await path.create();
      return path.path;
    }
  }
}