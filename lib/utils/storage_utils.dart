import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static Future<Directory> buildFolderPath(String folderName) async {
    Directory dir = await getExternalStorageDirectory();
    String path = Platform.isAndroid ? dir.path.substring(0, dir.path.indexOf("Android")) : "I don't know";
    return Directory("$path$folderName");
  }
  static Future<String> createFolder(String folderName) async {
    final path = await buildFolderPath(folderName);
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
  static Future<void> removeDirectory(String folderName) async {
    Directory dir = await buildFolderPath(folderName);
    dir.deleteSync(recursive: true);
  }
}