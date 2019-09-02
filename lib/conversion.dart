import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'converter.dart';
import 'main.dart';

class ConversionView extends StatefulWidget {
  final BasicCategory category;

  ConversionView(this.category);

  @override
  _ConversionViewState createState() => _ConversionViewState();
}

class _ConversionViewState extends State<ConversionView> {
  List<Unit> _units = List<Unit>();
  List<TextEditingController> _inputControllers = List<TextEditingController>();
  List<FocusNode> _focusNodes = List<FocusNode>();
  bool isLoaded = false;

  @override
  void initState() {
    _setupUnits();
    super.initState();
  }

  _loadIfNecessary() async {
    if(widget.category.name == 'Currency') {
      widget.category.units = await Storage.loadCurrency();
    }
  }

  _setupUnits() async {
    await _loadIfNecessary();
    List<int> indices = await _readOrder();
    for(int i = 0; i < widget.category.units.length; i++) {
      _units.add(widget.category.units[indices[i]]);
    }
    await _saveOrder();
    _setupInputControllers();
    _setupFocusNodes();
    setState(() {
      isLoaded = true;
    });
  }

  _setupInputControllers() {
    for(int i = 0; i < widget.category.units.length; i++) {
      if(i == 0) _inputControllers.add(TextEditingController(text: '0.00'));
      else _inputControllers.add(TextEditingController(
        text: Unit.convert(_units[0], _units[i], 0.0).toStringAsFixed(2),
      ));
    }
  }

  _setupFocusNodes() {
    for(int i = 0; i < widget.category.units.length; i++) {
      _focusNodes.add(FocusNode());
      _focusNodes[i].addListener(() {
        if(_focusNodes[i].hasFocus) {
          _inputControllers[i].selection = TextSelection(baseOffset: 0, extentOffset: _inputControllers[i].text.length);
        }
      });
    }
  }

  void dispose() {
    for(int i = 0; i < _inputControllers.length; i++) {
      _inputControllers[i].dispose();
    }
    for(int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoaded) return _buildBody(context);
    return Center(child: Container(width: 100.0, height: 100.0, child: CircularProgressIndicator()));
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(widget.category.icon),
            SizedBox(width: 8.0),
            Text(widget.category.name),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.category.units.length,
          itemBuilder: _buildListItem,
        ),
      ),
    );
  }

  void _swap(Unit unit, int index) {
    int tempIndex = _units.indexOf(unit);
    Unit temp = _units[index];
    _units[index] = unit;
    _units[tempIndex] = temp;
    _saveOrder();
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<Unit>(
              value: _units[index],
              onChanged: (unit) {
                setState(() {
                  _swap(unit, index);
                  _updateValues(index);
                });
              },
              items: widget.category.units.map((unit) {
                return DropdownMenuItem<Unit>(
                  value: unit,
                  child: Text(
                    unit.name,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                );
              }).toList(),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 200.0,
                  child: TextField(
                    controller: _inputControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 16.0,
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
                SizedBox(width: 8.0),
                Text(
                  _units[index].symbol,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<int>> _readOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = widget.category.name + '-order';
    if(prefs.getStringList(key) == null || prefs.getStringList(key).length == 0) {
      List<int> res = List<int>();
      for(int i = 0; i < widget.category.units.length; i++) res.add(i);
      return res;
    } else {
      List<int> order = prefs.getStringList(key).map((str) => int.parse(str)).toList();
      return order;
    }
  }

  Future<void> _saveOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = widget.category.name + '-order';
    List<String> strList = List<String>();
    for(Unit unit in _units) {
      strList.add(widget.category.units.indexOf(unit).toString());
    }
    prefs.setStringList(key, strList);
  }

  void _updateValues(int index) {
    for(int i = 0; i < _inputControllers.length; i++) {
      if(i != index) {
        if(double.tryParse(_inputControllers[index].text) != null) {
          _inputControllers[i].text = Unit.convert(_units[index], _units[i], double.tryParse(
            _inputControllers[index].text)).toStringAsFixed(2);
        } else {
          _inputControllers[i].text = Unit.convert(_units[index], _units[i], 0.0).toStringAsFixed(2);
        }
      }
    }
  }
}
