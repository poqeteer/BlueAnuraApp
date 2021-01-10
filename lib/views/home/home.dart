import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _startSurvey = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState () async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.photos,
    ].request();

    statuses.forEach((key, value) {
      print('$key: $value');
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _startSurvey = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                        child: Text('Welcome to Blue Anura\'s', style: Theme.of(context).textTheme.headline5)
                    ),
                    Center(
                        child: Text('Survey Camera App', style: Theme.of(context).textTheme.headline5)
                    ),
                    Center(
                        child: Text('Version ${AppInfo().version}.${AppInfo().buildNum}', style: Theme.of(context).textTheme.subtitle1)
                    ),
                  ],
                ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                children: [
                  Text('This app can replace or accompany the photo log', style: Theme.of(context).textTheme.bodyText1),
                  Text('you are maintaining on paper. By automating the', style: Theme.of(context).textTheme.bodyText1),
                  Text('log, it saves you time and creates a cleaner', style: Theme.of(context).textTheme.bodyText1),
                  Text('method for sending your photo surveys.', style: Theme.of(context).textTheme.bodyText1),
                ],
              )
            ),
            Flexible(
                fit: FlexFit.loose,
                child: Column(
                  children: [

                    _startSurvey
                        ? Text('You\'ve already started a survey.\nTo continue tap the Survey tab', style: Theme.of(context).textTheme.headline6)
                        : Text('You haven\'t started a survey.\nTap the Survey tab to begin', style: Theme.of(context).textTheme.headline6)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}