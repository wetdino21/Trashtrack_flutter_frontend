import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/appbar.dart';
import 'package:trashtrack/bottom_nav_bar.dart';
import 'package:trashtrack/drawer.dart';
import 'package:trashtrack/home.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';

class MainApp extends StatefulWidget {
  final int? selectedIndex;
  LatLng? pickupPoint;
  int? bookID;

  MainApp({this.selectedIndex, this.pickupPoint, this.bookID});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Logger logger = Logger();
  //user data
  Map<String, dynamic>? userData;
  String? user;

  int _selectedIndex = 0;
  bool Loading = false;

  @override
  void initState() {
    super.initState();
    _dbData();

    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }
  }

  // // Define pages
  List<Widget> get _pages {
    return [
      C_HomeScreen(),
      C_MapScreen(
        pickupPoint: widget.pickupPoint,
        bookID: widget.bookID,
      ),
      C_ScheduleScreen(),
      C_PaymentScreen(),
    ];
  }
  // final List<Widget> _pages = [
  //   C_HomeScreen(),
  //   C_MapScreen(),
  //   C_ScheduleScreen(),
  //   C_PaymentScreen(),
  // ];

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        widget.pickupPoint = null; // Reset pickupPoint
        widget.bookID = null;
      });
    }
    setState(() {
      _selectedIndex = index; // Update the selected index when tapped
    });
  }

  Future<void> _dbData() async {
    try {
      setState(() {
        Loading = true;
      });
      //await notificationCount(); //notification count
      //if(!mounted) return;
      await storeDataInHive(context); // user data

      final data = await userDataFromHive();

      Provider.of<UserModel>(context, listen: false).setUserData(
        newId: data['id'].toString(),
        newFname: data['fname'],
        newLname: data['lname'],
        newEmail: data['email'],
        newAuth: data['auth'],
        newProfile: data['profile'],
      );

      setState(() {
        //userData = data; //isnt used
        String? usertype = data['user'];
        user = usertype;
        Loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        Loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Loading
        ? Scaffold(
            backgroundColor: deepPurple,
            body: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 10,
                        strokeAlign: 2,
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            drawer: C_Drawer(),
            appBar: C_CustomAppBar(
                title: _selectedIndex == 0
                    ? 'Home'
                    : _selectedIndex == 1
                        ? 'Map'
                        : _selectedIndex == 2
                            ? 'Schedule'
                            : user == 'hauler'
                                ? 'Vehicle'
                                : 'Payment'),
            body: _pages[_selectedIndex],
            bottomNavigationBar: C_BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
  }
}
