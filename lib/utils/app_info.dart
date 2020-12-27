import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';

class AppInfo {
  static final AppInfo _appInfo = AppInfo._internal();

  factory AppInfo() {
    return _appInfo;
  }

  String version = '0.0.3';
  String buildNum= '4';
  String deviceModel = '';
  String osInfo = '';
  Future<void> readInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNum= packageInfo.buildNumber;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      osInfo = '${androidInfo.version.release} (${androidInfo.version.sdkInt})::${androidInfo.version.securityPatch}';
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.name;
      osInfo = '${iosInfo.systemVersion}::${iosInfo.utsname.version}';
    }
  }

  AppInfo._internal();
}