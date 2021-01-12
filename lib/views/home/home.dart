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
  bool _surveyStarted = false;

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
      _surveyStarted = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.8;
    FocusScope.of(context).unfocus();
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
                        child: Text('Welcome to Blue Anura\'s', 
                            style: Theme.of(context).textTheme.headline6)
                    ),
                    Center(
                        child: Text('Survey Camera Application', 
                            style: Theme.of(context).textTheme.headline5)
                    ),
                    Center(
                        child: Text('Version ${AppInfo().version}.${AppInfo().buildNum}', 
                            style: Theme.of(context).textTheme.subtitle1)
                    ),
                  ],
                ),
            ),
            Container (
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                width: c_width,
                child: Column(
                children: [
                  Text('This app can replace or accompany the photo log you\'re'
                       ' maintaining on paper. By automating the log, it saves '
                       'you time and creates a simpler method for sending your '
                       'photo surveys.',
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              )
            ),
            Flexible(
                fit: FlexFit.loose,
                child: Container (
                    padding: EdgeInsets.all(16.0),
                    width: c_width,
                    child: Column(
                      children: [
                        Divider(
                            height: 10.0,
                            color: Theme.of(context).primaryColor),
                        Text(''),
                        Text('Your ad or branding or message goes here!',
                            style: TextStyle(
                                fontFamily: "Grandstander",
                                fontSize: 30,
                                color: Colors.red,
                                fontWeight: FontWeight.w900)),
                      ],
                    ))
            ),
            Flexible(
                fit: FlexFit.tight,
                child: Container (
                    padding: EdgeInsets.all(16.0),
                    width: c_width,
                    child: Column(
                  children: [
                    Divider(
                        height: 10.0,
                        color: Theme.of(context).primaryColor),
                    Text(''),
                    _surveyStarted
                        ? Column(children: [
                              Text('You\'ve already started a survey. To '
                                   'continue go to the Survey tab',
                                  style: Theme.of(context).textTheme.headline6),
                              Text(''),
                              Text('When done with your survey, tap the menu '
                                   'icon located in the upper right in the '
                                   'Survey tab.',
                                  style: Theme.of(context).textTheme.bodyText1),
                            ]
                          )
                        : Text('You haven\'t started a survey. Tap the Survey '
                               'tab to begin',
                              style: Theme.of(context).textTheme.headline6),
                  ],
                )
            )),
          ],
        ),
      ),
    );
  }
}