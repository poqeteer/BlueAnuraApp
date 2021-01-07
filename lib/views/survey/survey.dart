import 'dart:async';
import 'dart:io';

import 'package:blue_anura/constants.dart';
import 'package:blue_anura/views/camera/camerawesome.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:r_album/r_album.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'album_page.dart';

class Survey extends StatefulWidget {
  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _orgTextController = new TextEditingController();
  TextEditingController _locTextController = new TextEditingController();

  Album _album;
  bool _loading = false;
  bool _activeSurvey = false;
  bool _hasMedia = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    // Create the album if it exists or not...
    await RAlbum.createAlbum(Constants.ALBUM_NAME).then((value) => print(value));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);

      Album blueAnuraAlbum;
      for(Album album in albums) {
        if (album.name == Constants.ALBUM_NAME) {
          blueAnuraAlbum = album;
          await album.listMedia().then(
                  (MediaPage media) =>
                    _hasMedia = media.items.isNotEmpty
          );  // Should just pass the media list along to Album?
                                                                                                  // Problem is who does the refresh?
          break;
        }
      }

      if (!mounted) return;

      if (blueAnuraAlbum == null) print("----------\nalbum ${Constants.ALBUM_NAME} not found\n----------");

      setState(() {
        _album = blueAnuraAlbum;
        _loading = false;
        _activeSurvey = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;

        _orgTextController.text = prefs.get(Constants.PREF_LAST_ORG) ?? "";
        _locTextController.text = prefs.get(Constants.PREF_LAST_LOC) ?? "";
      });
    }
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
        await Permission.storage.request().isGranted &&
        await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _launchCamera() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Camera()));
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
      setState(() {
        _loading = true;
      });
    }
    await initAsync();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: PreferredSize(
              preferredSize: Size.fromHeight(_hasMedia && _activeSurvey ? 50.0 : 0.0),
              child: AppBar(title: Text('Organization: ${_orgTextController.text} | Location: ${_locTextController.text}'))
            ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _hasMedia && _activeSurvey
              ? AlbumPage(_album)
              :Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                      'Obviously a dummy form for now...\n\nProbably some sort of list of organizations and a curated list of locations?\n\nFull page is overkill. Probably should just be a dialog.'
                  ),
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.business),
                    hintText: 'Enter Organization Identifier',
                    labelText: 'Organization',
                  ),
                  controller: _orgTextController,
                  textInputAction:  TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: ValidationBuilder().minLength(1, "Organization ID is required").build(),
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.location_pin),
                    hintText: 'Enter Location Identifier',
                    labelText: 'Location',
                  ),
                  controller: _locTextController,
                  textInputAction:  TextInputAction.next,
                  validator: ValidationBuilder().minLength(1, "Location ID is required").build(),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _orgTextController.text = prefs.get(Constants.PREF_LAST_ORG) ?? "";
                              _locTextController.text = prefs.get(Constants.PREF_LAST_LOC) ?? "";
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
                                SharedPreferences prefs = await SharedPreferences
                                    .getInstance();
                                prefs.setString(Constants.PREF_LAST_ORG, _orgTextController
                                    .text);
                                prefs.setString(Constants.PREF_LAST_LOC, _locTextController
                                    .text);
                                prefs.setBool(Constants.PREF_ACTIVE_SURVEY, true);
                                _launchCamera();
                              }
                            },
                            child: Text('Continue')
                        ),
                      ],
                    )
                ),
              ],
            )

                )
        ,
        floatingActionButton: _hasMedia && _activeSurvey
            ? FloatingActionButton(
                onPressed: _launchCamera,
                child: Icon(Icons.add),
                backgroundColor: Colors.green,
              )
            : SizedBox()
    );

  }
}

// Future<String> _getEXIFInfo(File _image) async {
//   var bytes = await _image.readAsBytes();
//   var tags = await readExifFromBytes(bytes);
//   List<String> userComment;
//
//   tags.forEach((k, v) {
//     if (k.contains("User")) userComment = v.toString().split('|');
//   });
//
//   if (userComment.length > 2)
//     return '${userComment[1]} :: ${userComment[3]}';
//   return "Old picture";
// }
// FutureBuilder(
// future: _getEXIFInfo(files[index]),
// builder: (BuildContext context, AsyncSnapshot snapshot) {
// if (snapshot.connectionState == ConnectionState.done) {
// return Text(snapshot.data, style: TextStyle(color: Colors.white, fontSize: 12.0));
// }
// return SizedBox();
// }
// ),
// ]),

