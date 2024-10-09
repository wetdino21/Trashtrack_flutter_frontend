import 'package:flutter/material.dart';

class C_BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  C_BottomNavBar({required this.currentIndex, required this.onTap});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name == 'c_map') {
          Navigator.of(context).pop(); // dispose if mapscreen
        }
        //if (currentIndex != 0) Navigator.pushNamed(context, 'c_home');
        break;
      case 1:
        //if (currentIndex != 1) Navigator.pushNamed(context, 'c_map');
        break;
      case 2:
        if (ModalRoute.of(context)?.settings.name == 'c_map') {
          Navigator.of(context).pop(); // dispose if mapscreen
        }
        //if (currentIndex != 2) Navigator.pushNamed(context, 'c_schedule');
        break;
      case 3:
        if (ModalRoute.of(context)?.settings.name == 'c_map') {
          Navigator.of(context).pop(); // dispose if mapscreen
        }
        //if (currentIndex != 3) Navigator.pushNamed(context, 'c_payment');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent, // Disable splash effect
        //highlightColor: Colors.transparent, // Disable highlight effect
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 21, 8, 44),
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: currentIndex == 0
                ? Icon(Icons.home)
                : Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:
                currentIndex == 1 ? Icon(Icons.map) : Icon(Icons.map_outlined),
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
        // onTap: (index) => _onItemTapped(context, index),
         onTap: onTap,  // Pass the selected index to the callback function
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        enableFeedback: true,
      ),
    );
  }
}
