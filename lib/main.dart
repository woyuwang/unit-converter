import 'package:flutter/material.dart';
import 'conversion-view.dart';
import 'converter.dart';
import 'presentation/nova_icons.dart';

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
  int _currentTab = 0;
  List<Category> _basicCategories = [
    Category('Length', Icon(NovaIcons.tools_measuring_tape),
      [
        Unit('meter', 'm', 0, 1.0, 0),
        Unit('foot', 'ft', 0, 0.304800610, 0),
        Unit('kilometer', 'km', 0, 1000, 0),
        Unit('yard', 'yd', 0, 0.9144, 0),
      ],
    ),
    Category('Area', Icon(NovaIcons.vector_square_1),
      [],
    ),
    Category('Volume', Icon(NovaIcons.box_2),
      [],
    ),
    Category('Temperature', Icon(NovaIcons.fire_lighter),
      [],
    ),
    Category('Weight', Icon(NovaIcons.sport_dumbbell_1),
      [],
    ),
    Category('Speed', Icon(NovaIcons.video_control_fast_forward),
      [],
    ),
    Category('Time', Icon(NovaIcons.calendar_1),
      [],
    ),
  ];
  List<Category> _scienceCategories = [
    Category('Pressure', Icon(NovaIcons.water_droplet),
      [],
    ),
    Category('Energy', Icon(NovaIcons.flash),
      [],
    ),
    Category('Force', Icon(NovaIcons.cursor_arrow_1),
      [],
    ),
    Category('Current', Icon(NovaIcons.battery_charging_1),
      [],
    ),
  ];
  List<Category> _financeCategories = [
    Category('Tip', Icon(NovaIcons.banking_spendings_1),
      [],
    ),
    Category('Loan', Icon(NovaIcons.business_briefcase_cash),
      [],
    ),
    Category('Currency', Icon(NovaIcons.location_pin_bank_2),
      [],
    ),
  ];

  Widget _buildTab() {
    return SliverGrid.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: _buildCategories(),
    );
  }

  Widget _buildTopicCard(Category topic){
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
            MaterialPageRoute(builder: (context) => ConversionView(topic))
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              topic.icon,
              SizedBox(width: 16.0),
              Text(topic.name),
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
      return _scienceCategories.map((topic) => _buildTopicCard(topic)).toList();
    } else {
      return _financeCategories.map((topic) => _buildTopicCard(topic)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          _buildTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.pencil_ruler),
            title: Text('Basic'),
          ),
          BottomNavigationBarItem(
            icon: Icon(NovaIcons.beaker_science),
            title: Text('Science'),
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
