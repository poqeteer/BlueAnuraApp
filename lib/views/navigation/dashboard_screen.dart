import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/first_camera.dart';
import 'package:blue_anura/views/camera/camerawesome.dart';
import 'package:blue_anura/views/widgets/option_button.dart';
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
    return NavigatorApp();
  }
}

const String _title = 'Blue Anura';

/// This is the main application widget.
class NavigatorApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: NavigatorStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class NavigatorStatefulWidget extends StatefulWidget {
  NavigatorStatefulWidget({Key key}) : super(key: key);

  @override
  _NavigatorStatefulWidgetState createState() => _NavigatorStatefulWidgetState();
}

/// This is the private State class that goes with NavigatorStatefulWidget.
class _NavigatorStatefulWidgetState extends State<NavigatorStatefulWidget>with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
      preferredSize: Size.fromHeight(85.0),
      child: AppBar(
        title: const Text(_title, style: TextStyle(fontFamily: "Grandstander", fontWeight: FontWeight.bold, fontSize: 24.0),),
        backgroundColor: Constants.mainBackgroundColor,
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.amber[800],
          tabs: [
            Tab(
              icon: Icon(Icons.home),
              // child: Text("Home"),
            ),
            Tab(
              icon: Icon(Icons.camera),
              // child: Text("Survey"),
            ),
            Tab(
              icon: Icon(Icons.location_pin),
              // child: Text("Send Location"),
            )
          ],
          controller: _tabController,
          indicatorColor: Colors.amber[800],
          indicatorSize: TabBarIndicatorSize.tab,
          ),
          bottomOpacity: 1,
        )
    ),
      body: TabBarView(
        children: [
          Home(),
          Camera(),
          SendLocation()
        ],
        controller: _tabController,
      ),
    );
  }
}
