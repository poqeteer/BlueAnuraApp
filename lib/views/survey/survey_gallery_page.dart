import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/organization_model.dart';
import 'package:blue_anura/utils/storage_utils.dart';
import 'package:blue_anura/views/camera/camerawesome_page.dart';
import 'package:blue_anura/views/survey/widgets/survey_info_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:r_album/r_album.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

import 'album_page.dart';

enum Selection {edit, done}

class Survey extends StatefulWidget {
  final TabController tabController;

  Survey({TabController tabController}) : tabController = tabController;

  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  Album _album;
  bool _loading = false;
  bool _activeSurvey = false;
  bool _hasMedia = false;
  bool _displayButton = true;
  int _mediaCount = 0;
  String _location = "";
  OrganizationModel _organization;

  SharedPreferences _prefs;

  // This needs to looked up somewhere...
  List<OrganizationModel> _organizationList = [
     OrganizationModel(code: 'BeW', name: 'Beach Watch'),
     OrganizationModel(code: 'WWF', name: 'World Wildlife Fund'),
     OrganizationModel(code: 'EDF', name: 'Environmental Defense Fund'),
  ];

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting() && mounted) {
      // Create the album if it exists or not...
      await RAlbum.createAlbum(Constants.ALBUM_NAME).then((value) => print(value));

      SharedPreferences prefs = await SharedPreferences.getInstance();

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
      if (!pref.contains("\{")) pref = _organizationList[0].toJsonString();

      final orgPref = json.decode(pref);
      final index = _organizationList.indexWhere((element) => element.code == orgPref["code"]);

      setState(() {
        _loading = false;
        _album = blueAnuraAlbum;
        _hasMedia = hasMedia;
        _mediaCount = mediaCount;
        _activeSurvey = prefs.getBool(Constants.PREF_ACTIVE_SURVEY) ?? false;
        if (!_activeSurvey) print("----------\nSurvey NOT started\n----------");
        else print("----------\nSurvey started\n----------");

        _organization = _organizationList[index];
        _location = prefs.get(Constants.PREF_LAST_LOC) ?? "";

        _prefs = prefs;
      });
    }
    await _checkSurveyStarted();
  }

  Future<void> _checkSurveyStarted() async {
    if (!_activeSurvey || _location == '') {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
                child: SurveyInfoDialog(
                context: context,
                saveButtonText: "Continue",
                cancelButton: false,
                organizationList: _organizationList,
                organizationModel: _organization,
                location: _location,
                onSave: (OrganizationModel organizationModel,
                    String location) {
                  _prefs.setBool(Constants.PREF_ACTIVE_SURVEY, true);
                  _prefs.setString(Constants.PREF_LAST_ORG, organizationModel.toJsonString());
                  _prefs.setString(Constants.PREF_LAST_LOC, location);

                  _launchCamera();

                  setState(() {
                    _organization = organizationModel;
                    _location = location;
                    _activeSurvey = true;
                  });
                }),
              onWillPop: () async {
                  // If they tapped the back button, go to the home page
                  widget.tabController.animateTo(0);
                  return true;
                  },
            );
          }
      );
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
      // if (result != null && result.contains(Constants.SAVED)) {
      {
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
      // } else {
      //   _checkSurveyStarted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Scaffold(
        appBar: PreferredSize(
              preferredSize: Size.fromHeight(_location != '' && !_loading && _activeSurvey ? 50.0 : 0.0),
              child: AppBar(title: Row(
                children: [
                  Text('Org: ${_organization?.code} | Loc: $_location'),
                  Spacer(flex: 1),
                  _popupMenuButton(),
                ],
              ),
            ),
        ),
        body: (_loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _hasMedia && _activeSurvey
              ? AlbumPage(_album)
              : _activeSurvey
                ? Center(
                    child: Column(children: [Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text("You don't have any photos in this survey yet. "
                            "Tap the camera button below to add photos.\n\nIf you "
                            "want to change the organization or location main "
                            "survey information, tap the menu button on the upper "
                            "right and select 'Edit Main Info'",
                            style: Theme.of(context).textTheme.headline6)
                    )])
                  )
                : SizedBox()
            ),
        floatingActionButton: _activeSurvey && _displayButton
            ? FloatingActionButton(
                heroTag: "fabSurveyCamera",
                onPressed: _launchCamera,
                child: Icon(Icons.camera_alt),
                backgroundColor: Colors.green,
              )
            : SizedBox()
    );
  }

  Widget _popupMenuButton() {
    return PopupMenuButton(
        icon: Icon(Icons.menu),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Selection>>[
          PopupMenuItem(
            value: Selection.edit,
            child: Text("Edit Main Info")
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            enabled: _hasMedia,
            value: Selection.done,
            child: Text("Done Upload")
          ),
        ],
        onSelected: (Selection result) async {
          switch (result) {
            case Selection.edit:
              setState(() {
                _displayButton = false;
              });
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SurveyInfoDialog(
                      context: context,
                      saveButtonText: "Save",
                      cancelButton: true,
                      organizationList: _organizationList,
                      organizationModel: _organization,
                      location: _location,
                      onSave: (OrganizationModel organizationModel, String location) {
                        _prefs.setString(Constants.PREF_LAST_ORG, organizationModel.toJsonString());
                        _prefs.setString(Constants.PREF_LAST_LOC, location);
                        setState(() {
                          _organization = organizationModel;
                          _location = location;
                        });
                      }
                  );
                }
              );
              setState(() {
                _displayButton = true;
              });
              break;

            case Selection.done:
            case Selection.edit:
              OkCancelResult result = await showOkCancelAlertDialog(
                context: context,
                title: 'Finished with Survey',
                message: 'You are about to upload your survey photo log and files. '
                    'This will close this survey and you will not be able continue '
                    'with any other actions in this survey.\n\nAre you sure?',
                okLabel: 'Yes',
                cancelLabel: 'No'
              );
              if (result == OkCancelResult.ok) {
                print('----------\nResetting prefs\n-----------');
                _prefs.setInt(Constants.PREF_SEQUENCE, 1);
                _prefs.setBool(Constants.PREF_ACTIVE_SURVEY, false);

                print('----------\nRemoving images\n-----------');
                MediaPage _media = await _album.listMedia();
                List<Medium> list = List.from(_media.items);
                List<String> ids = [];
                list.forEach((Medium element) {
                  ids.add(element.id);
                });
                await PhotoManager.editor.deleteWithIds(ids);
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
              break;
          }
        },
    );
  }
}
