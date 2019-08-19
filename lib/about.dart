import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Unit Converter',
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              'A handy app for all your conversion needs!',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'This is an app made from Dart and Flutter to support you in your quest to convert one unit to another.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Version: 0.1.9',
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
