import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:blue_anura/constants.dart';

class BaseNavPage extends StatelessWidget {
  final String title;
  final Widget body;

  BaseNavPage({String title, Widget body}) : body = body, title = title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(title),
          backgroundColor: Constants.mainBackgroundColor,
        ),
        body: body
      ),
    );
  }
}
