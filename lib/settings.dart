import 'package:flutter/material.dart';
import 'package:unit_converter/main.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: RaisedButton(
                child: Text('Clear Favorites'),
                onPressed: () async {
                  bool confirmation = await _showClearFavoritesAlertDialog(context);
                  if(confirmation) {
                    Storage.favoriteCategories = List<Category>();
                    Storage.saveFavoriteCategories();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Cleared Favorites')));
                  }
                },
              ),
            ),
            Row(
              children: <Widget>[
                Switch(
                  value: Storage.darkMode,
                  onChanged: (value) {
                    Storage.setDarkMode(value);
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

  Future<bool> _showClearFavoritesAlertDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Favorites?'),
          content: Text('This will remove all categories from your favorites view.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
    );
  }
}
