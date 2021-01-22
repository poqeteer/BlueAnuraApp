import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
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
      Permission.photos
    ].request();

    statuses.forEach((key, value) {
      print('$key: $value');
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _surveyStarted = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;
    });


    String currentLocale;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocale = await Devicelocale.currentLocale;
      print(currentLocale);
    } on PlatformException {
      print("Error obtaining current locale");
    }

    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
      timezone = "\n\nThe timezone is set to:\n\n  $timezone";
    } on PlatformException {
      print("Failed to get the timezone.");
      timezone = '';
    }

    try {
      DateTime ntpDate = await NTP.now();
      DateTime date = DateTime.now();
      prefs.setBool(Constants.PREF_TIME_CHECK, true);
      if (ntpDate.hour != date.hour || ntpDate.minute != date.minute ||
          ntpDate.day != date.day || ntpDate.month != date.month ||
          ntpDate.year != date.year) {
        String sysDisplayTime = '';
        String sysDisplayDate = date.toString();
        String ntpDisplayTime = '';
        String ntpDisplayDate = ntpDate.toString();
        if (currentLocale.isNotEmpty) {
          ntpDisplayDate = DateFormat.yMd(currentLocale).format(ntpDate);
          DateTime working = DateTime(ntpDate.year, ntpDate.month, ntpDate.day, ntpDate.hour, ntpDate.minute);
          DateFormat format = DateFormat.jm(currentLocale);
          ntpDisplayTime = format.format(working);
          sysDisplayDate = DateFormat.yMd(currentLocale).format(date);
          sysDisplayTime = format.format(date);
        }
        await showOkAlertDialog(
          context: context,
          title: 'System Time Error',
          message: 'It appears your system date and/or time aren\'t set '
              'correctly. Please update your settings.\n\n'
              'Your current date and time are:\n\n'
              ' $sysDisplayDate $sysDisplayTime$timezone\n\n'
              'According to the NTP (Network Time Protocol) for the '
              'current timezone, your date and time should be:\n\n'
              '  $ntpDisplayDate $ntpDisplayTime',
          okLabel: 'Ok',
        );
      }
    } catch (e) {
      bool timeChecked = prefs.getBool(Constants.PREF_TIME_CHECK) ?? false;
      if (!timeChecked) {
        prefs.setBool(Constants.PREF_TIME_CHECK, true);
        await showOkAlertDialog(
            context: context,
            title: 'System Time Warning',
            message: 'The application isn\'t unable to verify your date and time '
                'with the Network Time Protocol (NTP). Please verify that '
                'your date and time are correct.',
            okLabel: 'Ok'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width*0.8;
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
                width: cWidth,
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
                    width: cWidth,
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
                    width: cWidth,
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