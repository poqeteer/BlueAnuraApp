import 'package:flutter/material.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
                        child: Text('Version 0.0.3.1', style: Theme.of(context).textTheme.subtitle1)
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