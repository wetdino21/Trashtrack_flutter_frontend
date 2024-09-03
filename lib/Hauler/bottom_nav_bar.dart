import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, 'home');
        break;
      case 1:
        Navigator.pushNamed(context, 'map');
        break;
      case 2:
        Navigator.pushNamed(context, 'schedule');
        break;
      case 3:
        Navigator.pushNamed(context, 'vehicle');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0
              ? Icon(Icons.home)
              : Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1
              ? Icon(Icons.map)
              : Icon(Icons.map_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? Icon(Icons.calendar_month)
              : Icon(Icons.calendar_month_outlined),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 3
              ? Icon(Icons.directions_car)
              : Icon(Icons.directions_car_filled_outlined),
          label: 'Vehicle',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.white,
      selectedIconTheme: IconThemeData(),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 12),
    );
  }
}
