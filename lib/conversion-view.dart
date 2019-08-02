import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'converter.dart';
import 'main.dart';

class ConversionView extends StatefulWidget {
  final Category category;

  ConversionView(this.category);

  @override
  _ConversionViewState createState() => _ConversionViewState();
}

class _ConversionViewState extends State<ConversionView> {
  Unit _from;
  Unit _to;
  double _toV;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.category.units.length >= 1) {
      _from = widget.category.units[0];
      _to = widget.category.units[0];
    }
    if(double.tryParse(_inputController.text) != null) _toV = Unit.convert(_from, _to, double.tryParse(_inputController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            widget.category.icon,
            SizedBox(width: 8.0),
            Text(widget.category.name),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
          ),
          DropdownButton<Unit>(
            value: _from,
            onChanged: (unit) {
              setState(() {
                _from = unit;
                _toV = Unit.convert(_from, _to, double.tryParse(_inputController.text));
              });
            },
            items: widget.category.units.map((unit) {
              return DropdownMenuItem<Unit>(
                value: unit,
                child: Text(unit.name),
              );
            }).toList(),
          ),
          Container(
            width: 200.0,
            child: TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Input a number',
              ),
              onChanged: (value) {
                setState(() {
                  _toV = Unit.convert(_from, _to, double.tryParse(_inputController.text));
                });
              },
            ),
          ),
          DropdownButton<Unit>(
            value: _to,
            onChanged: (unit) {
              setState(() {
                _to = unit;
                _toV = Unit.convert(_from, _to, double.tryParse(_inputController.text));
              });
            },
            items: widget.category.units.map((unit) {
              return DropdownMenuItem<Unit>(
                value: unit,
                child: Text(unit.name),
              );
            }).toList(),
          ),
          Text(_toV == null ? '0' : _toV.toStringAsFixed(3)),
        ],
      ),
    );
  }
}
