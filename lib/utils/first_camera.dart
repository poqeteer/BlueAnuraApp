// import 'package:camera/camera.dart';

///
/// Kludge... Need to lookup this info before runApp? so just storing it here for later
///
class FirstCamera {
  static final FirstCamera _firstCamera = FirstCamera._internal();

  factory FirstCamera() {
    return _firstCamera;
  }
  // CameraDescription camera;

  FirstCamera._internal();
}