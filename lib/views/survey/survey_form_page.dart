import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blue_anura/constants.dart';
import 'package:blue_anura/models/exif_data_model.dart';
import 'package:blue_anura/utils/app_info.dart';
import 'package:blue_anura/utils/get_location.dart';
import 'package:blue_anura/views/widgets/base_nav_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:r_album/r_album.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyFormPage extends StatefulWidget {
  final String title;
  final File file;
  final EXIFDataModel exifDataModel;
  SurveyFormPage(String title, File file, EXIFDataModel exifDataModel) :
        title = title, file = file, exifDataModel = exifDataModel;

  @override
  _SurveyFormPageState createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _subcategoryTextController = new TextEditingController();
  TextEditingController _specimenTextController = new TextEditingController();
  TextEditingController _commentTextController = new TextEditingController();

  final _focusSub = FocusNode();
  final _focusSpc = FocusNode();
  final _focusCom = FocusNode();

  bool _showFloatingButton = false;

  List<String> _categories = <String>[
    'Panorama',
    'Specimen',
    'Other',
    'Datasheet',
  ];
  String _category = 'Panorama';

  @override
  void initState() {
    super.initState();
    _initState();
    if ( Platform.operatingSystem == 'ios')
      _focusSpc.addListener(_handleFocusChange);
  }
  Future<void> _initState() async {
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (widget.exifDataModel != null) {
        _category = widget.exifDataModel?.category;
        _subcategoryTextController.text =
            widget.exifDataModel?.subcategory ?? "";
        _specimenTextController.text = widget.exifDataModel?.specimen ?? "";
        _commentTextController.text = widget.exifDataModel?.comment ?? "";
      } else {
        _category = prefs.getString(Constants.PREF_LAST_CATEGORY) ?? _categories[0];
        _subcategoryTextController.text =
            prefs.getString(Constants.PREF_LAST_SUBCATEGORY) ?? "";
        _specimenTextController.text = prefs.getString(Constants.PREF_LAST_SPECIMEN) ?? "";
        _commentTextController.text = "";
      }
    });
  }

  @override
  void dispose() {
    if ( Platform.operatingSystem == 'ios')
      _focusSpc.removeListener(_handleFocusChange);
    _focusCom.dispose();
    _focusSpc.dispose();
    _focusSub.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if ( Platform.operatingSystem == 'ios')
      if (_focusSpc.hasFocus) {
        setState(() {_showFloatingButton = true;});
      } else {
        setState(() {_showFloatingButton = false;});
      }
  }

  @override
  Widget build(BuildContext context) {

    return BaseNavPage(title: widget.title, body: Scaffold(
      body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: FractionallySizedBox(
                    alignment: Alignment.center,
                    widthFactor: 0.5,
                    child: Container(
                      height: 150.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                            image: FileImage(widget.file),
                            fit: BoxFit.cover
                        ),
                      ),
                    )),

              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.category_outlined),
                      labelText: 'Category',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: _category == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: _category,
                        isDense: true,
                        onChanged: (String newValue) {
                          if (newValue != _category) {
                            setState(() {
                              _category = newValue;
                              _subcategoryTextController.text = "";
                              _specimenTextController.text = "";
                            });
                            state.didChange(newValue);
                          }
                          FocusScope.of(context).requestFocus(_focusSub);
                        },
                        items: _categories.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                // validator: (val) {
                //   return val != '' ? null : 'Please select a category';
                // },
              ),
              TextFormField(
                focusNode: _focusSub,
                decoration: InputDecoration(
                  labelText: 'Subcategory',
                  icon: Icon(Icons.workspaces_outline ),
                ),
                controller: _subcategoryTextController,
                textInputAction:  TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusSpc),
              ),
              TextFormField(
                focusNode: _focusSpc,
                decoration: InputDecoration(
                  labelText: 'Specimen',
                  icon: Icon(Icons.bug_report_outlined ),
                ),
                controller: _specimenTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction:  TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusCom),
              ),
              TextFormField(
                focusNode: _focusCom,
                decoration: InputDecoration(
                  labelText: 'Comment',
                  icon: Icon(Icons.comment ),
                ),
                controller: _commentTextController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                maxLength: 160,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          child: Text(Constants.CANCEL),
                          onPressed: () {
                            // your code
                            Navigator.pop(context, Constants.CANCEL);
                          }),
                      SizedBox(width: 15),
                      ElevatedButton(
                          child: Text("Save"),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              SharedPreferences prefs = await SharedPreferences
                                  .getInstance();
                              final String filePath = widget.file.path;
                              String formattedFilename;
                              String formattedSequence;
                              final int sequence = (prefs.getInt(
                                  Constants.PREF_SEQUENCE) ?? 1);

                              prefs.setString(Constants.PREF_LAST_CATEGORY, _category);
                              prefs.setString(Constants.PREF_LAST_SUBCATEGORY, _subcategoryTextController.text);
                              prefs.setString(Constants.PREF_LAST_SPECIMEN, _specimenTextController.text);

                              // Stopwatch stopwatch = new Stopwatch()..start();

                              final exif = FlutterExif.fromPath(filePath);
                              // print('read exif: ${stopwatch.elapsed}');

                              final String surveyInfo =
                                  "$_category|"
                                  "${_subcategoryTextController.text}|"
                                  "${_specimenTextController.text}|"
                                  "${_commentTextController.text}";

                              // New? Add location and app info
                              if (widget.exifDataModel == null) {
                                formattedSequence = sequence.toString()
                                    .padLeft(3, '0');
                                LocationData _location;
                                try {
                                  _location = await BuildLocation.buildLocationText();
                                  // print('got location: ${stopwatch.elapsed}');
                                } catch (e) {
                                  await showOkAlertDialog(title: "Location Error",
                                      message: e.toString(),
                                      context: context);
                                }
                                if (_location != null)
                                  formattedFilename =
                                  '${prefs.get(Constants.PREF_LAST_ORG)}'
                                      '_${prefs.get(Constants.PREF_LAST_LOC)}'
                                      '_${DateFormat('yyyyMMdd').format(
                                      DateTime.now())}'
                                      '_$formattedSequence.jpg';

                                // Add location information
                                await exif.setLatLong(
                                    _location.latitude, _location.longitude);
                                // print("----------------------------------");
                                // print('exif: ${stopwatch.elapsed}');
                                // print("exif updated: $_location");
                                // print("----------------------------------");

                                // Add app info
                                await exif.setAttribute(Constants.EXIF_BA_TAG,
                                    'ASCII\u{0}\u{0}\u{0}Blue Anura v${AppInfo()
                                        .version}.${AppInfo().buildNum}');
                              } else {
                                formattedFilename = widget.exifDataModel.filename;
                                formattedSequence = widget.exifDataModel.sequence;
                              }
                              // Add/Update the survey information
                              await exif.setAttribute(Constants.EXIF_SURVEY,
                                  '$formattedFilename|$surveyInfo\u{0}');

                              // apply attributes
                              try {
                                await exif.saveAttributes();
                                // print('save exif: ${stopwatch.elapsed}');
                              } catch (e) {
                                print("==================================");
                                print(e.toString());
                                await showOkAlertDialog(title: "EXIF Error",
                                    message: e.toString(),
                                    context: context);
                                print("==================================");
                              }

                              // If new then move file to album
                              if (widget.exifDataModel == null) {
                                await RAlbum.saveAlbum(Constants.ALBUM_NAME,
                                    [filePath]).then((value) {
                                  print('----------\nSaved to album: $value[0]\n---------');
                                  // print('save to album: ${stopwatch.elapsed}');
                                });

                                prefs.setInt(Constants.PREF_SEQUENCE, sequence + 1);

                                widget.file.delete();
                              }

                              Navigator.pop(context, '${Constants.SAVED} #$formattedSequence');
                            }})
                    ],
                  )
              ),
            ],
          )),
      floatingActionButton: Visibility(
        visible: _showFloatingButton,
        child: FloatingActionButton.extended(
          onPressed: () {
            FocusScope.of(context).requestFocus(_focusCom);
          },
          label: Text('   Next   '),
          icon: Icon(Icons.navigate_next),
          backgroundColor: Colors.grey,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ));
  }
}
