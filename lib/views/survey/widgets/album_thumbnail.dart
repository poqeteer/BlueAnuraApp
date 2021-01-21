import 'dart:io';
import 'dart:typed_data';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:blue_anura/utils/get_image_info.dart';
import 'package:blue_anura/views/survey/survey_form_page.dart';
import 'package:blue_anura/views/survey/viewer_page.dart';
import 'package:blue_anura/views/widgets/labeled_text.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';

class AlbumThumbnail extends StatefulWidget {
  final Medium medium;
  final double gridWidth;
  final Uint8List kTransparentImage;
  const AlbumThumbnail({
    Key key,
    @required this.medium,
    @required this.gridWidth,
    @required this.kTransparentImage,
  }) : super(key: key);

  @override
  _AlbumThumbnailState createState() => _AlbumThumbnailState();
}

class _AlbumThumbnailState extends State<AlbumThumbnail> {
  EXIFDataModel _exifDataModel;
  String _title = "";
  String _category = "";
  String _subcategory = "";
  String _specimen = "";

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    if (!mounted) return;
    File file = await widget.medium.getFile();
    _exifDataModel = await GetImageInfo.readEXIF(file);

    String info;
    if (_exifDataModel != null) {
      // Extract the filename then get the last value and remove the extension to
      // get the sequence #
      info = "#${_exifDataModel.sequence} @ ";

      DateTime date = widget.medium.creationDate ?? widget.medium.modifiedDate;
      if (date != null) {
        // Only want the time at this point...
        info += date?.toLocal().toString()?.split(" ")[1].substring(0, 5);
      }

      // info += '\nCat: ${TextUtils.ellipsis(exifDataModel.category, 8)}\n'
      //     'SbC: ${TextUtils.ellipsis(exifDataModel.subcategory, 8)}\n'
      //     'Spc: ${exifDataModel.specimen}';
    } else {
      info = "Error... ";
    }

    setState(() {
      _title = info;
      _category = _exifDataModel?.category ?? "";
      _subcategory = _exifDataModel?.subcategory ?? "";
      _specimen = _exifDataModel?.specimen ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_exifDataModel != null) {
          File file = await widget.medium.getFile();
          String result = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SurveyFormPage(_title, file, _exifDataModel))
          );
          if (result != Constants.CANCEL) {
            await _initState();
          }
        } else {
          await showOkAlertDialog(
              context: context,
              title: 'Image Error',
              message: 'There appears to be something wrong with this image\'s data. '
                      'It cannot be reviewed.',
              okLabel: 'Ok'
          );

        }
      },
      child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                color: Colors.grey[300],
                height: widget.gridWidth,
                width: widget.gridWidth,
                child: FadeInImage(
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(widget.kTransparentImage),
                  image: ThumbnailProvider(
                    mediumId: widget.medium.id,
                    mediumType: widget.medium.mediumType,
                    highQuality: true,
                    width: 256,
                    height: 256,
                  ),
                ),
              ),
            ),
            Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 3.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledText("", _title, 16.0, widget.gridWidth - 4),
                    LabeledText("Cat", _category, 14.0, widget.gridWidth - 35),
                    LabeledText("SbC", _subcategory, 14.0, widget.gridWidth - 35),
                    LabeledText("Spc", _specimen, 14.0, widget.gridWidth - 35),
                  ],
              )
            ),
          ]
      ),
    );
  }
}
