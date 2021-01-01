import 'package:blue_anura/views/gallery/viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:photo_gallery/photo_gallery.dart';
import 'package:flutter/rendering.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage(Album album) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium> _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = List.from(mediaPage.items.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      LayoutBuilder(
        builder: (context, constraints) {
          double gridWidth = (constraints.maxWidth - 20) / 3;
          double gridHeight = gridWidth + 33;
          double ratio = gridWidth / gridHeight;
          return Container(
            padding: EdgeInsets.all(5),
            child: GridView.count(
              childAspectRatio: ratio,
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              children: <Widget>[
                ...?_media?.map(
                      (medium) =>
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ViewerPage(medium))),
                        child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  color: Colors.grey[300],
                                  height: gridWidth,
                                  width: gridWidth,
                                  child: FadeInImage(
                                    fit: BoxFit.cover,
                                    placeholder: MemoryImage(kTransparentImage),
                                    image: ThumbnailProvider(
                                      mediumId: medium.id,
                                      mediumType: medium.mediumType,
                                      highQuality: true,
                                      width: 256,
                                      height: 256,
                                    ),
                                  ),
                                ),

                              ),
                              Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: getTextDate(medium)
                              ),
                            ]
                        ),
                      ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showOkAlertDialog(title: "link to Camera", message: "TBD", context: context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

Widget getTextDate(Medium medium) {
  DateTime date = medium.creationDate ??
      medium.modifiedDate;
  String d = date?.toLocal().toString().split(" ")[1].substring(0, 8);
  return Text(d,
      maxLines: 1,
      textAlign: TextAlign.start,
      style: TextStyle(
        height: 1.2,
        fontSize: 16,
      )
  );
}

