import 'package:flutter/material.dart';


class Constants {
  static const MaterialColor mainBackgroundColor = MaterialColor(0xFF557A95,
    {
      50:Color.fromRGBO(85, 122, 149, .1),
      100:Color.fromRGBO(85, 122, 149, .2),
      200:Color.fromRGBO(85, 122, 149, .3),
      300:Color.fromRGBO(85, 122, 149, .4),
      400:Color.fromRGBO(85, 122, 149, 1),
      500:Color.fromRGBO(85, 122, 149, .6),
      600:Color.fromRGBO(85, 122, 149, .7),
      700:Color.fromRGBO(85, 122, 149, .8),
      800:Color.fromRGBO(85, 122, 149, .9),
      900:Color.fromRGBO(85, 122, 149, 1),
    });

  static const String BASE_ALBUM = "DCIM";
  static const String ALBUM_NAME = "BlueAnura";

  static const String PREF_NAME = 'name';
  static const String PREF_EMAIL = 'email';
  static const String PREF_PHONE = 'phone';
  static const String PREF_LAST_ORG = 'lastOrg';
  static const String PREF_LAST_LOC = 'lastLoc';
  static const String PREF_ACTIVE_SURVEY = 'activeSurvey';
  static const String PREF_SEQUENCE = 'sequence';
  static const String PREF_LAST_CATEGORY = 'lastCategory';
  static const String PREF_LAST_SUBCATEGORY = 'lastSubcategory';
  static const String PREF_LAST_SPECIMEN = 'lastSpecimen';
  static const String PREF_TIME_CHECK = 'timeCheck';

  static const String CANCEL = 'Cancel';
  static const String SAVED = 'Saved';

  static const String EXIF_SURVEY_ACTUAL_TAG = "Image ImageDescription";
  static const String EXIF_SURVEY = 'TAG_IMAGE_DESCRIPTION';
  static const String EXIF_BA_TAG = 'TAG_USER_COMMENT';
}