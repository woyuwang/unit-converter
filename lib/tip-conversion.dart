import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/presentation/nova_icons.dart';

class TipConversionView extends StatefulWidget {
  @override
  _TipConversionViewState createState() => _TipConversionViewState();
}

class _TipConversionViewState extends State<TipConversionView> {
  TextEditingController _amount = TextEditingController();
  List<double> _percentages;
  List<TextEditingController> _rates = List<TextEditingController>();
  List<FocusNode> _focusNodes = List<FocusNode>();
  List<String> _tip = List<String>();
  List<String> _total = List<String>();
  bool isLoaded = false;

  @override
  void initState() {
    _setupPercentages();
    super.initState();
  }

  _setupPercentages() async {
    _percentages = await _readPercentages();
    await _savePercentages();
    _setupInputControllers();
    _setupFocusNodes();
    _setupValues();
    setState(() {
      isLoaded = true;
    });
  }

  _setupInputControllers() {
    for(int i = 0; i < _percentages.length; i++) {
      _rates.add(TextEditingController(text: _percentages[i].toString()));
    }
  }

  _setupFocusNodes() {
    for(int i = 0; i < _percentages.length; i++) {
      _focusNodes.add(FocusNode());
      _focusNodes[i].addListener(() {
        if(_focusNodes[i].hasFocus) {
          _rates[i].selection = TextSelection(baseOffset: 0, extentOffset: _rates[i].text.length);
        }
      });
    }
  }

  _setupValues() {
    for(int i = 0; i < _rates.length; i++) {
      _tip.add('0.00');
      _total.add('0.00');
    }
  }

  void dispose() {
    _amount.dispose();
    for(int i = 0; i < _rates.length; i++) {
      _rates[i].dispose();
    }
    for(int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  Future<List<double>> _readPercentages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList('tip-order') == null || prefs.getStringList('tip-order').length == 0) {
      List<double> res = [5.0, 8.0, 10.0, 12.0, 15.0, 18.0, 20.0, 25.0, 30.0];
      return res;
    } else {
      List<double> order = prefs.getStringList('tip-order').map((str) => double.parse(str)).toList();
      return order;
    }
  }

  Future<void> _savePercentages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> strList = List<String>();
    for(TextEditingController p in _rates) {
      strList.add(p.text);
    }
    prefs.setStringList('tip-order', strList);
  }

  @override
  Widget build(BuildContext context) {
    if(isLoaded) return _buildBody(context);
    return Center(child: Container(width: 100.0, height: 100.0, child: CircularProgressIndicator()));
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
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
            ),
          ),
          Container(
            width: 200.0,
            child: TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 15.0,
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
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.0,
      runSpacing: 8.0,
      children: <Widget>[
        Container(
          width: 50.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _rates[index],
            focusNode: _focusNodes[index],
            onChanged: (value) {
              setState(() {
                _savePercentages();
                _updateValues();
              });
            },
          ),
        ),
        Text(
          '%',
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
        SizedBox(width: 16.0),
        Text(
          'Tip: ' + _tip[index],
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
        SizedBox(width: 16.0),
        Text(
          'Total: ' + _total[index],
          style: TextStyle(
            fontSize: 15.0,
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
        double initial;
        if(_amount.text.length != 0) initial = double.tryParse(_amount.text);
        else initial = 0.0;
        double percent = double.tryParse(_rates[i].text) / 100;
        _tip[i] = (initial * percent).toStringAsFixed(2);
        _total[i] = (initial * (percent + 1)).toStringAsFixed(2);
      }
    }
  }
}
