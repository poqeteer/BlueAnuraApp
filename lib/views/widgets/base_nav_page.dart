import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:blue_anura/constants.dart';

class BaseNavPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;

  BaseNavPage({String title, String subtitle, Widget body}) : body = body, title = title, subtitle = subtitle;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Row(children: [
            Text(title),
            Spacer(flex: 1),
            Text(subtitle ?? "", style: TextStyle(fontSize: 14, fontFamily: "AndaleMono"),)
          ]),
          backgroundColor: Constants.mainBackgroundColor,
        ),
        body: body
      ),
    );
  }
}
