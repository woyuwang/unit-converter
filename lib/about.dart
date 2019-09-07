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
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                title: Text('A useful and user-friendly unit converter at your disposal.'),
              ),
              Divider(
                height: 20.0,
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Version Number'),
                subtitle: Text('1.0.3'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
