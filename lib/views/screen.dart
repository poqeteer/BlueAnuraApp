import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  final String title;
  Screen({this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title),
      ),
    );
  }
}