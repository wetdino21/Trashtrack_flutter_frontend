import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/Customer/c_drawer.dart';
import 'package:trashtrack/Customer/c_waste_info.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/styles.dart';

import 'package:trashtrack/user_date.dart';
import 'package:flutter_cube/flutter_cube.dart';


class C_HomeScreen extends StatefulWidget {
  @override
  State<C_HomeScreen> createState() => _C_HomeScreenState();
}

class _C_HomeScreenState extends State<C_HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //user data
  Map<String, dynamic>? userData;
  //Box<dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  //Uint8List? imageBytes;
  late Object _obj;

  @override
  void initState() {
    super.initState();
     _obj = Object(
      scale: Vector3(12.0, 12.0, 12.0),
      //position: Vector3(0, 0, 0),
      rotation: Vector3(0, -90, 0), // Start sideways
      fileName: 'assets/objects/base.obj',
    );
    _dbData();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      //final data = await Hive.openBox('mybox');
      final data = await userDataFromHive();
      // final data = await fetchCusData(context);
      setState(() {
        userData = data;
        isLoading = false;

        // // Decode base64 image only if it exists
        // if (userData?['profileImage'] != null) {
        //   imageBytes = base64Decode(userData!['profileImage']);
        // }
      });
      //await data.close();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

//////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_scaffoldKey.currentState!.isDrawerOpen) {
          _scaffoldKey.currentState!.closeDrawer();
        } else {
          if (didPop) {
            return;
          }
          showLogoutConfirmationDialog(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: deepGreen,
        appBar: C_CustomAppBar(
          title: 'Home',
        ),
        drawer: C_Drawer(currentIndex: 0,),
        body: RefreshIndicator(
          onRefresh: _dbData,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : userData != null
                  ? ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            // ElevatedButton(
                            //     onPressed: () async {
                            //       bool onLocation =
                            //           await checkLocationPermission();
                            //       if (onLocation)
                            //         Navigator.push(
                            //             context,
                            //             MaterialPageRoute(
                            //                 builder: (context) => C_MapScreen(
                            //                     pickupPoint: LatLng(10.25702151,
                            //                         123.85040322))));
                            //     },
                            //     child: Text('Go To Map')),
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
                                    //'Welcome ${userData!['cus_fname']}!',
                                    'Welcome ${userData!['fname']}!',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Ready to keep things tidy? Schedule your garbage pickup today!',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.arrow_left,
                                            color: deepPurple,
                                          ),
                                          Container(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Cube(
                                              onSceneCreated: (Scene scene) {
                                                // scene.world.add(Object(
                                                //     scale: Vector3(
                                                //         12.0, 12.0, 12.0),
                                                //     position: Vector3(0, 0, 0),
                                                //     rotation:
                                                //         Vector3(0, -90, 0),
                                                //     fileName:
                                                //         'assets/objects/base.obj'));
                                                 scene.world.add(_obj);
                                              },
                                            ),
                                          ),
                                          Icon(Icons.arrow_right,
                                              color: deepPurple),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: shadowColor
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RequestPickupScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 30.0),
                                        ),
                                        child: Text(
                                          'Request Pickup Now',
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

                            ////
                            SizedBox(height: 20.0),
                            Text(
                              '  Waste Collection Info',
                              style: TextStyle(
                                color: white,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 5.0),

                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => C_WasteInfo()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    boxShadow: shadowBigColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    leading: Icon(
                                      Icons.view_list,
                                      color: deepPurple,
                                    ),
                                    title: Text(
                                      'Type of Waste',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                )),

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
                                  icon: Icons.schedule,
                                  title: 'Total Requests',
                                  value: '150',
                                  iconColor: accentColor,
                                ),
                                StatisticBox(
                                  icon: Icons.delete_outline,
                                  title: 'Total Tons Collected',
                                  value: '75',
                                  iconColor: accentColor,
                                ),
                              ],
                            ),

                            SizedBox(height: 20.0),
                          ],
                        ),
                      ],
                    )
                  ///// if error
                  : Center(child: Text('Error: $errorMessage')),
        ),
        bottomNavigationBar: C_BottomNavBar(
          currentIndex: 0,
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
        boxShadow: shadowBigColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: deepPurple,
            size: 30.0,
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
