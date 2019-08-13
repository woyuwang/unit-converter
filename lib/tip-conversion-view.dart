import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unit_converter/main.dart';
import 'package:unit_converter/presentation/nova_icons.dart';

class TipConversionView extends StatefulWidget {
  @override
  _TipConversionViewState createState() => _TipConversionViewState();
}

class _TipConversionViewState extends State<TipConversionView> {
  TextEditingController _amount = TextEditingController();
  List<double> _percentages = [
    5.0, 8.0, 10.0, 12.0, 15.0, 18.0, 20.0, 25.0, 30.0,
  ];
  List<TextEditingController> _rates = List<TextEditingController>();
  List<String> _tip = List<String>();
  List<String> _total = List<String>();

  @override
  void initState() {
    super.initState();

    _setupInputControllers();
    _setupValues();
  }

  void _setupValues() {
    for(int i = 0; i < _rates.length; i++) {
      _tip.add('0.00');
      _total.add('0.00');
    }
  }

  void _setupInputControllers() {
    for(int i = 0; i < _percentages.length; i++) {
      _rates.add(TextEditingController(text: _percentages[i].toString()));
    }
  }

  void dispose() {
    _amount.dispose();
    for(int i = 0; i < _rates.length; i++) {
      _rates[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Storage.darkMode ? Colors.grey[800] : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(NovaIcons.banking_spendings_1),
            SizedBox(width: 8.0),
            Text('Tip'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: _buildList(),
        ),
      ),
    );
  }
  
  List<Widget> _buildList() {
    List<Widget> rows = List<Widget>();
    rows.add(
      Row(
        children: <Widget>[
          Text(
            'Amount: ',
            style: TextStyle(
              fontSize: 16.0,
              color: Storage.darkMode ? Colors.white : Colors.black,
            ),
          ),
          Container(
            width: 200.0,
            child: TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 15.0,
                color: Storage.darkMode ? Colors.white : Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  _updateValues();
                });
              },
            ),
          ),
        ],
      ),
    );
    rows.add(SizedBox(height: 16.0));
    for(int i = 0; i < _rates.length; i++) {
      rows.add(_buildRow(i));
    }
    return rows;
  }

  Widget _buildRow(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: 50.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _rates[index],
            style: TextStyle(
              color: Storage.darkMode ? Colors.white : Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                _updateValues();
              });
            },
          ),
        ),
        Text(
          '%',
          style: TextStyle(
            fontSize: 15.0,
            color: Storage.darkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(width: 16.0),
        Text(
          'Tip: ' + _tip[index],
          style: TextStyle(
            fontSize: 15.0,
            color: Storage.darkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(width: 16.0),
        Text(
          'Total: ' + _total[index],
          style: TextStyle(
            fontSize: 15.0,
            color: Storage.darkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _updateValues() {
    for(int i = 0; i < _rates.length; i++) {
      if(_rates[i].text == '') {
        _tip[i] = '0.00';
        _total[i] = '0.00';
      } else {
        double initial = double.tryParse(_amount.text);
        double percent = double.tryParse(_rates[i].text) / 100;
        _tip[i] = (initial * percent).toStringAsFixed(2);
        _total[i] = (initial * (percent + 1)).toStringAsFixed(2);
      }
    }
  }
}
