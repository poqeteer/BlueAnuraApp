import 'package:blue_anura/models/organization_model.dart';
import 'package:blue_anura/views/widgets/labeled_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:form_validator/form_validator.dart';

class SurveyInfoDialog extends StatefulWidget {
  final BuildContext context;
  final String saveButtonText;
  final bool cancelButton;
  final Function onSave;
  final List<OrganizationModel> organizationList;
  final OrganizationModel organizationModel;
  final String location;

  SurveyInfoDialog({BuildContext context, String saveButtonText, bool cancelButton, Function onSave, List<OrganizationModel> organizationList, OrganizationModel organizationModel, String location}) :
        context = context, saveButtonText = saveButtonText, cancelButton = cancelButton, onSave = onSave,
        organizationList = organizationList, organizationModel = organizationModel, location = location;

  @override
  _SurveyInfoDialogState createState() => _SurveyInfoDialogState();
}

class _SurveyInfoDialogState extends State<SurveyInfoDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _locTextController = new TextEditingController();
  final focusLocation = FocusNode();
  
  OrganizationModel _organizationModel;

  @override
  void initState() {
    super.initState();
    setState(() {
      _organizationModel = widget.organizationModel;
      _locTextController.text = widget.location;
    });
  }

  @override
  void dispose() {
    focusLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _onSave() {
      if (_formKey.currentState.validate()) {
        widget.onSave(_organizationModel, _locTextController.text);
        Navigator.pop(context, true);
      }
    }
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(
                Radius.circular(10.0))),
        scrollable: true,
        title: Text("Main Survey Information", style: TextStyle(fontSize: 18)),
        content:  Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormField<OrganizationModel>(
                builder: (FormFieldState<OrganizationModel> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.category_outlined),
                      labelText: 'Organization',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: _organizationModel == null,
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<OrganizationModel>(
                        value: _organizationModel,
                        isDense: true,
                        onChanged: (OrganizationModel newValue) {
                          setState(() {
                            _organizationModel = newValue;
                          });
                          state.didChange(newValue);
                          FocusScope.of(context).requestFocus(focusLocation);
                        },
                        items: widget.organizationList.map((OrganizationModel value) {
                          return new DropdownMenuItem<OrganizationModel>(
                            value: value,
                            child: LabeledText("", value.name, 16, MediaQuery.of(context).size.width - 200),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              TextFormField(
                focusNode: focusLocation,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_pin),
                  hintText: 'Enter Location Identifier',
                  labelText: 'Location',
                ),
                controller: _locTextController,
                keyboardType: TextInputType.number,
                textInputAction:  TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onEditingComplete: _onSave,
                validator: ValidationBuilder().minLength(1, "Location ID is required").build(),
                maxLength: 3,
              ),
            ],
          ),
        ),
        actions: [
          widget.cancelButton
              ? OutlineButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context))
              : SizedBox(),
          ElevatedButton(
            child: Text(widget.saveButtonText),
            onPressed: _onSave
          ),
        ],
      );
  }
}

