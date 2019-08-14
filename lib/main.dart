import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/settings-view.dart';
import 'package:unit_converter/tip-conversion-view.dart';
import 'about-view.dart';
import 'conversion-view.dart';
import 'converter.dart';
import 'presentation/nova_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await Storage.readDarkMode();
  runApp(MyApp());
}

abstract class Category {
  final String name;
  final IconData icon;
  final Color color;
  final List<Unit> units;
  final MaterialPageRoute route;

  Category(this.name, this.icon, {this.color, this.units, this.route});
}

class BasicCategory extends Category {
  BasicCategory(String name, IconData icon, List<Unit> units, {Color color}) : super(name, icon, color: color, units: units);
}

class SpecialCategory extends Category {
  SpecialCategory(String name, IconData icon, MaterialPageRoute route, {Color color}) : super(name, icon, color: color, route: route);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColorDark: Colors.deepPurple,
        accentColor: Colors.purpleAccent,
        toggleableActiveColor: Colors.purpleAccent,
        cursorColor: Colors.deepPurple,
        textSelectionHandleColor: Colors.deepPurpleAccent,
        brightness: Storage.darkMode ? Brightness.dark : Brightness.light,
      ),
      home: MainView(),
    );
  }
}

class Storage {
  static List<Category> categories;
  static List<Category> favoriteCategories;
  static bool darkMode;

  static Future<List<Category>> readFavoriteCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList('favorite-categories') == null){
      saveFavoriteCategories();
      return List<Category>();
    } else {
      List<int> ids = prefs.getStringList('favorite-categories').map((str) => int.parse(str)).toList();
      List<Category> favorites = new List<Category>();
      for (int id in ids) {
        favorites.add(categories[id]);
      }
      return favorites;
    }
  }

  static saveFavoriteCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> strIds = List<String>();
    for(Category category in favoriteCategories) {
      strIds.add(categories.indexOf(category).toString());
    }
    prefs.setStringList('favorite-categories', strIds);
  }

  static readDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('dark-mode');
    if(darkMode == null) darkMode = false;
    saveDarkMode();
  }

  static saveDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark-mode', darkMode);
  }

  static setDarkMode(bool value) async {
    darkMode = value;
    await saveDarkMode();
  }
}

class MainView extends StatefulWidget {


  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Future<void> _initialize() async {
    Storage.categories = [
      SpecialCategory('Tip', NovaIcons.banking_spendings_1,
        MaterialPageRoute(builder: (context) => TipConversionView()),
        color: Colors.yellow,
      ),
      BasicCategory('Currency', NovaIcons.location_pin_bank_2, (_cachedCurrencyUnits != null &&
        _lastCurrencyRequest.difference(DateTime.now()).inHours <= 6) ? _cachedCurrencyUnits :
        await _getCurrencyUnits(), color: Colors.indigo,
      ),
      BasicCategory('Length', NovaIcons.tools_measuring_tape,
        [
          Unit('meter', 'm', 0, 1, 0),
          Unit('inch', 'in', 0, 0.0254, 0),
          Unit('foot', 'ft', 0, 0.3048000000012192000000048768000000195072000000780288000003121152000012484608000049938432000199753728, 0),
          Unit('kilometer', 'km', 0, 1000, 0),
          Unit('yard', 'yd', 0, 0.9144000000036576000000146304000000585216000002340864000009363456000037453824000149815296000599261184, 0),
          Unit('mile', 'mi', 0, 1609.347219, 0),
          Unit('astronomical unit', 'AU', 0, 149597870700, 0),
          Unit('parsec', 'pc', 0, 30856775814913700, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Area', NovaIcons.vector_square_1,
        [
          Unit('square meter', 'm²', 0, 1, 0),
          Unit('acre', 'ac', 0, 4046.8564224, 0),
          Unit('square foot', 'sq ft', 0, 0.092903411613275, 0),
          Unit('square inch', 'sq in', 0, 0.00064516, 0),
          Unit('square kilometer', 'km²', 0, 1000000, 0),
          Unit('square mile', 'sw mi', 0, 2589988.110336, 0),
          Unit('square yard', 'sq yd', 0, 0.83612736, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Volume', NovaIcons.box_2,
        [
          Unit('cubic meter', 'm³', 0, 1, 0),
          Unit('cubic inch', 'in³', 0, 0.000016387, 0),
          Unit('teaspoon', 'tsp', 0, 0.000005, 0),
          Unit('liter', 'L', 0, 0.001, 0),
          Unit('lambda', 'λ', 0, 0.000000001, 0),
          Unit('cup (metric)', 'c', 0, 0.0002500, 0),
          Unit('pint (US fluid)', 'pt', 0, 0.000473176473, 0),
          Unit('quart (US fluid)', 'qt', 0, 0.000946352946, 0),
          Unit('gallon (US fluid)', 'gal', 0, 0.003785411784, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Temperature', NovaIcons.fire_lighter,
        [
          Unit('Celsius', '°C', 0, 1, 273.15),
          Unit('Fahrenheit', '°F', 459.67, 5 / 9, 0),
          Unit('kelvin', 'K', 0, 1, 0),
          Unit('Rankine', '°R;', 0, 5 / 9, 0),
          Unit('Delisle', '°De', 0, -2 / 3, 373.15),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Speed', NovaIcons.video_control_fast_forward,
        [
          Unit('meter per second', 'm/s', 0, 1, 0),
          Unit('knot', 'kn', 0, 0.514444444444, 0),
          Unit('mile per hour', 'mph', 0, 0.44704, 0),
          Unit('speed of light in vacuum', 'c', 0, 299792458, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Time', NovaIcons.calendar_1,
        [
          Unit('Second', 's', 0, 1, 0),
          Unit('Minute', 'min', 0, 60, 0),
          Unit('Hour', 'h', 0, 3600, 0),
          Unit('Day', 'd', 0, 86400, 0),
          Unit('Week', 'wk', 0, 604800, 0),
          Unit('Month', 'mo', 0, 2592000, 0),
          Unit('Year', 'yr', 0, 31536000, 0),
        ],
        color: Colors.amber,
      ),
      BasicCategory('Plane Angle', NovaIcons.vector_triangle,
        [
          Unit('radian', 'rad', 0, 1, 0),
          Unit('degree', '°', 0, 0.017453293, 0),
          Unit('gradian', 'grad', 0, 0.015707963, 0),
          Unit('quadrant', '', 0, 1.570796, 0),
          Unit('octant', '', 0, 0.785398, 0),
          Unit('sextant', '', 0, 1.047198, 0),
          Unit('sign', '', 0, 0.523599, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Solid Angle', NovaIcons.vector_triangle,
        [
          Unit('steradian', 'sr', 0, 1, 0),
          Unit('square degree', 'deg²', 0, 0.00030462, 0),
          Unit('spat', '', 0, 12.56637, 0),
        ],
        color: Colors.blueGrey,
      ),
      BasicCategory('Force', NovaIcons.cursor_arrow_1,
        [
          Unit('newton', 'N', 0, 1, 0),
          Unit('pound-force', 'lbf', 0, 4.4482216152605, 0),
          Unit('ounce-force', 'ozf', 0, 0.27801385095378125, 0),
          Unit('dyne', 'dyn', 0, 0.0001, 0),
          Unit('kilogram-force', 'kgf', 0, 9.80665, 0),
        ],
        color: Colors.orange,
      ),
      BasicCategory('Acceleration', NovaIcons.video_control_fast_forward,
        [
          Unit('meter/second squared', 'm/s²', 0, 1, 0),
          Unit('mile per hour/sec', 'mph/s', 0, 0.44704, 0),
          Unit('standard gravity', 'g₀', 0, 9.80665, 0),
          Unit('foot per minute/sec', 'fpm/s', 0, 0.00508, 0),
          Unit('inch per minute/sec', 'ipm/s', 0, 0.000423333333333, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Pressure', NovaIcons.water_droplet,
        [
          Unit('pascal', 'Pa', 0, 1, 0),
          Unit('atmosphere', 'atm', 0, 101325, 0),
          Unit('bar', 'bar', 0, 100000, 0),
          Unit('centimeter of mercury', 'cmHg', 0, 1333.22, 0),
          Unit('centimeter of water (4°C)', 'cmH₂O', 0, 98.0638, 0),
          Unit('pound per square inch', 'psi', 0, 6894.757, 0),
          Unit('torr', 'torr', 0, 101325 / 760, 0),
        ],
        color: Colors.yellow,
      ),
      BasicCategory('Torque', NovaIcons.synchronize_1,
        [
          Unit('Newton meter', 'N·m', 0, 1, 0),
          Unit('kilogram force-meter', 'kgf·m', 0, 9.80665, 0),
          Unit('pound force-foot', 'lbf·ft', 0, 1.3558179483314004, 0),
        ],
        color: Colors.grey,
      ),
      BasicCategory('Energy', NovaIcons.sport_dumbbell_1,
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
        color: Colors.indigo,
      ),
      BasicCategory('Power', NovaIcons.flash,
        [
          Unit('watt', 'W', 0, 1, 0),
          Unit('horsepower (metric)', 'hp', 0, 735.49875, 0),
          Unit('BTU per minute', 'BTU/min', 0, 17.584264, 0),
          Unit('atmosphere-cubic ft/min', 'atm cfm', 0, 47.82007468224, 0),
          Unit('liter-atmosphere/min', 'L·atm/min', 0, 1.68875, 0),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Dynamic Viscosity', NovaIcons.water_droplet,
        [
          Unit('pascal second', 'Pa·s', 0, 1, 0),
          Unit('pound per foot second', 'lb/(ft·s)', 0, 1.488164, 0),
          Unit('poise', 'P', 0, 0.1, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Kinematic Viscosity', NovaIcons.water_droplet,
        [
          Unit('square meter per second', 'm²/s', 0, 1, 0),
          Unit('square foot per second', 'ft²/s', 0, 0.09290304, 0),
          Unit('stokes', 'St', 0, 0.001, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Current', NovaIcons.battery_charging_1,
        [
          Unit('ampere', 'A', 0, 1, 0),
          Unit('emu, abampere', 'abamp', 0, 10, 0),
          Unit('esu per second', 'esu/s', 0, 0.0000000003335641, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Charge', NovaIcons.cursor_arrow_1,
        [
          Unit('coulomb', 'C', 0, 1, 0),
          Unit('faraday', 'F', 0, 96485.3383, 0),
          Unit('atmoic unit of charge', 'au', 0, 0.0000000000000000001602176, 0),
          Unit('milliampere hour', 'mA·h', 0, 3.6, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Dipole', NovaIcons.synchronize_2,
        [
          Unit('coulomb meter', 'C·m', 0, 1, 0),
          Unit('debye', 'D', 0, 0.000000000000000000000000000003335646, 0),
          Unit('electric dipole moment', 'ea₀', 0, 0.000000000003335646, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Electromotive Force', NovaIcons.sport_dumbbell_1,
        [
          Unit('volt', 'V', 0, 1, 0),
          Unit('statvolt', 'statV', 0, 299.792458, 0),
          Unit('abvolt', 'abV', 0, 0.00000001, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Magnetic Flux', NovaIcons.synchronize_2,
        [
          Unit('weber', 'Wb', 0, 1, 0),
          Unit('maxwell', 'Mx', 0, 0.00000001, 0),
        ],
        color: Colors.yellow,
      ),
      BasicCategory('Magnetic Flux Density', NovaIcons.synchronize_2,
        [
          Unit('tesla', 'T', 0, 1, 0),
          Unit('gauss', 'G', 0, 0.0001, 0),
        ],
        color: Colors.blueGrey,
      ),
      BasicCategory('Flow', NovaIcons.cursor_arrow_1,
        [
          Unit('cubic meter per second', 'm³/s', 0, 1, 0),
          Unit('gallon per minute', 'gal/min', 0, 0.0000630901964, 0),
          Unit('cubic foot per minute', 'ft³/min', 0, 0.0004719474432, 0),
          Unit('cubic inch per minute', 'in³/min', 0, 0.000000273117733333, 0),
        ],
        color: Colors.indigo,
      ),
      BasicCategory('Luminous Intensity', NovaIcons.lamp_studio_1,
        [
          Unit('candela', 'cd', 0, 1, 0),
          Unit('candlepower (new)', 'cp', 0, 1, 0),
          Unit('candlepower (old, pre-1948)', 'cp', 0, 0.981, 0),
        ],
        color: Colors.amber,
      ),
      BasicCategory('Luminance', NovaIcons.lamp_studio_1,
        [
          Unit('candela per square meter', 'cd/m²', 0, 1, 0),
          Unit('footlambert', 'fL', 0, 3.4262590996, 0),
          Unit('lambert', 'L', 0, 3183.0988618, 0),
          Unit('stilb', 'sb', 0, 10000, 0),
        ],
        color: Colors.grey,
      ),
      BasicCategory('Illuminance', NovaIcons.lamp_studio_1,
        [
          Unit('lux', 'lx', 0, 1, 0),
          Unit('phot', 'ph', 0, 10000, 0),
          Unit('lumen per square inch', 'lm/in²', 0, 1550.0031, 0),
          Unit('footcandle', 'fc', 0, 10.763910417, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Radioactive Activity', NovaIcons.atomic_bomb,
        [
          Unit('becquerel', 'Bq', 0, 1, 0),
          Unit('curie', 'Ci', 0, 37000000000, 0),
          Unit('rutherford', 'rd', 0, 1000000, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Radiation Absorption', NovaIcons.atomic_bomb,
        [
          Unit('gray', 'Gy', 0, 1, 0),
          Unit('rad', 'rad', 0, 0.01, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Radiation Equivalent', NovaIcons.atomic_bomb,
        [
          Unit('sievert', 'Sv', 0, 1, 0),
          Unit('Röntgen equivalent man', 'rem', 0, 0.01, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Mass', NovaIcons.gold_nuggets,
        [
          Unit('kilogram', 'kg', 0, 1, 0),
          Unit('gram', 'g', 0, 0.001, 0),
          Unit('ton', 't', 0, 1000, 0),
          Unit('ounce', 'oz', 0, 0.028, 0),
          Unit('pound', 'lb', 0, 0.5, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Density', NovaIcons.gold_nuggets,
        [
          Unit('kilogram per cubic meter', 'kg/m³', 0, 1, 0),
          Unit('gram per milliliter', 'g/mL', 0, 1000, 0),
          Unit('kilogram per liter', 'kg/L', 0, 1000, 0),
          Unit('ounce per cubic inch', 'oz/in³', 0, 1729.994044, 0),
          Unit('pound per cubic inch', 'lb/in³', 0, 27679.90471, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Frequency', NovaIcons.synchronize_1,
        [
          Unit('hertz', 'Hz', 0, 1, 0),
          Unit('revolutions per minute', 'rpm', 0, 0.01666666666666667, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Data', NovaIcons.cloud,
        [
          Unit('bit', 'b', 0, 1, 0),
          Unit('byte', 'B', 0, 8, 0),
          Unit('kilobyte', 'kB', 0, 8000, 0),
          Unit('megabyte', 'MB', 0, 8000000, 0),
          Unit('gigabyte', 'GB', 0, 8000000000, 0),
          Unit('terabyte', 'TB', 0, 8000000000000, 0),
          Unit('petabyte', 'PB', 0, 8000000000000000, 0),
          Unit('crumb', '', 0, 2, 0),
          Unit('nibble', '', 0, 4, 0),
          Unit('trit', '', 0, 1.585, 0),
          Unit('decit', '', 0, 3.322, 0),
          Unit('nat', '', 0, 1.443, 0),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Permeability', NovaIcons.vector_square_1,
        [
          Unit('m²', 'm²', 0, 1, 0),
          Unit('darcy', 'd', 0, 0.0000000000009869233, 0),
          Unit('millidarcy', 'md', 0, 0.0000000000000009869233, 0),
        ],
        color: Colors.blue,
      ),
    ];
    Storage.favoriteCategories = await Storage.readFavoriteCategories();
  }

  int _currentTab = 0;
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
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: _buildCategories(),
    );
  }

  static void _toggleFavoriteCategory(Category category) {
    if(Storage.favoriteCategories.contains(category)) Storage.favoriteCategories.remove(category);
    else Storage.favoriteCategories.add(category);
    Storage.saveFavoriteCategories();
  }

  Widget _buildCategoryCard(Category category){
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
            category.runtimeType == BasicCategory ? MaterialPageRoute(builder: (context) => ConversionView(category)) : category.route
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: FavoriteButton(category),
              ),
              Icon(category.icon, color: category.color, size: 35.0),
              SizedBox(height: 6.0),
              Expanded(
                child: Text(category.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategories() {
    if(_currentTab == 0) {
      return Storage.categories.map((category) => _buildCategoryCard(category)).toList();
    } else if (_currentTab == 1) {
      return Storage.favoriteCategories.map((category) => _buildCategoryCard(category)).toList();
    }
    return null;
  }

  void _onAppbarDropdownSelected(String value) {
    if(value == 'About') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AboutView())
      );
    } else if(value == 'Settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsView())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _onAppbarDropdownSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'About',
                child: Text('About'),
              ),
              PopupMenuItem(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initialize(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text(
                  'Connection not started.',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              );
            case ConnectionState.active:
            case ConnectionState.waiting:
            return Center(child: Container(width: 100.0, height: 100.0, child: CircularProgressIndicator()));
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                );
              return CustomScrollView(
                slivers: <Widget>[
                  _buildTab(),
                ],
                key: PageStorageKey(_currentTab.toString()),
              );
            default: return null;
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.pencil_ruler),
            title: Text('Converters'),
          ),
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.vote_heart_circle_1),
            title: Text('Favorite'),
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

class FavoriteButton extends StatefulWidget {
  final Category category;

  FavoriteButton(this.category);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _MainViewState._toggleFavoriteCategory(widget.category);
        setState(() {});
      },
      child: Icon(Storage.favoriteCategories.contains(widget.category) ? Icons.star : Icons.star_border, size: 25.0, color: Colors.amber),
    );
  }
}