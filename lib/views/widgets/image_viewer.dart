import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';

class ImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  const ImageViewer({
    Key key,
    this.imageProvider,
  }) : super(key: key);

  @override
  ImageViewerState createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
        Positioned.fill(child:
        InteractiveViewer(minScale: 1.0, maxScale: 3.0,
            child: ImageFade(
              image: widget.imageProvider,
              placeholder: Container(
                color: Color(0xFFCFCDCA),
                child: Center(child: Icon(Icons.photo, color: Colors.white30, size: 128.0,)),
              ),
              alignment: Alignment.center,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent event) {
                if (event == null) { return child; }
                return Center(
                  child: CircularProgressIndicator(
                      value: event.expectedTotalBytes == null ? 0.0 : event.cumulativeBytesLoaded / event.expectedTotalBytes
                  ),
                );
              },
              errorBuilder: (BuildContext context, Widget child, dynamic exception) {
                return Container(
                  color: Color(0xFF6F6D6A),
                  child: Center(child: Icon(Icons.warning, color: Colors.black26, size: 128.0)),
                );
              },
            )
          )),
      ]
    );
  }
}
