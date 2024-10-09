import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/Customer/c_drawer.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/user_hive_data.dart';

class MainApp extends StatefulWidget {
  final int? selectedIndex;

  MainApp({this.selectedIndex});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  // Define pages here
  final List<Widget> _pages = [
    C_HomeScreen(),
    C_MapScreen(),
    C_ScheduleScreen(),
    C_PaymentScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _dbData();

    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index when tapped
    });
  }

  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      Provider.of<UserModel>(context, listen: false).setUserData(
          data['id'].toString(),
          data['fname'],
          data['lname'],
          data['email'],
          data['auth'],
          data['profile']);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: C_Drawer(),
      appBar: C_CustomAppBar(
          title: _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
                  ? 'Map'
                  : _selectedIndex == 2
                      ? 'Schedule'
                      : 'Payment'), // Update title based on the page
      body: _pages[_selectedIndex], // Change the body based on selected index
      bottomNavigationBar: C_BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
