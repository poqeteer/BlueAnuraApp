import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/first_camera.dart';
import 'package:blue_anura/views/camera/camerawesome.dart';
import 'package:blue_anura/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:blue_anura/views/send_location/send_location.dart';
import 'package:blue_anura/views/screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return CitSciCamApp();
  }
}

const String _title = 'Blue Anura';

/// This is the main application widget.
class CitSciCamApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: CitSciCamStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class CitSciCamStatefulWidget extends StatefulWidget {
  CitSciCamStatefulWidget({Key key}) : super(key: key);

  @override
  _CitSciCamStatefulWidgetState createState() => _CitSciCamStatefulWidgetState();
}

/// This is the private State class that goes with CitSciCamStatefulWidget.
class _CitSciCamStatefulWidgetState extends State<CitSciCamStatefulWidget> {
  int _selectedIndex = 0;
  // static const TextStyle optionStyle =
  // TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text(
  //     'Index 0: Home',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 1: Business',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 2: School',
  //     style: optionStyle,
  //   ),
  // ];
  List<Widget> _widgetOptions = <Widget>[

    Home(),
    // FirstCamera().camera == null ? Screen(title: "No camera available"):
    Camera(),
    SendLocation(),

  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title, style: TextStyle(fontFamily: "Grandstander", fontWeight: FontWeight.bold, fontSize: 24.0),),
        backgroundColor: Constants.mainBackgroundColor,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.linked_camera),
            label: 'Survey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'Send Location',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
