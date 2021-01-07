import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

// import 'package:blue_anura/utils/app_info.dart';
// import 'package:blue_anura/utils/get_location.dart';
import 'package:blue_anura/views/camera/survey_card_page.dart';
// import 'package:blue_anura/utils/storage_utils.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:blue_anura/views/camera/widgets/bottom_bar.dart';
// import 'package:blue_anura/views/camera/widgets/preview_card.dart';
import 'package:blue_anura/views/camera/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:adaptive_dialog/adaptive_dialog.dart';
// import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
// import 'package:location/location.dart';

// import 'package:image/image.dart' as imgUtils;
// import 'package:gallery_saver/gallery_saver.dart';

import 'package:path_provider/path_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
// import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';


// import 'package:r_album/r_album.dart';

class Camera extends StatefulWidget {
  // just for E2E test. if true we create our images names from datetime.
  // Else it's just a name to assert image exists
  final bool randomPhotoName;

  Camera({this.randomPhotoName = true});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with TickerProviderStateMixin {
  // String _lastPhotoPath;
  bool _fullscreen = false;

  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(null);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  ValueNotifier<CameraOrientations> _orientation =
  ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = new PictureController();

  /// list of available sizes
  List<Size> _availableSizes;

  AnimationController _iconsAnimationController, _previewAnimationController;
  // Animation<Offset> _previewAnimation;
  Timer _previewDismissTimer;
  // StreamSubscription<Uint8List> previewStreamSub;
  // Stream<Uint8List> previewStream;

  String _orgId;
  String _locId;
  int _sequence;

  @override
  void initState() {
    super.initState();
    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _previewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // _previewAnimation = Tween<Offset>(
    //   begin: const Offset(-2.0, 0.0),
    //   end: Offset.zero,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _previewAnimationController,
    //     curve: Curves.elasticOut,
    //     reverseCurve: Curves.elasticIn,
    //   ),
    // );
    _initState();
  }

  Future<void> _initState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState((){
      _orgId = prefs.get(Constants.PREF_LAST_ORG) ?? "";
      _locId = prefs.get(Constants.PREF_LAST_LOC) ?? "";
      _sequence = prefs.getInt(Constants.PREF_SEQUENCE) ?? 1;
    });
  }

  @override
  void dispose() {
    _iconsAnimationController.dispose();
    _previewAnimationController.dispose();
    // previewStreamSub.cancel();
    _photoSize.dispose();
    _captureMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseNavPage(
        title: "Organization: ${_orgId} | Location: ${_locId}",
        body: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            this._fullscreen ? buildFullscreenCamera() : buildSizedScreenCamera(),
            _buildInterface(),
            //  PreviewCardWidget(
            //   lastPhotoPath: _lastPhotoPath,
            //   orientation: _orientation,
            //   previewAnimation: _previewAnimation,
            // )
          ],
        ),
      )
    );
  }

  Widget _buildInterface() {
    return Stack(
      children: <Widget>[
        SafeArea(
          bottom: false,
          child: TopBarWidget(
              isFullscreen: _fullscreen,
              photoSize: _photoSize,
              captureMode: _captureMode,
              switchFlash: _switchFlash,
              orientation: _orientation,
              rotationController: _iconsAnimationController,
              onFlashTap: () {
                switch (_switchFlash.value) {
                  case CameraFlashes.NONE:
                    _switchFlash.value = CameraFlashes.ON;
                    break;
                  case CameraFlashes.ON:
                    _switchFlash.value = CameraFlashes.AUTO;
                    break;
                  case CameraFlashes.AUTO:
                    _switchFlash.value = CameraFlashes.ALWAYS;
                    break;
                  case CameraFlashes.ALWAYS:
                    _switchFlash.value = CameraFlashes.NONE;
                    break;
                }
                setState(() {});
              },
              onResolutionTap: () => _buildChangeResolutionDialog(),
              onFullscreenTap: () {
                this._fullscreen = !this._fullscreen;
                setState(() {});
              }),
        ),
        BottomBarWidget(
          onZoomInTap: () {
            if (_zoomNotifier.value <= 0.9) {
              _zoomNotifier.value += 0.1;
            }
            setState(() {});
          },
          onZoomOutTap: () {
            if (_zoomNotifier.value >= 0.1) {
              _zoomNotifier.value -= 0.1;
            }
            setState(() {});
          },
          onCaptureTap: _takePhoto,
          rotationController: _iconsAnimationController,
          orientation: _orientation,
          captureMode: _captureMode,
        ),
      ],
    );
  }

  _takePhoto() async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
      await Directory('${extDir.path}/test').create(recursive: true);
    final String fileName = widget.randomPhotoName
        ? '${_orgId}_${_locId}_${DateFormat('yyyyMMdd').format(DateTime.now())}_${_sequence.toString().padLeft(3, '0')}.jpg'
        : 'photo_test.jpg';
    final String filePath ='${testDir.path}/$fileName';

    // final String path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES);
    // final String filePath = '$path/photo_test.jpg';
    // Stopwatch stopwatch = new Stopwatch()..start();
    await _pictureController.takePicture(filePath);
    // print('takePicture: ${stopwatch.elapsed}');
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();

    // _lastPhotoPath = filePath;
    setState(() {});
    // print('setState: ${stopwatch.elapsed}');
    // if (_previewAnimationController.status == AnimationStatus.completed) {
    //   _previewAnimationController.reset();
    // }
    // _previewAnimationController.forward();
    // print('preview: ${stopwatch.elapsed}');
    print("----------------------------------");
    print("TAKE PHOTO CALLED");
    // File _image = File(filePath);
    print("==> path : $filePath");
    // final img = imgUtils.decodeImage(file.readAsBytesSync());
    // print("==> img.width : ${img.width} | img.height : ${img.height}");
    print("----------------------------------");

    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SurveyCardPage(filePath)));

    if (result == 'Saved') {
      Navigator.pop(context, result);
    }

    // StorageUtils.createFolder("DCIM/BlueAnura").then((path) {
    //   _image.copy('$path/$fileName').then((value) {
    //     print("----------------------------------");
    //         print("IMAGE MOVED: Success");
    //     print("==> from: $filePath to $value");
    //     print("----------------------------------");
    //     _image.delete();
    //   }).catchError((error) {
    //     showOkAlertDialog(title: "Copy Error", message: error.toString(), context: context);
    //   });
    // }).catchError((error){
    //   print("----------------------------------");
    //   print("IMAGE MOVED: Failed ${error.toString()}");
    //   print("----------------------------------");
    // });
  }

  _buildChangeResolutionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => ListTile(
          key: ValueKey("resOption"),
          onTap: () {
            this._photoSize.value = _availableSizes[index];
            setState(() {});
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.aspect_ratio),
          title: Text(
              "${_availableSizes[index].width}/${_availableSizes[index].height}"),
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: _availableSizes.length,
      ),
    );
  }

  _onOrientationChange(CameraOrientations newOrientation) {
    _orientation.value = newOrientation;
    if (_previewDismissTimer != null) {
      _previewDismissTimer.cancel();
    }
  }

  _onPermissionsResult(bool granted) {
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text(
            'It seems you did\'t authorized some permissions. Please check on your settings\n' +
            'for permissions to use the camera, storage and location, and try again.'),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print("granted");
    }
  }

  Widget buildFullscreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: CameraAwesome(
          onPermissionsResult: _onPermissionsResult,
          selectDefaultSize: (availableSizes) {
            this._availableSizes = availableSizes;
            return availableSizes[0];
          },
          captureMode: _captureMode,
          photoSize: _photoSize,
          sensor: _sensor,
          enableAudio: _enableAudio,
          switchFlashMode: _switchFlash,
          zoom: _zoomNotifier,
          onOrientationChanged: _onOrientationChange,
          onCameraStarted: () {
            // camera started here -- do your after start stuff
          },
        ),
      ),
    );
  }

  Widget buildSizedScreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: CameraAwesome(
              onPermissionsResult: _onPermissionsResult,
              selectDefaultSize: (availableSizes) {
                this._availableSizes = availableSizes;
                return availableSizes[0];
              },
              captureMode: _captureMode,
              photoSize: _photoSize,
              sensor: _sensor,
              fitted: true,
              switchFlashMode: _switchFlash,
              zoom: _zoomNotifier,
              onOrientationChanged: _onOrientationChange,
            ),
          ),
        ),
      ),
    );
  }
}
