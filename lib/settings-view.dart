import 'package:flutter/material.dart';
import 'package:unit_converter/main.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FlatButton(
              child: Text('Clear Favorites'),
              onPressed: () {
                Storage.favoriteCategories = List<Category>();
                Storage.saveFavoriteCategories();
              },
            ),
            Row(
              children: <Widget>[
                Switch(
                  value: Storage.darkMode,
                  onChanged: (value) {
                    Storage.darkMode = value;
                    runApp(MyApp());
                  },
                ),
                Text('Dark Mode'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
