import 'package:flutter/material.dart';
import 'package:vibes_app/Widgets/drawer.dart';
import 'package:vibes_app/pages/homePage.dart';

import 'menu_page.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() => BottomNavigationBarPageState ();
}

class BottomNavigationBarPageState  extends State<BottomNavigationBarPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MenuPage(category: "all",),
    Center(child: Text('Index 3: Hotel', style: TextStyle(color: Colors.black))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      extendBody: true,// This allows the body to extend behind the bottom navigation bar
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: EdgeInsets.all(8),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', 0),
          _buildNavItem(Icons.fastfood, 'All Menu', 1),
          _buildNavItem(Icons.hotel_sharp, 'Hotel', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.green : Colors.white,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }
}