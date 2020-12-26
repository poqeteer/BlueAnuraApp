import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class StorageUtils {
  static Future<String> createFolder(String folderName) async {
    final path = Directory("storage/emulated/0/$folderName");
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