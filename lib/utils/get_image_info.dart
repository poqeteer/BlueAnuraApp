import 'dart:io';
import 'dart:typed_data';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:exif/exif.dart';

class GetImageInfo {
  static Future<EXIFDataModel> readEXIF(File file) async {
    EXIFDataModel info = new EXIFDataModel();
    try {
      info.file = file;
      Uint8List bytes = await info.file.readAsBytes();
      Map<String, IfdTag> tags = await readExifFromBytes(bytes);

      info.surveyInfo = tags["Image ${Constants.EXIF_SURVEY}"].toString();

      // "EXIF UserComment" == abc_123_20210107_004.jpg|Cat|SubCat|Spec|Comment
      List<String> exifInfo = info.surveyInfo.split("|");
      if (exifInfo.isNotEmpty) {
        info.filename = exifInfo[0];
        info.category = exifInfo[1];
        info.subcategory = exifInfo[2];
        info.specimen = exifInfo[3];
        info.comment = exifInfo[4];
        info.sequence = info.filename.split("_")[3].substring(0, 3);
      } else info = null;
    } catch(e) {
      print('----------\nerror reading EXIF: $e\n----------');
      info = null;
    }
    return info;
  }
}