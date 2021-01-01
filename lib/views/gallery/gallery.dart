import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'album_page.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
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
    return  _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : AlbumPage(_albums[0]);
  }
}
