// import 'package:package_info/package_info.dart';

class AppInfo {
  static final AppInfo _appInfo = AppInfo._internal();

  factory AppInfo() {
    return _appInfo;
  }

  String version = '0.0.3';
  String buildNum= '3';
  // Future<void> readPackage() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   version = packageInfo.version;
  //   buildNum= packageInfo.buildNumber;
  // }

  AppInfo._internal();
}