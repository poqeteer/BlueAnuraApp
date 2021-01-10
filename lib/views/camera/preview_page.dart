import 'dart:io';

import 'package:blue_anura/constants.dart';
import 'package:blue_anura/views/survey/survey_form_page.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:blue_anura/views/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  final String filePath;

  PreviewPage(String filePath) : filePath = filePath;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  DateTime date;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState () async {

    FileStat fs = await FileStat.stat(widget.filePath);
    setState(() {
      date = fs.modified;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String filePath = widget.filePath;
    final File _image = File(filePath);

    return Scaffold(
        body: BaseNavPage(
          title: date?.toLocal().toString(),
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
                  builder: (context) => SurveyFormPage(date?.toLocal().toString(), _image, null)));
              if (result != Constants.CANCEL) {
                Navigator.pop(context, result);
              }
            },
            child: Icon(Icons.edit),
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
