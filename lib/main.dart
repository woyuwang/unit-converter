import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/settings.dart';
import 'package:unit_converter/tip-conversion.dart';
import 'about.dart';
import 'conversion.dart';
import 'converter.dart';
import 'presentation/nova_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reorderables/reorderables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.readDarkMode();
  runApp(MyApp());
}

abstract class Category {
  final String name;
  final IconData icon;
  final Color color;
  List<Unit> units;
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
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Storage.darkMode ? Color.fromRGBO(200, 200, 200, 1) : Color.fromRGBO(50, 50, 50, 1),
        ),
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
  static List<int> convertersOrder;
  static List<int> favoritesOrder;
  static List<Unit> _currencyUnits = List<Unit>();
  static DateTime _lastCurrencyRequest;

  static Future<List<Unit>> loadCurrency() async {
    if(_currencyUnits.length == 0 || _lastCurrencyRequest.difference(DateTime.now()).inHours > 6) {
      var url = 'https://api.exchangeratesapi.io/latest';
      http.Response response = await http.get(url);
      var decoded = json.decode(response.body);
      List<Unit> res = List<Unit>();
      res.add(Unit(decoded['base'], decoded['base'], 0, 1, 0, isSI: true));
      var map = decoded['rates'];
      for (int i = 0; i < map.length; i++) {
        res.add(Unit(map.keys.toList()[i], map.keys.toList()[i], 0, map.values.toList()[i], 0));
      }
      _currencyUnits = res;
      _lastCurrencyRequest = DateTime.tryParse(decoded['date']);
      return _currencyUnits;
    } else return _currencyUnits;
  }

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

  static Future<List<int>> readConvertersOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> order = prefs.getStringList('converters');
    List<int> res = List<int>();
    if(order == null) {
      for(int i = 0; i < categories.length; i++) {res.add(i);}
      convertersOrder = res;
      saveConvertersOrder();
    } else {
      for(int i = 0; i < order.length; i++) {res.add(int.tryParse(order[i]));}
    }
    return res;
  }

  static saveConvertersOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> order = List<String>();
    for(int i = 0; i < convertersOrder.length; i++) {
      order.add(convertersOrder[i].toString());
    }
    prefs.setStringList('converters', order);
  }

  static Future<List<int>> readFavoritesOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> order = prefs.getStringList('favorites');
    List<int> res = List<int>();
    if(order == null || order.length != favoriteCategories.length) {
      for(int i = 0; i < favoriteCategories.length; i++) {res.add(i);}
      favoritesOrder = res;
      saveFavoritesOrder();
    } else {
      for(int i = 0; i < order.length; i++) {res.add(int.tryParse(order[i]));}
    }
    return res;
  }

  static saveFavoritesOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> order = List<String>();
    for(int i = 0; i < favoritesOrder.length; i++) {
      order.add(favoritesOrder[i].toString());
    }
    prefs.setStringList('favorites', order);
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
      BasicCategory('Currency', NovaIcons.location_pin_bank_2, [], color: Colors.indigo,
      ),
      BasicCategory('Length', NovaIcons.tools_measuring_tape,
        [
          Unit('Meter', 'm', 0, 1, 0, isSI: true),
          Unit('Inch', 'in', 0, 1/0.0254, 0),
          Unit('Foot', 'ft', 0, 1/0.3048000000012192000000048768000000195072000000780288000003121152000012484608000049938432000199753728, 0),
          Unit('Kilometer', 'km', 0, 1/1000, 0),
          Unit('Yard', 'yd', 0, 1/0.9144000000036576000000146304000000585216000002340864000009363456000037453824000149815296000599261184, 0),
          Unit('Mile', 'mi', 0, 1/1609.347219, 0),
          Unit('Astronomical Unit', 'AU', 0, 1/149597870700, 0),
          Unit('Parsec', 'pc', 0, 1/30856775814913700, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Area', NovaIcons.vector_square_1,
        [
          Unit('Square Meter', 'm²', 0, 1, 0, isSI: true),
          Unit('Acre', 'ac', 0, 1/4046.8564224, 0),
          Unit('Square Foot', 'sq ft', 0, 1/0.092903411613275, 0),
          Unit('Square Inch', 'sq in', 0, 1/0.00064516, 0),
          Unit('Square Kilometer', 'km²', 0, 1/1000000, 0),
          Unit('Square Mile', 'sw mi', 0, 1/2589988.110336, 0),
          Unit('Square Yard', 'sq yd', 0, 1/0.83612736, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Volume', NovaIcons.box_2,
        [
          Unit('Cubic Meter', 'm³', 0, 1, 0, isSI: true),
          Unit('Cubic Inch', 'in³', 0, 1/0.000016387, 0),
          Unit('Teaspoon', 'tsp', 0, 1/0.000005, 0),
          Unit('Liter', 'L', 0, 1/0.001, 0),
          Unit('Lambda', 'λ', 0, 1/0.000000001, 0),
          Unit('Cup (metric)', 'c', 0, 1/0.0002500, 0),
          Unit('Pint (US fluid)', 'pt', 0, 1/0.000473176473, 0),
          Unit('Quart (US fluid)', 'qt', 0, 1/0.000946352946, 0),
          Unit('Gallon (US fluid)', 'gal', 0, 1/0.003785411784, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Temperature', NovaIcons.fire_lighter,
        [
          Unit('Kelvin', 'K', 0, 1, 0, isSI: true),
          Unit('Celsius', '°C', 0, 1, -273.15),
          Unit('Fahrenheit', '°F', -273.15, 9 / 5, 32),
          Unit('Rankine', '°R;', 0, 9 / 5, 0),
          Unit('Delisle', '°De', -373.15, -3 / 2, 0),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Speed', NovaIcons.video_control_fast_forward,
        [
          Unit('Meter per Second', 'm/s', 0, 1, 0, isSI: true),
          Unit('Knot', 'kn', 0, 1/0.514444444444, 0),
          Unit('Mile per Hour', 'mph', 0, 1/0.44704, 0),
          Unit('Speed of Light in Vacuum', 'c', 0, 1/299792458, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Time', NovaIcons.calendar_1,
        [
          Unit('Second', 's', 0, 1, 0, isSI: true),
          Unit('Minute', 'min', 0, 1/60, 0),
          Unit('Hour', 'h', 0, 1/3600, 0),
          Unit('Day', 'd', 0, 1/86400, 0),
          Unit('Week', 'wk', 0, 1/604800, 0),
          Unit('Month', 'mo', 0, 1/2592000, 0),
          Unit('Year', 'yr', 0, 1/31536000, 0),
        ],
        color: Colors.amber,
      ),
      BasicCategory('Plane Angle', NovaIcons.vector_triangle,
        [
          Unit('Radian', 'rad', 0, 1, 0, isSI: true),
          Unit('Degree', '°', 0, 1/0.017453293, 0),
          Unit('Gradian', 'grad', 0, 1/0.015707963, 0),
          Unit('Quadrant', '', 0, 1/1.570796, 0),
          Unit('Octant', '', 0, 1/0.785398, 0),
          Unit('Sextant', '', 0, 1/1.047198, 0),
          Unit('Sign', '', 0, 1/0.523599, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Solid Angle', NovaIcons.vector_triangle,
        [
          Unit('Steradian', 'sr', 0, 1, 0, isSI: true),
          Unit('Square degree', 'deg²', 0, 1/0.00030462, 0),
          Unit('Spat', '', 0, 1/12.56637, 0),
        ],
        color: Colors.blueGrey,
      ),
      BasicCategory('Force', NovaIcons.cursor_arrow_1,
        [
          Unit('Newton', 'N', 0, 1, 0, isSI: true),
          Unit('Pound-Force', 'lbf', 0, 1/4.4482216152605, 0),
          Unit('Ounce-Force', 'ozf', 0, 1/0.27801385095378125, 0),
          Unit('Dyne', 'dyn', 0, 1/0.0001, 0),
          Unit('Kilogram-Force', 'kgf', 0, 1/9.80665, 0),
        ],
        color: Colors.orange,
      ),
      BasicCategory('Acceleration', NovaIcons.video_control_fast_forward,
        [
          Unit('Meter/Second Squared', 'm/s²', 0, 1, 0, isSI: true),
          Unit('Mile per Hour/Sec', 'mph/s', 0, 1/0.44704, 0),
          Unit('Standard Gravity', 'g₀', 0, 1/9.80665, 0),
          Unit('Foot per Minute/Sec', 'fpm/s', 0, 1/0.00508, 0),
          Unit('Inch per Minute/Sec', 'ipm/s', 0, 1/0.000423333333333, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Pressure', NovaIcons.water_droplet,
        [
          Unit('Pascal', 'Pa', 0, 1, 0, isSI: true),
          Unit('Atmosphere', 'atm', 0, 1/101325, 0),
          Unit('Bar', 'bar', 0, 1/100000, 0),
          Unit('Centimeter of Mercury', 'cmHg', 0, 1/1333.22, 0),
          Unit('Centimeter of Water (4°C)', 'cmH₂O', 0, 1/98.0638, 0),
          Unit('Pound per Square Inch', 'psi', 0, 1/6894.757, 0),
          Unit('Torr', 'torr', 0, 760 / 101325, 0),
        ],
        color: Colors.yellow,
      ),
      BasicCategory('Torque', NovaIcons.synchronize_1,
        [
          Unit('Newton Meter', 'N·m', 0, 1, 0, isSI: true),
          Unit('Kilogram Force-Meter', 'kgf·m', 0, 1/9.80665, 0),
          Unit('Pound Force-Foot', 'lbf·ft', 0, 1/1.3558179483314004, 0),
        ],
        color: Colors.grey,
      ),
      BasicCategory('Energy', NovaIcons.sport_dumbbell_1,
        [
          Unit('Joule', 'J', 0, 1, 0, isSI: true),
          Unit('Electronvolt', 'eV', 0, 1/0.000000000000000000160217656535, 0),
          Unit('Calorie', 'cal', 0, 1/4184, 0),
          Unit('Barrel of Oil Equivalent', 'boe', 0, 1/6120000000, 0),
          Unit('Foot-Pound Force', 'ft lbf', 0, 1/1.3558179483314004, 0),
          Unit('Ton of Coal Equivalent', 'TCE', 0, 1/29288000000, 0),
          Unit('Ton of Oil Equivalent', 'toe', 0, 1/41868000000, 0),
          Unit('Ton of TNT', 'tTNT', 0, 1/4184000000, 0),
        ],
        color: Colors.indigo,
      ),
      BasicCategory('Power', NovaIcons.flash,
        [
          Unit('Watt', 'W', 0, 1, 0, isSI: true),
          Unit('Horsepower (metric)', 'hp', 0, 1/735.49875, 0),
          Unit('BTU per Minute', 'BTU/min', 0, 1/17.584264, 0),
          Unit('Atmosphere-Cubic Feet/Minute', 'atm cfm', 0, 1/47.82007468224, 0),
          Unit('Liter-Atmosphere/Minute', 'L·atm/min', 0, 1/1.68875, 0),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Dynamic Viscosity', NovaIcons.water_droplet,
        [
          Unit('Pascal Pecond', 'Pa·s', 0, 1, 0, isSI: true),
          Unit('Pound per Foot Second', 'lb/(ft·s)', 0, 1/1.488164, 0),
          Unit('Poise', 'P', 0, 1/0.1, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Kinematic Viscosity', NovaIcons.water_droplet,
        [
          Unit('Square Meter per Second', 'm²/s', 0, 1, 0, isSI: true),
          Unit('Square Foot per Second', 'ft²/s', 0, 1/0.09290304, 0),
          Unit('Stokes', 'St', 0, 1/0.001, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Current', NovaIcons.battery_charging_1,
        [
          Unit('Ampere', 'A', 0, 1, 0, isSI: true),
          Unit('Emu, Abampere', 'abamp', 0, 1/10, 0),
          Unit('Esu per Second', 'esu/s', 0, 1/0.0000000003335641, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Charge', NovaIcons.cursor_arrow_1,
        [
          Unit('Coulomb', 'C', 0, 1, 0, isSI: true),
          Unit('Faraday', 'F', 0, 1/96485.3383, 0),
          Unit('Atomic Unit of Charge', 'au', 0, 1/0.0000000000000000001602176, 0),
          Unit('Milliampere Hour', 'mA·h', 0, 1/3.6, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Dipole', NovaIcons.synchronize_2,
        [
          Unit('Coulomb Meter', 'C·m', 0, 1, 0, isSI: true),
          Unit('Debye', 'D', 0, 1/0.000000000000000000000000000003335646, 0),
          Unit('Electric Dipole Moment', 'ea₀', 0, 1/0.000000000003335646, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Electromotive Force', NovaIcons.sport_dumbbell_1,
        [
          Unit('Volt', 'V', 0, 1, 0, isSI: true),
          Unit('Statvolt', 'statV', 0, 1/299.792458, 0),
          Unit('Abvolt', 'abV', 0, 1/0.00000001, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Magnetic Flux', NovaIcons.synchronize_2,
        [
          Unit('Weber', 'Wb', 0, 1, 0, isSI: true),
          Unit('Maxwell', 'Mx', 0, 1/0.00000001, 0),
        ],
        color: Colors.yellow,
      ),
      BasicCategory('Magnetic Flux Density', NovaIcons.synchronize_2,
        [
          Unit('Tesla', 'T', 0, 1, 0, isSI: true),
          Unit('Gauss', 'G', 0, 1/0.0001, 0),
        ],
        color: Colors.blueGrey,
      ),
      BasicCategory('Flow', NovaIcons.cursor_arrow_1,
        [
          Unit('Cubic Meter per Second', 'm³/s', 0, 1, 0, isSI: true),
          Unit('Gallon per Minute', 'gal/min', 0, 1/0.0000630901964, 0),
          Unit('Cubic Foot per Minute', 'ft³/min', 0, 1/0.0004719474432, 0),
          Unit('Cubic Inch per Minute', 'in³/min', 0, 1/0.000000273117733333, 0),
        ],
        color: Colors.indigo,
      ),
      BasicCategory('Luminous Intensity', NovaIcons.lamp_studio_1,
        [
          Unit('Candela', 'cd', 0, 1, 0, isSI: true),
          Unit('Candlepower (new)', 'cp', 0, 1, 0),
          Unit('Candlepower (old, pre-1948)', 'cp', 0, 1/0.981, 0),
        ],
        color: Colors.amber,
      ),
      BasicCategory('Luminance', NovaIcons.lamp_studio_1,
        [
          Unit('Candela per Square Meter', 'cd/m²', 0, 1, 0, isSI: true),
          Unit('Footlambert', 'fL', 0, 1/3.4262590996, 0),
          Unit('Lambert', 'L', 0, 1/3183.0988618, 0),
          Unit('Stilb', 'sb', 0, 1/10000, 0),
        ],
        color: Colors.grey,
      ),
      BasicCategory('Illuminance', NovaIcons.lamp_studio_1,
        [
          Unit('Lux', 'lx', 0, 1, 0, isSI: true),
          Unit('Phot', 'ph', 0, 1/10000, 0),
          Unit('Lumen per Square Inch', 'lm/in²', 0, 1/1550.0031, 0),
          Unit('Footcandle', 'fc', 0, 1/10.763910417, 0),
        ],
        color: Colors.blue,
      ),
      BasicCategory('Radioactive Activity', NovaIcons.atomic_bomb,
        [
          Unit('Becquerel', 'Bq', 0, 1, 0, isSI: true),
          Unit('Curie', 'Ci', 0, 1/37000000000, 0),
          Unit('Rutherford', 'rd', 0, 1/1000000, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Radiation Absorption', NovaIcons.atomic_bomb,
        [
          Unit('Gray', 'Gy', 0, 1, 0, isSI: true),
          Unit('Rad', 'rad', 0, 1/0.01, 0),
        ],
        color: Colors.green,
      ),
      BasicCategory('Radiation Equivalent', NovaIcons.atomic_bomb,
        [
          Unit('Sievert', 'Sv', 0, 1, 0, isSI: true),
          Unit('Röntgen Equivalent Man', 'rem', 0, 1/0.01, 0),
        ],
        color: Colors.teal,
      ),
      BasicCategory('Mass', NovaIcons.gold_nuggets,
        [
          Unit('Kilogram', 'kg', 0, 1, 0, isSI: true),
          Unit('Gram', 'g', 0, 1/0.001, 0),
          Unit('Ton', 't', 0, 1/1000, 0),
          Unit('Ounce', 'oz', 0, 1/0.028, 0),
          Unit('Pound', 'lb', 0, 1/0.5, 0),
        ],
        color: Colors.red,
      ),
      BasicCategory('Density', NovaIcons.gold_nuggets,
        [
          Unit('Kilogram per Cubic Meter', 'kg/m³', 0, 1, 0, isSI: true),
          Unit('Gram per Milliliter', 'g/mL', 0, 1/1000, 0),
          Unit('Kilogram per Liter', 'kg/L', 0, 1/1000, 0),
          Unit('Ounce per Cubic Inch', 'oz/in³', 0, 1/1729.994044, 0),
          Unit('Pound per Cubic Inch', 'lb/in³', 0, 1/27679.90471, 0),
        ],
        color: Colors.lime,
      ),
      BasicCategory('Frequency', NovaIcons.synchronize_1,
        [
          Unit('Hertz', 'Hz', 0, 1, 0, isSI: true),
          Unit('Revolutions per Minute', 'rpm', 0, 1/0.01666666666666667, 0),
        ],
        color: Colors.purple,
      ),
      BasicCategory('Data', NovaIcons.cloud,
        [
          Unit('Bit', 'b', 0, 1, 0, isSI: true),
          Unit('Byte', 'B', 0, 1/8, 0),
          Unit('Kilobyte', 'kB', 0, 1/8000, 0),
          Unit('Megabyte', 'MB', 0, 1/8000000, 0),
          Unit('Gigabyte', 'GB', 0, 1/8000000000, 0),
          Unit('Terabyte', 'TB', 0, 1/8000000000000, 0),
          Unit('Petabyte', 'PB', 0, 1/8000000000000000, 0),
          Unit('Crumb', '', 0, 1/2, 0),
          Unit('Nibble', '', 0, 1/4, 0),
          Unit('Trit', '', 0, 1/1.585, 0),
          Unit('Decit', '', 0, 1/3.322, 0),
          Unit('Nat', '', 0, 1/1.443, 0),
        ],
        color: Colors.pink,
      ),
      BasicCategory('Permeability', NovaIcons.vector_square_1,
        [
          Unit('Meter Squared', 'm²', 0, 1, 0, isSI: true),
          Unit('Darcy', 'd', 0, 1/0.0000000000009869233, 0),
          Unit('Millidarcy', 'md', 0, 1/0.0000000000000009869233, 0),
        ],
        color: Colors.blue,
      ),
    ];
    Storage.favoriteCategories = await Storage.readFavoriteCategories();
    Storage.convertersOrder = await Storage.readConvertersOrder();
    Storage.favoritesOrder = await Storage.readFavoritesOrder();
  }

  int _currentTab = 0;

  Widget _buildTab() {
    return Center(
      child: ReorderableWrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: _buildCategories(),
        onReorder: _reorderCategories,
      ),
    );
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    if(_currentTab == 0) {
      int i = Storage.convertersOrder.removeAt(oldIndex);
      Storage.convertersOrder.insert(newIndex, i);
      Storage.saveConvertersOrder();
    } else {
      int i = Storage.favoritesOrder.removeAt(oldIndex);
      Storage.favoritesOrder.insert(newIndex, i);
      Storage.saveFavoritesOrder();
    }
    setState(() {});
  }

  static void _toggleFavoriteCategory(Category category) {
    if(Storage.favoriteCategories.contains(category)) Storage.favoriteCategories.remove(category);
    else Storage.favoriteCategories.add(category);
    Storage.saveFavoriteCategories();
  }

  Widget _buildCategoryCard(Category category){
    return Container(
      width: 120.0,
      height: 120.0,
      child: Card(
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
      ),
    );
  }

  List<Widget> _buildCategories() {
    if(_currentTab == 0) {
      List<Widget> res = List<Widget>();
      for(int i = 0; i < Storage.convertersOrder.length; i++) {
        res.add(_buildCategoryCard(Storage.categories[Storage.convertersOrder[i]]));
      }
      return res;
    } else if (_currentTab == 1) {
      List<Widget> res = List<Widget>();
      for(int i = 0; i < Storage.favoritesOrder.length; i++) {
        res.add(_buildCategoryCard(Storage.favoriteCategories[Storage.favoritesOrder[i]]));
      }
      if(res.length == 0) {
        return [Padding(padding: const EdgeInsets.all(64.0), child: Text('Nothing in here yet! :)', style: TextStyle(fontSize: 20.0)))];
      } else return res;
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
              return Container(
                child: _buildTab(),
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
      child: Tooltip(child: Icon(Storage.favoriteCategories.contains(widget.category) ? Icons.star : Icons.star_border, size: 25.0, color: Colors.amber), message: 'Favorite'),
    );
  }
}