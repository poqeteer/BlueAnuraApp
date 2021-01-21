import 'dart:io';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:blue_anura/utils/text_utils.dart';
import 'package:blue_anura/views/survey/survey_form_page.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:blue_anura/views/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

import 'package:photo_gallery/photo_gallery.dart';

class ReviewImagePage extends StatelessWidget {
  final File fileImage;
  final String title;
  final EXIFDataModel exifDataModel;

  ReviewImagePage(File fileImage, String title, EXIFDataModel exifDataModel) :
        fileImage = fileImage, title = title, exifDataModel = exifDataModel;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: BaseNavPage(
          title: title,
          subtitle: "Cat: ${TextUtils.ellipsis(exifDataModel.category, 10)}\n"
                    "SbC: ${TextUtils.ellipsis(exifDataModel.subcategory, 10)}\n"
                    "Spc: ${exifDataModel.specimen}"
                    "",
          body: Container(
            alignment: Alignment.center,
            child: ImageViewer(imageProvider: FileImage(fileImage)),
          ),
        ),
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: "fabViewBack",
            onPressed:  () => Navigator.pop(context),
            child: Padding(padding: EdgeInsets.only(left: 10.0), child: Icon(Icons.arrow_back_ios)),
            backgroundColor: Constants.mainBackgroundColor,
          ),
        ])
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
