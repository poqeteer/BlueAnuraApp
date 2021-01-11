import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/organization_model.dart';
import 'package:blue_anura/utils/storage_utils.dart';
import 'package:blue_anura/views/camera/camerawesome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:form_validator/form_validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:r_album/r_album.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

import 'album_page.dart';

class Survey extends StatefulWidget {
  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingController _orgTextController = new TextEditingController();
  TextEditingController _locTextController = new TextEditingController();
  // MaskedTextController _locTextController = new MaskedTextController(mask: '000', text: '');
  final focusLocation = FocusNode();

  Album _album;
  bool _loading = false;
  bool _activeSurvey = false;
  bool _hasMedia = false;
  int _mediaCount = 0;

  List<OrganizationModel> _organizations = [
     OrganizationModel(code: 'BeW', name: 'Beach Watch'),
     OrganizationModel(code: 'WWF', name: 'World Wildlife Fund'),
     OrganizationModel(code: 'EDF', name: 'Environmental Defense Fund'),
  ];
  OrganizationModel _organization;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  @override
  void dispose() {
    focusLocation.dispose();
    super.dispose();
  }

  Future<void> initAsync() async {
    // Create the album if it exists or not...
    await RAlbum.createAlbum(Constants.ALBUM_NAME).then((value) => print(value));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);

      Album blueAnuraAlbum;
      bool hasMedia = false;
      int mediaCount = 0;
      for(Album album in albums) {
        if (album.name == Constants.ALBUM_NAME) {
          blueAnuraAlbum = album;
          await album.listMedia()?.then(
                  (MediaPage media) {
                    hasMedia = media.items.isNotEmpty;
                    mediaCount = media.items.length;
                  }
          );  // Should just pass the media list along to Album?
              // Problem is who does the refresh?
          break;
        }
      }
      if (blueAnuraAlbum == null) print("----------\nalbum ${Constants.ALBUM_NAME} NOT found\n----------");
      else  print("----------\nalbum ${Constants.ALBUM_NAME} found\n----------");
      if (!hasMedia) print("----------\nalbum ${Constants.ALBUM_NAME} has NO media\n----------");
      else print("----------\nalbum ${Constants.ALBUM_NAME} HAS media\n----------");

      // if (!mounted) return;

      String pref = prefs.get(Constants.PREF_LAST_ORG) ?? "";
      if (!pref.contains("\{")) pref = _organizations[0].toJsonString();

      final orgPref = json.decode(pref);
      final index = _organizations.indexWhere((element) => element.code == orgPref["code"]);

      setState(() {
        _loading = false;
        _album = blueAnuraAlbum;
        _hasMedia = hasMedia;
        _mediaCount = mediaCount;
        _activeSurvey = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;
        if (!_activeSurvey) print("----------\nSurvey NOT started\n----------");
        else print("----------\nSurvey started\n----------");

        _organization = _organizations[index];

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

  void _launchCamera() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Camera())).then((result) async {
      if (result != null && result.contains(Constants.SAVED)) {
        print('-----------\n_launchCamera result: $result\n-----------');
        // ScaffoldMessenger.of(context)
        //   ..removeCurrentSnackBar()
        //   ..showSnackBar(SnackBar(content: Text("$result")));

        Directory dir = await StorageUtils.buildFolderPath('${Constants.BASE_ALBUM}/${Constants.ALBUM_NAME}');
        List<FileSystemEntity> list = await StorageUtils.dirContents(dir);

        // Refresh gallery/album...
        setState(() {
          _loading = true;
        });
        await initAsync();

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! KLUDGE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // Have to wait for the album to be loaded by the system if this the
        // 1st time or after an upload. This could take a second or 2, so loop
        // until it is found... And for some reason on may S9 it doesn't always
        // get all the images even though they are there so counts should match
        // ...
        // Hmmm... Now that I do the lookup of the directory, this doesn't seem
        // to be necessary... I'll leave it anyway.
        int count = 0;
        while(((!_hasMedia && _album == null) || _mediaCount < list.length) && count < 5) {
          print('-----------\nrefresh #: $count\n-----------');
          setState(() {
            _loading = true;
          });
          await initAsync();
          if (!_hasMedia && _album == null)
            sleep(Duration(seconds: 1));
          count++;
        }
        if (count == 5) {
          AlertDialog(title: Text('System error'), content: Text('Please exit application and reload!'));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
              preferredSize: Size.fromHeight(_hasMedia && _activeSurvey && !_loading ? 50.0 : 0.0),
              child: AppBar(title: Row(
                children: [
                  Text('Org: ${_organization?.code} | Loc: ${_locTextController.text}'),
                  Spacer(flex: 1),
                  DropdownButton(
                    icon: Icon(Icons.menu),
                    iconSize: 24,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.transparent,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.transparent,
                    ),
                    onChanged: _hasMedia && _activeSurvey // This should never happen... But "disables" the menu
                        ? (String newValue) async {
                          print('----------\nResetting prefs\n-----------');
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setInt(Constants.PREF_SEQUENCE, 1);
                          prefs.setBool(Constants.PREF_ACTIVE_SURVEY, false);

                          print('----------\nRemoving images\n-----------');
                          MediaPage _media = await _album.listMedia();
                          List<Medium> list = List.from(_media.items);
                          List<String> ids = [];
                          list.forEach((Medium element) {
                            ids.add(element.id);
                          });
                          PhotoManager.editor.deleteWithIds(ids);
                          // The deleted id will be returned, if it fails, an empty array will be returned.
                          //final List<String> result = await PhotoManager.editor.deleteWithIds(ids);
                          // print('----------\nFiles removed\n-----------');
                          // if (result.isNotEmpty) {
                          //   final Directory dir =
                          //   await StorageUtils.buildFolderPath(
                          //       '${Constants.BASE_ALBUM}/${Constants
                          //           .ALBUM_NAME}');
                          //   print('----------\nRemoving album folder\n-----------');
                          //   dir.deleteSync(recursive: true);
                          // } else {
                          //   print('----------\nError the deleteWithIds didn\'t work\n---------');
                          // }
                          print('----------\nReloading...\n-----------');
                          setState(() {
                            _loading = true;
                          });
                          // Kludge... This really isn't necessary but the
                          // PhotoManager call above doesn't come back using an
                          // await on SDK 30 and it does execute...
                          // So just wait a tick
                          sleep(const Duration(milliseconds: 500));

                          await initAsync();
                        }
                        : null,
                    items: <String>['Done']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _hasMedia && _activeSurvey
              ? AlbumPage(_album)
              : Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                            'To start the survey the following information is required:\n\n'
                                'Select the organization you are doing the survey for followed by the location identification number for the you are doing the survey.\n\n'
                                'When you have entered the information, tap the Continue button to take your first photo.'
                        ),
                      ),
                      // TextFormField(
                      //   autofocus: true,
                      //   decoration: const InputDecoration(
                      //     icon: const Icon(Icons.business),
                      //     hintText: 'Enter Organization Identifier',
                      //     labelText: 'Organization',
                      //   ),
                      //   controller: _orgTextController,
                      //   textInputAction:  TextInputAction.next,
                      //   onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusLocation),
                      //   validator: ValidationBuilder().minLength(1, "Organization ID is required").build(),
                      // ),
                      FormField<OrganizationModel>(
                        builder: (FormFieldState<OrganizationModel> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: const Icon(Icons.category_outlined),
                              labelText: 'Organization',
                              errorText: state.hasError ? state.errorText : null,
                            ),
                            isEmpty: _organization == null,
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton<OrganizationModel>(
                                value: _organization,
                                isDense: true,
                                onChanged: (OrganizationModel newValue) {
                                  setState(() {
                                    _organization = newValue;
                                  });
                                  state.didChange(newValue);
                                  FocusScope.of(context).requestFocus(focusLocation);
                                },
                                items: _organizations.map((OrganizationModel value) {
                                  return new DropdownMenuItem<OrganizationModel>(
                                    value: value,
                                    child: new Text(value.name),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      TextFormField(
                        focusNode: focusLocation,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.location_pin),
                          hintText: 'Enter Location Identifier',
                          labelText: 'Location',
                        ),
                        controller: _locTextController,
                        keyboardType: TextInputType.number,
                        textInputAction:  TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: ValidationBuilder().minLength(1, "Location ID is required").build(),
                        maxLength: 3,
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
                                    _organization = prefs.get(Constants.PREF_LAST_ORG) ?? _organizations;
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
                                      prefs.setString(Constants.PREF_LAST_ORG, _organization.toJsonString());
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
                ),
        floatingActionButton: _hasMedia && _activeSurvey
            ? FloatingActionButton(
                heroTag: "fabSurveyCamera",
                onPressed: _launchCamera,
                child: Icon(Icons.camera_alt),
                backgroundColor: Colors.green,
              )
            : SizedBox()
    );
  }
}
