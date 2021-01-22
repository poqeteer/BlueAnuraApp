// import 'dart:math';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:blue_anura/utils/get_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:platform_date_picker/platform_date_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:location/location.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:form_validator/form_validator.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendLocation extends StatefulWidget {
  SendLocation({Key key}) : super(key: key);

  @override
  _SendLocationState createState() => _SendLocationState();
}

class _SendLocationState extends State<SendLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameTextController = new TextEditingController();
  MaskedTextController _phoneTextController = new MaskedTextController(mask: '(000) 000-0000', text: '');
  TextEditingController _emailTextController = new TextEditingController();

  TextEditingController _dateTextController = new TextEditingController();
  TextEditingController _timeTextController = new TextEditingController();

  bool _showDateTime = false;

  // Use these because the built in validators aren't very good...
  RegExp _emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  RegExp _phoneRegExp = RegExp(r"^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$");

  final Location location = Location();
  LocationData _locationData;

  bool _doneOnce = false;
  String _locationText = 'Looking up location...';

  String _locale;

  TextInputType phoneKeyboardType = TextInputType.phone;
  final focusPhone = FocusNode();
  final focusEmail = FocusNode();
  Widget phoneButton = SizedBox();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    if ( Platform.operatingSystem == 'ios')
      // phoneKeyboardType = TextInputType.text;
      focusPhone.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if ( Platform.operatingSystem == 'ios')
      focusPhone.removeListener(_handleFocusChange);
    focusPhone.dispose();
    focusEmail.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if ( Platform.operatingSystem == 'ios')
      if (focusPhone.hasFocus) {
        setState(() {_showFloatingButton = true;});
      } else {
        setState(() {_showFloatingButton = false;});
      }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String currentLocale;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocale = await Devicelocale.currentLocale;
      print(currentLocale);
    } on PlatformException {
      print("Error obtaining current locale");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _nameTextController.text = prefs.get('name') ?? "";
      _phoneTextController.text = prefs.get('phone') ?? "";
      _emailTextController.text = prefs.get('email') ?? "";

      _locale = currentLocale;
      _dateTextController.text = DateFormat.yMd(_locale).format(DateTime.now());
      _timeTextController.text = formatTime(TimeOfDay.now(), _locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);

    void buildLocationText() async {
      if (_doneOnce || !mounted) return;
      _doneOnce = true;

      LocationData location;
      String err;
      try {
        location = await BuildLocation.buildLocationText();
      } catch (e) {
        await showOkAlertDialog(title: "Location Error",
            message: e.toString(),
            context: context);
        err = e.toString();
      }

      if (err == null) {
        if (mounted)
          setState(() {
            _locationText = "Location: ${location.latitude} / ${location.longitude}";
            _locationData = location;
          },);
      } else {
        if (mounted)
          setState(() {
            _locationText = err;
          });
      }
    }

    // Where's my useEffect??? LoL...
    buildLocationText();

    return Scaffold(
      body: SafeArea(
          top: false,
          bottom: false,
          child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                        'This will create a message with the location. Please send at your earliest opportunity.'
                    ),
                  ),
                  OutlinedButton(
                    child: Text(_locationText),
                    onPressed: () => setState(() {_doneOnce = false; _locationText = "Looking up location..."; }),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Enter your first and last name',
                      labelText: 'My Name',
                    ),
                    controller: _nameTextController,
                    textInputAction:  TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusPhone),
                    validator: ValidationBuilder().minLength(2, "Entering your name is required").build(),
                  ),
                  TextFormField(
                    focusNode: focusPhone,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.phone),
                      hintText: '(000) 000-0000',
                      labelText: 'My Phone Number',
                    ),
                    keyboardType: phoneKeyboardType,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _phoneTextController,
                    textInputAction:  TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusEmail),
                    validator: ValidationBuilder().regExp(_phoneRegExp, "Your phone number is required").build(),
                  ),
                  TextFormField(
                    focusNode: focusEmail,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: 'Enter your email address',
                      labelText: 'My Email Address',
                    ),
                    controller: _emailTextController,
                    textInputAction:  TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationBuilder().regExp(_emailRegExp, "Your valid email is required").build(),
                  ),
                  _showDateTime
                      ? Row (
                    children: <Widget> [
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.calendar_today),
                                  labelText: 'Today\'s Date',
                                ),
                                controller: _dateTextController,
                                readOnly: true,
                                onTap: () async {
                                  DateTime temp = await PlatformDatePicker.showDate(
                                    context: context,
                                    firstDate: DateTime(DateTime.now().year - 2),
                                    initialDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 2),
                                    builder: (context, child) => Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: const Color(0xFF8CE7F1),
                                        accentColor: const Color(0xFF8CE7F1),
                                        colorScheme:
                                        ColorScheme.light(primary: const Color(0xFF8CE7F1)),
                                        buttonTheme:
                                        ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                      ),
                                      child: child,
                                    ),
                                  );
                                  if (temp != null) {
                                    setState(() {_dateTextController.text = DateFormat.yMd(_locale).format(temp);});
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.access_alarm),
                                  labelText: 'Time now',
                                ),
                                controller: _timeTextController,
                                readOnly: true,
                                onTap: () async {
                                  TimeOfDay temp = await PlatformDatePicker.showTime(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (temp != null) {
                                    setState(() {_timeTextController.text = formatTime(temp, _locale);});
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      : SizedBox()
                  ,
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              setState(() {
                                _nameTextController.text = prefs.get('name') ?? "";
                                _phoneTextController.text = prefs.get('phone') ?? "";
                                _emailTextController.text = prefs.get('email') ?? "";
                                _dateTextController.text = DateFormat.yMd(_locale).format(DateTime.now());
                                _timeTextController.text = formatTime(TimeOfDay.now(), _locale);
                              });
                            },
                            child: Text('RESET'),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false
                              // otherwise.
                              if (_formKey.currentState.validate()) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString('name', _nameTextController.text);
                                prefs.setString('phone', _phoneTextController.text);
                                prefs.setString('email', _emailTextController.text);

                                final url = "https://maps.google.com/maps?q=" +
                                    _locationData.latitude.toString() +
                                    "%2C" +
                                    _locationData.longitude.toString();

                                String message = "From: " +
                                    _nameTextController.text + "\n" +
                                    _phoneTextController.text + "\n" +
                                    _emailTextController.text + "\n\n" +
                                    _dateTextController.text + " " +
                                    _timeTextController.text + "\n" +
                                    "I am here: " +
                                        _locationData.latitude.toString() + " / " +
                                        _locationData.longitude.toString() +
                                    "\n\n" +
                                    "model: ${AppInfo().deviceModel}\n" +
                                    "os: ${AppInfo().osInfo}\n" +
                                    "blueanura: ${AppInfo().version}.${AppInfo().buildNum}" +
                                    "\n\n" +
                                    url + "\n\n" +
                                    "Accuracy: " +
                                    _locationData.accuracy.toStringAsFixed(2) + "m\n" +
                                    "Altitude: " +
                                    _locationData.altitude.toStringAsFixed(2) + "m";
                                await Share.share(message);
                                // _onBasicAlertPressed(
                                //     context, "Message", message);
                              }
                            },
                            child: Text('Send Location'),
                          ),
                        ],
                      )
                  ),
                ],
              ))),
      floatingActionButton: Visibility(
        visible: _showFloatingButton,
        child: FloatingActionButton.extended(
            onPressed: () {
              FocusScope.of(context).requestFocus(focusEmail);
            },
            label: Text('   Next   '),
            icon: Icon(Icons.navigate_next),
            backgroundColor: Colors.grey,
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

String formatTime(TimeOfDay time, String locale) {
  DateTime current = new DateTime.now();
  current = DateTime(
      current.year, current.month, current.day, time.hour, time.minute);
  DateFormat format = DateFormat.jm(locale);
  return format.format(current);
}

// String convertDEGToDMS (double deg, bool lat) {
//   double dp(double val, int places){
//     double mod = pow(10.0, places);
//     return ((val * mod).round().toDouble() / mod);
//   }
//   double absolute = deg.abs();
//
//   int degrees = absolute.floor();
//   double minutesNotTruncated = (absolute - degrees) * 60;
//   int minutes = minutesNotTruncated.floor();
//   double seconds = (minutesNotTruncated - minutes) * 60;
//
//   String direction = "";
//   if (lat) {
//     direction = deg >= 0 ? "N" : "S";
//   } else {
//     direction = deg >= 0 ? "E" : "W";
//   }
//
//   return degrees.toString() + "°" + minutes.toString() + "'" + dp(seconds, 1).toString() + '"' + direction;
// }
