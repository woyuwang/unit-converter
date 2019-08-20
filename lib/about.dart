import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

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
            FutureBuilder(
              future: File('../pubspec.yaml').readAsString(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.hasData) {
                  return Text(
                    loadYaml(snapshot.data)['version'].toString(),
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  );
                } else return Center(child: Container(width: 100.0, height: 100.0, child: CircularProgressIndicator()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
