import 'dart:async';
import 'dart:io';

import 'package:blue_anura/views/camera/camerawesome.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'album_page.dart';

class Survey extends StatefulWidget {
  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  List<Album> _albums;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
      await PhotoGallery.listAlbums(mediumType: MediumType.image);

      List<Album> blueAnuraAlbum = [];
      for(Album album in albums) {
        if (album.name == 'BlueAnura') {
          blueAnuraAlbum.add(album);
        }
      }

      setState(() {
        _albums = blueAnuraAlbum;
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : _albums == null || _albums.isEmpty
            ? Center(child: Text("Survey not started yet"))
            : AlbumPage(_albums[0]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Camera()));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        )
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

