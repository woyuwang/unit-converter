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
      backgroundColor: Storage.darkMode ? Colors.grey[800] : Colors.white,
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
              child: Row(
                children: <Widget>[
                  Icon(Icons.clear_all, color: Storage.darkMode ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
                  Text('Clear Favorites', style: TextStyle(color: Storage.darkMode ? Colors.white : Colors.black)),
                ],
              ),
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
                    setState(() {
                      Storage.darkMode = value;
                    });
                  },
                ),
                Text('Dark Mode', style: TextStyle(color: Storage.darkMode ? Colors.white : Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
