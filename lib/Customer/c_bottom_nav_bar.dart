import 'package:flutter/material.dart';

class C_BottomNavBar extends StatelessWidget {
  final int currentIndex;

  C_BottomNavBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
      if(currentIndex!=0)
        Navigator.pushNamed(context, 'c_home');
        break;
      case 1:
      if(currentIndex!=1)
        Navigator.pushNamed(context, 'c_map');
        break;
      case 2:
      if(currentIndex!=2)
        Navigator.pushNamed(context, 'c_schedule');
        break;
      case 3:
      if(currentIndex!=3)
        Navigator.pushNamed(context, 'c_payment');
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
              ? Icon(Icons.payment)
              : Icon(Icons.payment_outlined),
          label: 'Payment',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 12),
    );
  }
}
