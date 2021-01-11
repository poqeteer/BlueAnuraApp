import 'dart:io';

import 'package:blue_anura/constants.dart';
import 'package:blue_anura/views/survey/survey_form_page.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:blue_anura/views/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewPage extends StatefulWidget {
  final String filePath;

  PreviewPage(String filePath) : filePath = filePath;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String _title = '';

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int sequence = prefs.getInt(Constants.PREF_SEQUENCE);
    FileStat fs = await FileStat.stat(widget.filePath);
    DateTime date = fs.modified;
    String _sequence = sequence.toString().padLeft(3, '0') ?? '001';
    setState(() {
      _title = 'Preview #$_sequence @ ${date?.toLocal().toString()?.split(" ")[1].substring(0, 5)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final String filePath = widget.filePath;
    final File _image = File(filePath);

    return Scaffold(
        body: BaseNavPage(
          title: _title,
          body: Container(
            alignment: Alignment.center,
            child: ImageViewer(imageProvider: FileImage(_image)),
            ),
          ),
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: "fabCardReject",
            onPressed:  () => Navigator.pop(context),
            tooltip: 'Reject',
            child: Icon(Icons.clear),
            backgroundColor: Constants.mainBackgroundColor,
          ),
          SizedBox(width:20.0),
          FloatingActionButton(
            heroTag: "fabSurveyInfo",
            onPressed: () async {
              String result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SurveyFormPage(_title, _image, null)));
              if (result != Constants.CANCEL) {
                Navigator.pop(context, result);
              }
            },
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
        ]
        ));
  }
}

class VideoProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Videos are not supported at this time"),
    );
  }
}
