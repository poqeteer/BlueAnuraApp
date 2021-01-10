import 'dart:io';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:blue_anura/utils/text_utils.dart';
import 'package:blue_anura/views/survey/survey_form_page.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:blue_anura/views/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

import 'package:photo_gallery/photo_gallery.dart';

class ViewerPage extends StatelessWidget {
  final Medium medium;
  final EXIFDataModel exifDataModel;

  ViewerPage(Medium medium, EXIFDataModel exifDataModel) : medium = medium, exifDataModel = exifDataModel;

  @override
  Widget build(BuildContext context) {
    DateTime date = medium.creationDate ?? medium.modifiedDate;
    String title = '${exifDataModel.sequence} @ ${date?.toLocal().toString()?.split(" ")[1].substring(0, 8)}';

    return Scaffold(
        body: BaseNavPage(
          title: title,
          subtitle: "Cat: ${TextUtils.ellipsis(exifDataModel.category, 10)}\n"
                    "SbC: ${TextUtils.ellipsis(exifDataModel.subcategory, 10)}\n"
                    "Spc: ${exifDataModel.specimen}",
          body: Container(
            alignment: Alignment.center,
            child: medium.mediumType == MediumType.image
                ? ImageViewer(imageProvider: PhotoProvider(mediumId: medium.id))
                : VideoProvider()
            ,
          ),
        ),
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: "fabViewBack",
            onPressed:  () => Navigator.pop(context),
            child: Padding(padding: EdgeInsets.only(left: 10.0), child:Icon(Icons.arrow_back_ios)),
            backgroundColor: Constants.mainBackgroundColor,
          ),
          SizedBox(width:20.0),
          FloatingActionButton(
          heroTag: "fabSurveyInfo",
          onPressed: () async {
            File file = await medium.getFile();
            String result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SurveyFormPage(title, file, exifDataModel)));
            if (result != Constants.CANCEL) {
              Navigator.pop(context, result);
            }
          },
            child: Icon(Icons.edit),
            backgroundColor: Colors.green,
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
