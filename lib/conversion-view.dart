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
  List<Unit> _units = List<Unit>();
  List<TextEditingController> _inputControllers = List<TextEditingController>();

  @override
  void initState() {
    super.initState();

    _setupUnits();
    _setupInputControllers();
  }

  void _setupUnits() {
    for(int i = 0; i < widget.category.units.length; i++) {
      _units.add(widget.category.units[i]);
    }
  }

  void _setupInputControllers() {
    for(int i = 0; i < widget.category.units.length; i++) {
      _inputControllers.add(TextEditingController(text: '0.0'));
    }
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
      body: ListView.builder(
        itemCount: widget.category.units.length,
        itemBuilder: _buildListItem,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 8.0),
        DropdownButton<Unit>(
          value: _units[index],
          onChanged: (unit) {
            setState(() {
              _units[index] = unit;
              _updateValues(index);
            });
          },
          items: widget.category.units.map((unit) {
            return DropdownMenuItem<Unit>(
              value: unit,
              child: Text(
                unit.name,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(width: 4.0),
        Container(
          width: 100.0,
          child: TextField(
            controller: _inputControllers[index],
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15.0,
            ),
            decoration: InputDecoration(
              hintText: 'Input a number',
            ),
            onChanged: (value) {
              setState(() {
                _updateValues(index);
              });
            },
          ),
        ),
        SizedBox(width: 4.0),
        Text(
          widget.category.units[index].symbol,
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }

  void _updateValues(int index) {
    for(int i = 0; i < _inputControllers.length; i++) {
      if(i != index) {
        if(double.tryParse(_inputControllers[index].text) != null) {
          _inputControllers[i].text = Unit.convert(_units[index], _units[i], double.tryParse(_inputControllers[index].text)).toString();
        } else {
          _inputControllers[i].text = '0.0';
        }
      }
    }
  }
}
