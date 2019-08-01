import 'package:flutter/material.dart';
import 'presentation/nova_icons.dart';

void main() => runApp(MyApp());

class Topic {
  final String name;
  final Icon icon;
  final String route;

  Topic(this.name, this.icon, {this.route});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  List<Topic> _basicTopics = [
    Topic('Length', Icon(NovaIcons.tools_measuring_tape)),
    Topic('Area', Icon(NovaIcons.vector_square_1)),
    Topic('Volume', Icon(NovaIcons.box_2)),
    Topic('Temperature', Icon(NovaIcons.fire_lighter)),
    Topic('Weight', Icon(NovaIcons.sport_dumbbell_1)),
    Topic('Speed', Icon(NovaIcons.video_control_fast_forward)),
    Topic('Time', Icon(NovaIcons.calendar_1)),
  ];
  List<Topic> _scienceTopics = [
    Topic('Pressure', Icon(NovaIcons.water_droplet)),
    Topic('Energy', Icon(NovaIcons.flash)),
    Topic('Force', Icon(NovaIcons.cursor_arrow_1)),
    Topic('Current', Icon(NovaIcons.battery_charging_1)),
  ];
  List<Topic> _financeTopics = [
    Topic('Tip', Icon(NovaIcons.banking_spendings_1)),
    Topic('Loan', Icon(NovaIcons.business_briefcase_cash)),
    Topic('Currency', Icon(NovaIcons.location_pin_bank_2)),
  ];

  Widget _buildTab() {
    return SliverGrid.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: _buildTopics(),
    );
  }

  Widget _buildTopicCard(Topic topic){
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {},
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

  List<Widget> _buildTopics() {
    if(_currentTab == 0) {
      return _basicTopics.map((topic) => _buildTopicCard(topic)).toList();
    } else if (_currentTab == 1) {
      return _scienceTopics.map((topic) => _buildTopicCard(topic)).toList();
    } else {
      return _financeTopics.map((topic) => _buildTopicCard(topic)).toList();
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
