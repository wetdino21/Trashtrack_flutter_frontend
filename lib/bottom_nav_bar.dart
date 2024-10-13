import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trashtrack/main.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class C_BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  C_BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  State<C_BottomNavBar> createState() => _C_BottomNavBarState();
}

class _C_BottomNavBarState extends State<C_BottomNavBar> {
  //user data
  Map<String, dynamic>? userData;
  String user = 'customer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await userDataFromHive();
    setState(() {
      userData = data;
      user = data['user'];
      print(user);
    });
  }

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
        currentIndex: widget.currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: widget.currentIndex == 0
                ? Icon(Icons.home)
                : Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 1
                ? Icon(Icons.map)
                : Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 2
                ? Icon(Icons.calendar_month)
                : Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: widget.currentIndex == 3 && user == 'customer'
                ? Icon(
                    user == 'customer' ? Icons.payment : Icons.directions_car)
                : Icon(user == 'customer'
                    ? Icons.payment_outlined
                    : Icons.directions_car_filled_outlined),
            label: user == 'customer' ? 'Payment' : 'Vehicle',
          ),
        ],
        // onTap: (index) => _onItemTapped(context, index),
        onTap: widget.onTap, // Pass the selected index to the callback function
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        enableFeedback: true,
      ),
    );
  }
}
