import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:blue_anura/utils/get_location.dart';
import 'package:blue_anura/utils/storage_utils.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:location/location.dart';
import 'package:r_album/r_album.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:image_native_resizer/image_native_resizer.dart';

class SurveyCardPage extends StatefulWidget {
  final String filePath;

  SurveyCardPage(String filePath) : filePath = filePath;

  @override
  _SurveyCardPageState createState() => _SurveyCardPageState();
}

class _SurveyCardPageState extends State<SurveyCardPage> {
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

    return BaseNavPage(
      title: date?.toLocal().toString(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            ClipRect(child: InteractiveViewer(minScale: 1.0, maxScale: 3.0,
              child: Image(image: FileImage(_image)),
            )),
            Row(
              children: [
                ElevatedButton(
                  child: Text("Save"),
                  onPressed: () async {
                    Stopwatch stopwatch = new Stopwatch()..start();

                    LocationData _location;
                    try {
                      _location = await BuildLocation.buildLocationText();
                    } catch(e) {
                      await showOkAlertDialog(title: "Location Error", message: e.toString(), context: context);
                    }
                    if (_location != null)
                      try {
                        print('got location: ${stopwatch.elapsed}');
                        final exif = FlutterExif.fromPath(filePath);
                        print('read exif: ${stopwatch.elapsed}');
                        await exif.setLatLong(_location.latitude, _location.longitude);
                        await exif.setAttribute("UserComment",
                            "ASCII\0\0\0${filePath.split('/').last}|Cat|SubCat|Spec|Comment|${AppInfo().version}.${AppInfo().buildNum}");

                        // apply attributes
                        await exif.saveAttributes();
                        print('save exif: ${stopwatch.elapsed}');
                        print("----------------------------------");
                        // print('exif: ${stopwatch.elapsed}');
                        print("exif updated: $_location");
                        print("----------------------------------");
                     } catch (e) {
                        print("==================================");
                        print(e.toString());
                        await showOkAlertDialog(title: "EXIF Error", message: e.toString(), context: context);
                        print("==================================");
                      }

                    await RAlbum.saveAlbum(Constants.ALBUM_NAME, [filePath]).then((value) {
                      print('----------\nSaved to album: $value[0]\n---------');
                      print('save to album: ${stopwatch.elapsed}');

                      // String ourFileName = filePath.split('/').last;
                      // String tempFileName = value[0].split('/').last;
                      // String albumPath = value[0].replaceFirst('$tempFileName', '');
                      // File f = File(value[0]).renameSync('$albumPath$ourFileName');
                      // print('----------\nRenamed to: ${f.path}\n---------');
                    });

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    int sequence = (prefs.getInt(Constants.PREF_SEQUENCE) ?? 1) + 1;
                    prefs.setInt(Constants.PREF_SEQUENCE, sequence);

                    _image.delete();

                    Navigator.pop(context, "Saved");
                  },
                ),
                ElevatedButton(
                  child: Text("Reject"),
                  onPressed: () {
                    _image.delete();
                    Navigator.pop(context, "Rejected");
                  },
                )
              ],
            )
          ]
        ),
      ),
    );
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
