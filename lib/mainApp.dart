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
import 'package:latlong2/latlong.dart';
import 'package:trashtrack/vehicle.dart';

class MainApp extends StatefulWidget {
  final int? selectedIndex;
  LatLng? pickupPoint;
  int? bookID;
  String? bookStatus;

  MainApp({this.selectedIndex, this.pickupPoint, this.bookID, this.bookStatus});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AudioService _audioService = AudioService(); //from modal
  //user data
  Map<String, dynamic>? userData;
  String? user;

  int _selectedIndex = 0;
  bool loading = false;
  bool firstLoad = true;
  //animate
  bool isHome = false;
  double height = 0.3;
  double position = 0;
  UserModel? userModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _dbData();

    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }

    // //load all resource
    // if (firstLoad && _selectedIndex == 0) {
    //   Future.delayed(const Duration(seconds: 3), () {
    //     setState(() {
    //       firstLoad = false;
    //     });
    //   });
    // }

    if (_selectedIndex != 0) {
      firstLoad = false;
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _dbData() async {
    try {
      setState(() {
        loading = true;
      });
      //await notificationCount(); //notification count
      //if(!mounted) return;
      await storeDataInHive(context); // user data
      final data = await userDataFromHive();

      userModel!.setUserData(
        newId: data['id'].toString(),
        newFname: data['fname'],
        newLname: data['lname'],
        newEmail: data['email'],
        newAuth: data['auth'],
        newProfile: data['profile'],
        newNotifCount: data['notif_count'],
      );
      // Provider.of<UserModel>(context, listen: false).setUserData(
      //   newId: data['id'].toString(),
      //   newFname: data['fname'],
      //   newLname: data['lname'],
      //   newEmail: data['email'],
      //   newAuth: data['auth'],
      //   newProfile: data['profile'],
      //   newNotifCount: data['notif_count'],
      // );

      setState(() {
        //userData = data; //isnt used
        String? usertype = data['user'];
        user = usertype;
        loading = false;

        //load all resource
        if (firstLoad && _selectedIndex == 0) {
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              firstLoad = false;
            });
          });
        }
      });
    } catch (e) {
      console(e.toString());
      if (!mounted) return;
      // setState(() {
      //   Loading = false;
      // });
    }
  }

  //animation
  void _startAnimation() async {
    setState(() {
      height = 0.3;
      position = 0;
    });
    // First, wait for a moment
    await Future.delayed(Duration(milliseconds: 10));

    // Animate height change
    if (!mounted) return;
    setState(() {
      height = 1; // Expand height to 80%
    });

    // Wait for height animation to complete
    await Future.delayed(Duration(milliseconds: 100));

    // Now move the image to the right
    if (!mounted) return;
    setState(() {
      position = MediaQuery.of(context).size.width; // Move it off-screen
    });
  }

  //sound
  Future<void> _playSound() async {
    await _audioService.playPressSound();
  }

  // // Define pages
  List<Widget> get _pages {
    return [
      C_HomeScreen(),
      C_MapScreen(pickupPoint: widget.pickupPoint, bookID: widget.bookID, bookStatus: widget.bookStatus),
      C_ScheduleScreen(),
      user == null
          ? Container()
          : user == 'customer'
              ? C_PaymentScreen()
              : user == 'hauler'
                  ? VehicleScreen()
                  : Container(),
    ];
  }

  //ontappppppppppppppp
  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        loading = true;
      });
      _startAnimation();
      userModel!.setIsHome(true);
      //

      if (_selectedIndex != index) {
        _playSound();
        setState(() {
          _selectedIndex = index;
        });
      }
      //
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          loading = false;
        });
      });
    } else {
      // Normal behavior for other indices
      if (_selectedIndex != index) {
        _playSound();
        setState(() {
          _selectedIndex = index;
        });
      }
    }

    // Reset data if index is not 1
    if (index != 1) {
      setState(() {
        widget.pickupPoint = null; // Reset pickupPoint
        widget.bookID = null;
        widget.bookStatus = null;
      });
    }
  }

  // void _onItemTapped(int index) {
  //   if (index != 1) {
  //     setState(() {
  //       widget.pickupPoint = null; // Reset pickupPoint
  //       widget.bookID = null;
  //       widget.bookStatus = null;
  //     });
  //   }

  //   if (_selectedIndex != index) {
  //     _playSound();
  //     setState(() {
  //       _selectedIndex = index; // Update the selected index when tapped
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        if (!loading)
          Scaffold(
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
          ),
        if (loading || firstLoad) showLoadingIconAnimate(),
        if (userModel!.isToHome) showLoadingMovingTruck(context, height, position),
      ],
    ));
    // Scaffold(
    //   drawer: C_Drawer(),
    //   appBar: C_CustomAppBar(
    //       title: _selectedIndex == 0
    //           ? 'Home'
    //           : _selectedIndex == 1
    //               ? 'Map'
    //               : _selectedIndex == 2
    //                   ? 'Schedule'
    //                   : user == 'hauler'
    //                       ? 'Vehicle'
    //                       : 'Payment'),
    //   body:
    //       Loading ? const CircularProgressIndicator() : _pages[_selectedIndex],
    //   bottomNavigationBar: C_BottomNavBar(
    //     currentIndex: _selectedIndex,
    //     onTap: _onItemTapped,
    //   ),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Loading || firstLoad
  //       ? Scaffold(
  //           backgroundColor: deepPurple,
  //           body: Stack(
  //             children: [
  //               Positioned.fill(
  //                 child: InkWell(
  //                   onTap: () {},
  //                   child: Center(
  //                     child: CircularProgressIndicator(
  //                       color: Colors.green,
  //                       strokeWidth: 10,
  //                       strokeAlign: 2,
  //                       backgroundColor: Colors.deepPurple,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //       : Scaffold(
  //           drawer: C_Drawer(),
  //           appBar: C_CustomAppBar(
  //               title: _selectedIndex == 0
  //                   ? 'Home'
  //                   : _selectedIndex == 1
  //                       ? 'Map'
  //                       : _selectedIndex == 2
  //                           ? 'Schedule'
  //                           : user == 'hauler'
  //                               ? 'Vehicle'
  //                               : 'Payment'),
  //           body: Loading
  //               ? const CircularProgressIndicator()
  //               : _pages[_selectedIndex],
  //           bottomNavigationBar: C_BottomNavBar(
  //             currentIndex: _selectedIndex,
  //             onTap: _onItemTapped,
  //           ),
  //         );
  // }
}
