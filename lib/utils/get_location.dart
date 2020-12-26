import 'package:location/location.dart';

class BuildLocation {
  static Future<LocationData> buildLocationText() async {
    final Location location = Location();

    String err = "";
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        err = "GPS Serve disabled";
      }
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (err == "" && _permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        err = "GPS Permission denied";
      }
    }

    if (err == "") {
      return await location.getLocation();
    } else {
      return Future.error(err);
    }
  }
}