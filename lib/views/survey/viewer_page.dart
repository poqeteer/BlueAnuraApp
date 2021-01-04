import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:flutter/material.dart';

import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime date = medium.creationDate ?? medium.modifiedDate;
    return BaseNavPage(
      title: date?.toLocal().toString(),
      body: Container(
        alignment: Alignment.center,
        child: medium.mediumType == MediumType.image
            ? ClipRect(child: InteractiveViewer(minScale: 1.0, maxScale: 3.0, child:  FadeInImage(
          fit: BoxFit.cover,
          placeholder: MemoryImage(kTransparentImage),
          image: PhotoProvider(mediumId: medium.id),
        )))
            : VideoProvider(),
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
