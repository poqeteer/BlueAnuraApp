// import 'package:blue_anura/utils/first_camera.dart';
// import 'package:camera/camera.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:blue_anura/views/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   FirstCamera().cameras = await availableCameras();
  // } on CameraException catch (e) {
  //   print('Error: ${e.code}\nError Message: ${e.description}');
  // }

  // Obtain a list of the available cameras on the device.
  // final cameras = await availableCameras();

  // if (cameras.length == 0) {
  //   print ('no cameras...');
  // } else {
  //   FirstCamera().camera = cameras.first;
  // }

  // Really only needed for initial run. This should be set on upload
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt(Constants.PREF_SEQUENCE) == null)
    prefs.setInt(Constants.PREF_SEQUENCE, 1);

  await AppInfo().readInfo();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: Constants.mainBackgroundColor,
        accentColor: Colors.orange,
        // fontFamily: 'SourceSansPro',
        // textTheme: TextTheme(
        //   button: TextStyle(
        //     // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
        //     fontFamily: 'OpenSans',
        //   ),
        //   caption: TextStyle(
        //     fontFamily: 'NotoSans',
        //     fontSize: 12.0,
        //     fontWeight: FontWeight.normal,
        //     color: Colors.deepPurple[300],
        //   ),
        //   // headline1: TextStyle(fontFamily: 'Quicksand'),
        //   headline2: TextStyle(
        //     fontFamily: 'OpenSans',
        //     fontSize: 24.0,
        //     // fontWeight: FontWeight.w400,
        //     color: Colors.orange,
        //   ),
        //   headline3: TextStyle(fontFamily: 'Quicksand'),
        //   headline4: TextStyle(fontFamily: 'Quicksand'),
        //   headline5: TextStyle(fontFamily: 'NotoSans'),
        //   headline6: TextStyle(fontFamily: 'NotoSans'),
        //   bodyText1: TextStyle(fontFamily: 'NotoSans'),
        //   bodyText2: TextStyle(fontFamily: 'NotoSans'),
        //   subtitle1: TextStyle(fontFamily: 'NotoSans'),
        //   subtitle2: TextStyle(fontFamily: 'NotoSans'),
        //   overline: TextStyle(fontFamily: 'NotoSans'),
        // ),
      ),
      home: LoginScreen(),
    );
  }
}