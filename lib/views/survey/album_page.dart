import 'package:blue_anura/views/survey/album_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:photo_gallery/photo_gallery.dart';
import 'package:flutter/rendering.dart';
import 'package:transparent_image/transparent_image.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage(Album album) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium> _media;
  bool _loading = true;

  Widget gallery = Center(child: Text("Not started"),);
  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = List.from(mediaPage.items.reversed);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          :
      LayoutBuilder(
        builder: (context, constraints) {
          double gridWidth = (constraints.maxWidth - 20) / 3;
          double gridHeight = gridWidth + 73;
          double ratio = gridWidth / gridHeight;
          return Container(
            padding: EdgeInsets.all(5),
            child: _media ==null || _media.isEmpty
                ? SizedBox()
                : GridView.count(
              childAspectRatio: ratio,
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              children: <Widget>[
                ...?_media?.map(
                      (medium) => AlbumThumbnail(medium: medium, gridWidth: gridWidth, kTransparentImage: kTransparentImage)
                      // GestureDetector(
                      //   onTap: () =>
                      //       Navigator.of(context).push(MaterialPageRoute(
                      //           builder: (context) => ViewerPage(medium))),
                      //   child: Column(
                      //       children: [
                      //         ClipRRect(
                      //           borderRadius: BorderRadius.circular(5.0),
                      //           child: Container(
                      //             color: Colors.grey[300],
                      //             height: gridWidth,
                      //             width: gridWidth,
                      //             child: FadeInImage(
                      //               fit: BoxFit.cover,
                      //               placeholder: MemoryImage(kTransparentImage),
                      //               image: ThumbnailProvider(
                      //                 mediumId: medium.id,
                      //                 mediumType: medium.mediumType,
                      //                 highQuality: true,
                      //                 width: 256,
                      //                 height: 256,
                      //               ),
                      //             ),
                      //           ),
                      //
                      //         ),
                      //         Container(
                      //             alignment: Alignment.topLeft,
                      //             padding: EdgeInsets.only(left: 2.0),
                      //             child: FutureBuilder<String>(
                      //               future: GetImageInfo.generateSubtitle(medium),
                      //               builder: (BuildContext context, AsyncSnapshot<String> result) {
                      //                 if (result.connectionState == ConnectionState.waiting) return SizedBox();
                      //                 return Text(result.data,
                      //                     maxLines: 4,
                      //                     textAlign: TextAlign.start,
                      //                     style: TextStyle(
                      //                       height: 1.2,
                      //                       fontSize: 16,
                      //                     )
                      //                 );
                      //
                      //               },
                      //             )
                      //         ),
                      //       ]
                      //   ),
                      // ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
