import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/ZPractice.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/booking_pending_list.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';

import 'package:trashtrack/user_hive_data.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:async';

class C_HomeScreen extends StatefulWidget {
  @override
  State<C_HomeScreen> createState() => _C_HomeScreenState();
}

class _C_HomeScreenState extends State<C_HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  String? user;
  int totalRequest = 0;
  int totalPickup = 0;
  String totalCusWasteCollected = '0';
  String totalHaulWasteCollected = '0';

  //user data
  Map<String, dynamic>? userData;
  bool isLoading = false;
  bool loadingAction = false;
  String? errorMessage;
  Object? _obj;
  //bool _isObjectLoaded = false;
  Completer<void>? _sceneCreationCompleter;
  // Object _obj = Object(
  //   scale: Vector3(11.0, 11.0, 11.0),
  //   //position: Vector3(0, 0, 0),
  //   rotation: Vector3(0, -90, 0),
  //   fileName: 'assets/objects/base.obj',
  // );

  UserModel? userModel;
  Offset position = Offset(50, 150); // Initial position
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  @override
  void initState() {
    super.initState();
    _dbData();

    //_objLoad();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _sceneCreationCompleter?.complete();
    TickerCanceled;
    _controller.dispose();
    super.dispose();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final data = await userDataFromHive();
      final dbtotalRequest = await fetchTotalCusPickupRequest();
      final dbtotalPickup = await fetchTotalHaulerPickup();
      final dbCusWasteCollected = await fetchTotalCusWasteCollected();
      final dbHaulWasteCollected = await fetchTotalHaulWasteCollected();
      if (!mounted) return;
      setState(() {
        userData = data;
        user = data['user'];
      });

      if (dbtotalRequest != null) {
        totalRequest = dbtotalRequest;
      }
      if (dbtotalPickup != null) {
        totalPickup = dbtotalPickup;
      }
      if (dbCusWasteCollected != null) {
        totalCusWasteCollected = NumberFormat('#,##0.00').format(dbCusWasteCollected);
        //totalCusWasteCollected = dbCusWasteCollected;
      }
      if (dbHaulWasteCollected != null) {
        totalHaulWasteCollected = NumberFormat('#,##0.00').format(dbHaulWasteCollected);
        //totalHaulWasteCollected = dbHaulWasteCollected;
      }
      if (!mounted) return;

      _obj = Object(
        scale: Vector3(11.0, 11.0, 11.0),
        //position: Vector3(0, 0, 0),
        rotation: Vector3(0, -90, 0),
        fileName: 'assets/objects/base.obj',
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      console(e.toString());
    }
  }

//////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        showLogoutConfirmationDialog(context);
      },
      child: Scaffold(
        backgroundColor: deepGreen,
        body: RefreshIndicator(
          onRefresh: _dbData,
          child: Stack(
            children: [
              isLoading
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: loadingHomeAnimation(_controller, _colorTween, _colorTween2),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            // Welcome Container
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: shadowBigColor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome ${userModel!.fname}!',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      color: deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    user == 'customer'
                                        ? 'Ready to keep things tidy? Schedule your garbage pickup today!'
                                        : 'Another waste collection day? Drive safe!',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Icon(
                                              Icons.arrow_left,
                                              color: deepPurple,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                              height: 200,
                                              child:
                                                  // Cube(
                                                  //   onSceneCreated: (Scene scene) {
                                                  //     _sceneCreationCompleter = Completer<void>();

                                                  //     scene.world.add(_obj!);

                                                  //     //await Future.delayed(Duration(milliseconds: 100));

                                                  //     if (scene.world.children.contains(_obj)) {
                                                  //       if (!mounted) return;
                                                  //       setState(() {
                                                  //         _isObjectLoaded = true;
                                                  //         //load animation
                                                  //         userModel!.setIsHome(false);
                                                  //         print("Object fully loaded in the scene");
                                                  //       });
                                                  //     }
                                                  //   },
                                                  // )
                                                  ///////////////////////////////////////////
                                                  //     Cube(
                                                  //   onSceneCreated: (Scene scene) {
                                                  //     _sceneCreationCompleter = Completer<void>();

                                                  //     // Add the object to the scene
                                                  //     if (_obj != null) {
                                                  //       scene.world.add(_obj!);

                                                  //       // Use a delayed Future to wait for processing
                                                  //       Future.delayed(Duration(milliseconds: 100), () {
                                                  //         // Check if the completer has been completed
                                                  //         if (_sceneCreationCompleter?.isCompleted ?? false) return;

                                                  //         // Check if the object is still in the scene
                                                  //         if (scene.world.children.contains(_obj)) {
                                                  //           if (!mounted) return;
                                                  //           setState(() {
                                                  //             _isObjectLoaded = true; // Mark object as loaded
                                                  //             userModel!.setIsHome(false); // Example action
                                                  //             print("Object fully loaded in the scene");
                                                  //           });
                                                  //         }
                                                  //       });
                                                  //     } else {
                                                  //       print("Object is not initialized yet.");
                                                  //     }
                                                  //   },
                                                  // ),
                                                  //  ///////////////////////////////////////////
                                                  Cube(
                                                onSceneCreated: (Scene scene) {
                                                  scene.world.add(_obj!);
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Icon(Icons.arrow_right, color: deepPurple),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                                      decoration: BoxDecoration(
                                          color: deepPurple,
                                          borderRadius: BorderRadius.circular(10.0),
                                          boxShadow: shadowLowColor),
                                      child: InkWell(
                                        //
                                        onTap: () async {
                                          setState(() {
                                            loadingAction = true;
                                          });
                                          //
                                          if (user == 'customer') {
                                            String? bklimit = await checkBookingLimit(context);
                                            if (bklimit == 'max') {
                                              showBookLimitDialog(context);
                                            } else if (bklimit == 'disabled') {
                                              showErrorSnackBar(context, 'We are not accepting booking right now!');
                                            } else if (bklimit == 'no limit') {
                                              showErrorSnackBar(context, 'No booking limit found');
                                            } else if (bklimit == 'success') {
                                              String? isUnpaidBIll = await checkUnpaidBIll(context);
                                              if (isUnpaidBIll == 'Unpaid') {
                                                showUnpaidBillDialog(context);
                                              } else if (isUnpaidBIll == 'success') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => RequestPickupScreen(),
                                                  ),
                                                );
                                              }
                                            }
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Booking_List(),
                                              ),
                                            );
                                          }
                                          //
                                          setState(() {
                                            loadingAction = false;
                                          });
                                        },
                                        child: Text(
                                          user == 'customer' ? 'Request Pickup Now' : 'Go to Pickup',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /////
                            SizedBox(height: 20.0),
                            Text(
                              '  Previous waste pickup',
                              style: TextStyle(
                                color: white,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 5.0),

                            // Statistic Boxes
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              children: [
                                StatisticBox(
                                  icon: Icons.access_time_filled,
                                  title: user == 'customer' ? 'Total Requests' : 'Total Pickup',
                                  value: user == 'customer' ? totalRequest.toString() : totalPickup.toString(),
                                  iconColor: accentColor,
                                ),
                                StatisticBox(
                                  icon: Icons.delete,
                                  title: 'Total Waste Collected',
                                  value:
                                      user == 'customer' ? '$totalCusWasteCollected kg' : '$totalHaulWasteCollected kg',
                                  iconColor: accentColor,
                                ),
                              ],
                            ),

                            SizedBox(height: 20.0),
                          ],
                        ),
                      ],
                    ),
              // if (!_isObjectLoaded)
              //   Positioned.fill(
              //     child: InkWell(
              //       onTap: () {},
              //       child: Container(
              //         color: deepGreen,
              //         padding: EdgeInsets.all(20),
              //         child: loadingHomeAnimation(_controller, _colorTween, _colorTween2),
              //       ),
              //     ),
              //   ),
              if (loadingAction) showLoadingAction(),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  StatisticBox({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        boxShadow: shadowMidColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: deepPurple,
            size: 50.0,
            shadows: shadowColor,
          ),
          SizedBox(height: 10.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 5.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20.0, // Default font size; will scale down if text overflows
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

void showBookLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Text('Unable to request pickup', style: TextStyle(color: redSoft)),
        content: Text('You have reached the maximum booking limit.', style: TextStyle(color: blackSoft)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: blackSoft, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

void showUnpaidBillDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Text('Unable to request pickup', style: TextStyle(color: redSoft)),
        content: Text('You still have unpaid payment, please pay it first.', style: TextStyle(color: blackSoft)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: blackSoft, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
