import 'package:blue_anura/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Home extends StatelessWidget {
  Future<void>_initPermissions () async {
    if (Platform.isAndroid) {
      if (await Permission.camera
          .request()
          .isGranted) {
        print("camera granted");
        // Either the permission was already granted before or the user just granted it.
      }
      if (await Permission.microphone
          .request()
          .isGranted) {
        print("camera microphone");
        // Either the permission was already granted before or the user just granted it.
      }
      if (await Permission.location
          .request()
          .isGranted) {
        print("location granted");
        // Either the permission was already granted before or the user just granted it.
      }
      if (await Permission.storage
          .request()
          .isGranted) {
        print("storage granted");
        // Either the permission was already granted before or the user just granted it.
      }
      if (await Permission.photos
          .request()
          .isGranted) {
        print("photos granted");
        // Either the permission was already granted before or the user just granted it.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initPermissions();

    return Scaffold(
      // appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                        child: Text('Welcome to Blue Anura', style: Theme.of(context).textTheme.headline5)
                    ),
                    Center(
                        child: Text('Version ${AppInfo().version}.${AppInfo().buildNum}', style: Theme.of(context).textTheme.subtitle1)
                    ),
                  ],
                ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                children: [
                  Text('blah, blah, blah', style: Theme.of(context).textTheme.bodyText1),
                  Text('blah, blah, blah', style: Theme.of(context).textTheme.bodyText1),
                  Text('blah, blah, blah', style: Theme.of(context).textTheme.bodyText1),
                ],
              )
            ),
            Flexible(
                fit: FlexFit.loose,
                child: Column(
                  children: [
                    Text('You haven\'t started your latest survey. Tap the Survey button below to begin', style: Theme.of(context).textTheme.bodyText1),
                    Text(''),
                    Text('You have started your survey. To continue tap the Survey button below ', style: Theme.of(context).textTheme.bodyText1),
                    Text(''),
                    Text('Are you done with your survey? Press this button to end this survey', style: Theme.of(context).textTheme.bodyText1),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}