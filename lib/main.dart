import 'package:flutter/material.dart';
import 'conversion-view.dart';
import 'converter.dart';
import 'presentation/nova_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class Category {
  final String name;
  final Icon icon;
  final List<Unit> units;

  Category(this.name, this.icon, this.units);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Future<void> _loadUnits() async {
    _basicCategories = [
      Category('Length', Icon(NovaIcons.tools_measuring_tape),
        [
          Unit('meter', 'm', 0, 1.0, 0),
          Unit('foot', 'ft', 0, 0.3048000000012192000000048768000000195072000000780288000003121152000012484608000049938432000199753728, 0),
          Unit('kilometer', 'km', 0, 1000, 0),
          Unit('yard', 'yd', 0, 0.9144000000036576000000146304000000585216000002340864000009363456000037453824000149815296000599261184, 0),
        ],
      ),
      Category('Area', Icon(NovaIcons.vector_square_1),
        [
          Unit('square meter', 'm²', 0, 1, 0),
          Unit('acre', 'ac', 0, 4046.8564224, 0),
          Unit('square foot', 'sq ft', 0, 0.092903411613275, 0),
          Unit('square inch', 'sq in', 0, 0.00064516, 0),
          Unit('square kilometer', 'km²', 0, 1000000, 0),
          Unit('square mile', 'sw mi', 0, 2589988.110336, 0),
          Unit('square yard', 'sq yd', 0, 0.83612736, 0),
        ],
      ),
      Category('Volume', Icon(NovaIcons.box_2),
        [
          Unit('cubic meter', 'm³', 0, 1, 0),
          Unit('cubic inch', 'in³', 0, 0.000016387, 0),
          Unit('teaspoon', 'tsp', 0, 0.000005, 0),
          Unit('liter', 'L', 0, 0.001, 0),
        ],
      ),
      Category('Angle', Icon(NovaIcons.vector_triangle),
        [
          Unit('radian', 'rad', 0, 1, 0),
          Unit('degree', '°', 0, 0.017453293, 0),
          Unit('gradian', 'grad', 0, 0.015707963, 0),
          Unit('quadrant', '', 0, 1.570796, 0),
        ],
      ),
      Category('Temperature', Icon(NovaIcons.fire_lighter),
        [
          Unit('kelvin', 'K', 0, 1, 0),
          Unit('Celsius', '°C', 0, 1, 273.15),
          Unit('Fahrenheit', '°F', 459.67, 5 / 9, 0),
          Unit('Rankine', '°R;', 0, 5 / 9, 0),
          Unit('Delisle', '°De', 0, -2 / 3, 373.15),
        ],
      ),
      Category('Force', Icon(NovaIcons.cursor_arrow_1),
        [
          Unit('newton', 'N', 0, 1, 0),
          Unit('pound-force', 'lbf', 0, 4.4482216152605, 0),
          Unit('ounce-force', 'ozf', 0, 0.27801385095378125, 0),
          Unit('dyne', 'dyn', 0, 0.0001, 0),
          Unit('kilogram-force', 'kgf', 0, 9.80665, 0),
        ],
      ),
      Category('Speed', Icon(NovaIcons.video_control_fast_forward),
        [
          Unit('meter per second', 'm/s', 0, 1, 0),
          Unit('knot', 'kn', 0, 0.514444444444, 0),
          Unit('mile per hour', 'mph', 0, 0.44704, 0),
          Unit('speed of light in vacuum', 'c', 0, 299792458, 0),
        ],
      ),
      Category('Time', Icon(NovaIcons.calendar_1),
        [
          Unit('Second', 's', 0, 1, 0),
          Unit('Minute', 'min', 0, 60, 0),
          Unit('Hour', 'h', 0, 3600, 0),
          Unit('Day', 'd', 0, 86400, 0),
          Unit('Week', 'wk', 0, 604800, 0),
          Unit('Month', 'mo', 0, 2592000, 0),
          Unit('Year', 'yr', 0, 31536000, 0),
        ],
      ),
      Category('Acceleration', Icon(NovaIcons.video_control_fast_forward),
        [
          Unit('meter per second squared', 'm/s²', 0, 1, 0),
          Unit('mile per hour per second', 'mph/s', 0, 0.44704, 0),
          Unit('standard gravity', 'g₀', 0, 9.80665, 0),
          Unit('foot per minute per second', 'fpm/s', 0, 0.00508, 0),
          Unit('inch per minute per second', 'ipm/s', 0, 0.000423333333333, 0),
        ],
      ),
      Category('Pressure', Icon(NovaIcons.water_droplet),
        [
          Unit('pascal', 'Pa', 0, 1, 0),
          Unit('atmosphere', 'atm', 0, 101325, 0),
          Unit('bar', 'bar', 0, 100000, 0),
          Unit('centimeter of mercury', 'cmHg', 0, 1333.22, 0),
          Unit('centimeter of water (4°C)', 'cmH₂O', 0, 98.0638, 0),
          Unit('pound per square inch', 'psi', 0, 6894.757, 0),
          Unit('torr', 'torr', 0, 101325 / 760, 0),
        ],
      ),
      Category('Torque', Icon(NovaIcons.synchronize_1),
        [
          Unit('Newton meter', 'N·m', 0, 1, 0),
          Unit('kilogram force-meter', 'kgf·m', 0, 9.80665, 0),
          Unit('pound force-foot', 'lbf·ft', 0, 1.3558179483314004, 0),
        ],
      ),
      Category('Energy', Icon(NovaIcons.sport_dumbbell_1),
        [
          Unit('joule', 'J', 0, 1, 0),
          Unit('electronvolt', 'eV', 0, 0.000000000000000000160217656535, 0),
          Unit('calorie', 'cal', 0, 4184, 0),
          Unit('barrel of oil equivalent', 'boe', 0, 6120000000, 0),
          Unit('foot-pound force', 'ft lbf', 0, 1.3558179483314004, 0),
          Unit('ton of coal equivalent', 'TCE', 0, 29288000000, 0),
          Unit('ton of oil equivalent', 'toe', 0, 41868000000, 0),
          Unit('ton of TNT', 'tTNT', 0, 4184000000, 0),
        ],
      ),
      Category('Power', Icon(NovaIcons.flash),
        [
          Unit('watt', 'W', 0, 1, 0),
          Unit('horsepower (metric)', 'hp', 0, 735.49875, 0),
          Unit('BTU per minute', 'BTU/min', 0, 17.584264, 0),
          Unit('atmosphere-cubic foot per minute', 'atm cfm', 0, 47.82007468224, 0),
          Unit('liter-atmosphere per minute', 'L·atm/min', 0, 1.68875, 0),
        ],
      ),
      Category('Dynamic Viscosity', Icon(NovaIcons.water_droplet),
        [
          Unit('pascal second', 'Pa·s', 0, 1, 0),
          Unit('pound per foot second', 'lb/(ft·s)', 0, 1.488164, 0),
          Unit('poise', 'P', 0, 0.1, 0),
        ],
      ),
      Category('Kinematic Viscosity', Icon(NovaIcons.water_droplet),
        [
          Unit('square meter per second', 'm²/s', 0, 1, 0),
          Unit('square foot per second', 'ft²/s', 0, 0.09290304, 0),
          Unit('stokes', 'St', 0, 0.001, 0),
        ],
      ),
      Category('Current', Icon(NovaIcons.battery_charging_1),
        [
          Unit('ampere', 'A', 0, 1, 0),
          Unit('emu, abampere', 'abamp', 0, 10, 0),
          Unit('esu per second', 'esu/s', 0, 0.0000000003335641, 0),
        ],
      ),
      Category('Charge', Icon(NovaIcons.cursor_arrow_1),
        [
          Unit('coulomb', 'C', 0, 1, 0),
          Unit('faraday', 'F', 0, 96485.3383, 0),
          Unit('atmoic unit of charge', 'au', 0, 0.0000000000000000001602176, 0),
          Unit('milliampere hour', 'mA·h', 0, 3.6, 0),
        ],
      ),
      Category('Dipole', Icon(NovaIcons.synchronize_2),
        [
          Unit('coulomb meter', 'C·m', 0, 1, 0),
          Unit('debye', 'D', 0, 0.000000000000000000000000000003335646, 0),
          Unit('atmoic unit of electric dipole moment', 'ea₀', 0, 0.000000000003335646, 0),
        ],
      ),
      Category('Electromotive Force', Icon(NovaIcons.sport_dumbbell_1),
        [
          Unit('volt', 'V', 0, 1, 0),
          Unit('statvolt', 'statV', 0, 299.792458, 0),
          Unit('abvolt', 'abV', 0, 0.00000001, 0),
        ],
      ),
      Category('Magnetic Flux', Icon(NovaIcons.synchronize_2),
        [
          Unit('weber', 'Wb', 0, 1, 0),
          Unit('maxwell', 'Mx', 0, 0.00000001, 0),
        ],
      ),
      Category('Magnetic Flux Density', Icon(NovaIcons.synchronize_2),
        [
          Unit('tesla', 'T', 0, 1, 0),
          Unit('gauss', 'G', 0, 0.0001, 0),
        ],
      ),
      Category('Flow', Icon(NovaIcons.cursor_arrow_1),
        [
          Unit('cubic meter per second', 'm³/s', 0, 1, 0),
          Unit('gallon per minute', 'gal/min', 0, 0.0000630901964, 0),
          Unit('cubic foot per minute', 'ft³/min', 0, 0.0004719474432, 0),
          Unit('cubic inch per minute', 'in³/min', 0, 0.000000273117733333, 0),
        ],
      ),
      Category('Luminous Intensity', Icon(NovaIcons.lamp_studio_1),
        [
          Unit('candela', 'cd', 0, 1, 0),
          Unit('candlepower (new)', 'cp', 0, 1, 0),
          Unit('candlepower (old, pre-1948)', 'cp', 0, 0.981, 0),
        ],
      ),
      Category('Luminance', Icon(NovaIcons.lamp_studio_1),
        [
          Unit('candela per square meter', 'cd/m²', 0, 1, 0),
          Unit('footlambert', 'fL', 0, 3.4262590996, 0),
          Unit('lambert', 'L', 0, 3183.0988618, 0),
          Unit('stilb', 'sb', 0, 10000, 0),
        ],
      ),
      Category('Illuminance', Icon(NovaIcons.lamp_studio_1),
        [
          Unit('lux', 'lx', 0, 1, 0),
          Unit('phot', 'ph', 0, 10000, 0),
          Unit('lumen per square inch', 'lm/in²', 0, 1550.0031, 0),
          Unit('footcandle', 'fc', 0, 10.763910417, 0),
        ],
      ),
      Category('Radiation Source Activity', Icon(NovaIcons.atomic_bomb),
        [
          Unit('becquerel', 'Bq', 0, 1, 0),
          Unit('curie', 'Ci', 0, 37000000000, 0),
          Unit('rutherford', 'rd', 0, 1000000, 0),
        ],
      ),
      Category('Radiation Absorbed Dose', Icon(NovaIcons.atomic_bomb),
        [
          Unit('gray', 'Gy', 0, 1, 0),
          Unit('rad', 'rad', 0, 0.01, 0),
        ],
      ),
      Category('Radiation Equivalent Dose', Icon(NovaIcons.atomic_bomb),
        [
          Unit('sievert', 'Sv', 0, 1, 0),
          Unit('Röntgen equivalent man', 'rem', 0, 0.01, 0),
        ],
      ),
      Category('Mass', Icon(NovaIcons.gold_nuggets),
        [
          Unit('kilogram', 'kg', 0, 1, 0),
          Unit('gram', 'g', 0, 0.001, 0),
          Unit('ton', 't', 0, 1000, 0),
          Unit('ounce', 'oz', 0, 0.028, 0),
          Unit('pound', 'lb', 0, 0.5, 0),
        ],
      ),
      Category('Density', Icon(NovaIcons.gold_nuggets),
        [
          Unit('kilogram per cubic meter', 'kg/m³', 0, 1, 0),
          Unit('gram per milliliter', 'g/mL', 0, 1000, 0),
          Unit('kilogram per liter', 'kg/L', 0, 1000, 0),
          Unit('ounce per cubic inch', 'oz/in³', 0, 1729.994044, 0),
          Unit('pound per cubic inch', 'lb/in³', 0, 27679.90471, 0),
        ],
      ),
      Category('Frequency', Icon(NovaIcons.synchronize_1),
        [
          Unit('hertz', 'Hz', 0, 1, 0),
          Unit('revolutions per minute', 'rpm', 0, 0.01666666666666667, 0),
        ],
      ),
    ];
    _financeCategories = [
      //Category('Tip', Icon(NovaIcons.banking_spendings_1),
      //  [],
      //),
      //Category('Loan', Icon(NovaIcons.business_briefcase_cash),
      //  [],
      //),
      Category('Currency', Icon(NovaIcons.location_pin_bank_2), (_cachedCurrencyUnits != null &&
        _lastCurrencyRequest.difference(DateTime.now()).inHours <= 6) ? _cachedCurrencyUnits :
        await _getCurrencyUnits()
      ),
    ];
  }

  int _currentTab = 0;
  List<Category> _basicCategories;
  List<Category> _financeCategories;
  static List<Unit> _cachedCurrencyUnits;
  static DateTime _lastCurrencyRequest;

  static Future<List<Unit>> _getCurrencyUnits() async {
    var url = 'https://api.exchangeratesapi.io/latest';
    http.Response response = await http.get(url);
    var decoded = json.decode(response.body);
    print('currencies loaded');
    List<Unit> res = List<Unit>();
    res.add(Unit(decoded['base'], decoded['base'], 0, 1 ,0));
    var _map = decoded['rates'];
    for(int i = 0; i < _map.length; i++) {
      res.add(Unit(_map.keys.toList()[i], _map.keys.toList()[i], 0, 1/_map.values.toList()[i], 0));
    }
    _cachedCurrencyUnits = res;
    _lastCurrencyRequest = DateTime.tryParse(decoded['date']);
    return res;
  }

  Widget _buildTab() {
    return SliverGrid.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: _buildCategories(),
    );
  }

  Widget _buildTopicCard(Category category){
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConversionView(category))
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              category.icon,
              SizedBox(width: 16.0),
              Expanded(
                child: Text(category.name),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategories() {
    if(_currentTab == 0) {
      return _basicCategories.map((topic) => _buildTopicCard(topic)).toList();
    } else if (_currentTab == 1) {
      return _financeCategories.map((topic) => _buildTopicCard(topic)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter'),
      ),
      body: FutureBuilder(
        future: _loadUnits(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Connection not started!');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Awaiting result...');
            case ConnectionState.done:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              return CustomScrollView(
                slivers: <Widget>[
                  _buildTab(),
                ],
              );
            default: return null;
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.pencil_ruler),
            title: Text('Basic'),
          ),
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.bank_note),
            title: Text('Finance'),
          ),
        ],
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }
}
