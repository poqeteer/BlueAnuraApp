import 'dart:io';
import 'dart:typed_data';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:exif/exif.dart';

class GetImageInfo {
  static Future<EXIFDataModel> readEXIF(File file) async {
    EXIFDataModel info ;
    try {
      Uint8List bytes = await file.readAsBytes();
      Map<String, IfdTag> tags = await readExifFromBytes(bytes);

      String surveyInfo = tags["Image ${Constants.EXIF_SURVEY}"].toString();

      // "EXIF Image Description" == abc_123_20210107_004.jpg|Cat|SubCat|Spec|Comment
      List<String> exifInfo = surveyInfo.split("|");
      if (exifInfo.isNotEmpty) {
        info = new EXIFDataModel(
            surveyInfo: surveyInfo,
            filename: exifInfo[0],
            category: exifInfo[1],
            subcategory: exifInfo[2],
            specimen: exifInfo[3],
            comment: exifInfo[4],
            sequence: exifInfo[0].split("_")[3].substring(0, 3)
        );
      } else info = null;
    } catch(e) {
      print('----------\nerror reading EXIF: $e\n----------');
      info = null;
    }
    return info;
  }
}