import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_waste_info.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/booking_list.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';

import 'package:trashtrack/user_hive_data.dart';
import 'package:flutter_cube/flutter_cube.dart';

class C_HomeScreen extends StatefulWidget {
  @override
  State<C_HomeScreen> createState() => _C_HomeScreenState();
}

class _C_HomeScreenState extends State<C_HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? user;

  //user data
  Map<String, dynamic>? userData;
  //Box<dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  //Uint8List? imageBytes;
  //late Object _obj;
  final Object _obj = Object(
    scale: Vector3(12.0, 12.0, 12.0),
    //position: Vector3(0, 0, 0),
    rotation: Vector3(0, -90, 0), // Start sideways
    fileName: 'assets/objects/base.obj',
  );
  UserModel? userModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if (!mounted) return null;
    // _obj = Object(
    //   scale: Vector3(12.0, 12.0, 12.0),
    //   //position: Vector3(0, 0, 0),
    //   rotation: Vector3(0, -90, 0), // Start sideways
    //   fileName: 'assets/objects/base.obj',
    // );
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  @override
  void initState() {
    super.initState();
    // _obj = Object(
    //   scale: Vector3(12.0, 12.0, 12.0),
    //   //position: Vector3(0, 0, 0),
    //   rotation: Vector3(0, -90, 0), // Start sideways
    //   fileName: 'assets/objects/base.obj',
    // );
    _dbData();
  }

  @override
  void dispose() {
    super.dispose();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      //await storeDataInHive(context);

      //final data = await Hive.openBox('mybox');
      final data = await userDataFromHive();
      // final data = await fetchCusData(context);
      if (!mounted) return null;
      setState(() {
        userData = data;
        user = data['user'];
        isLoading = false;

        // // Decode base64 image only if it exists
        // if (userData?['profileImage'] != null) {
        //   imageBytes = base64Decode(userData!['profileImage']);
        // }
      });

      // Provider.of<UserModel>(context, listen: false).setUserData(data['id'].toString(), data['fname'],
      //     data['lname'], data['email'], data['auth'], data['profile']);

      //if online provider
      // final data2 = await fetchCusData(context);
      // if (data2 != null) {
      //   Provider.of<UserModel>(context, listen: false).setUserData(
      //     data2['cus_fname'],
      //     data2['cus_lname'],
      //     data2['cus_email'],
      //     data2['profileImage'] != null
      //         ? base64Decode(data2['profileImage'])
      //         : null,
      //   );
      // } else {
      //   showErrorSnackBar(context, 'errorMessage');
      // }

      //await data.close();
    } catch (e) {
      // setState(() {
      //   errorMessage = e.toString();
      //   isLoading = false;
      // });
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Refresh the app bar when dependencies change
  //   appbarKey.currentState?.loadProfileImage();
  // }

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
        // appBar: C_CustomAppBar(
        //   title: 'Home',
        // ),
        // drawer: C_Drawer(
        //   currentIndex: 0,
        // ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _dbData,
              child:
                  // isLoading
                  //     ? Center(child: CircularProgressIndicator())
                  //     :
                  userData != null
                      ? ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          children: [
                            // InkWell(
                            //   child: Text('data'),
                            //   onTap: (){
                            //   setState(() {
                            //     deepGreen = Colors.grey;
                            //     deepPurple = Colors.grey;
                            //     darkPurple = Colors.grey;
                            //   });
                            // }),

                            // Stack(
                            //   children: [
                            //     Container(
                            //       color: white,
                            //       height: 200,
                            //       width: 200,
                            //     ),
                            //     Positioned(
                            //       top: 0,
                            //       bottom: 0,
                            //       child: Image.asset('assets/pin.png'))
                            //   ]
                            // ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: shadowBigColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        //'Welcome ${userData!['cus_fname']}!',
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
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
                                                  onSceneCreated:
                                                      (Scene scene) {
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
                                              boxShadow: shadowColor),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (user == 'customer') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RequestPickupScreen(),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Booking_List(),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: deepPurple,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0,
                                                  horizontal: 30.0),
                                            ),
                                            child: Text(
                                              user == 'customer'
                                                  ? 'Request Pickup Now'
                                                  : 'Pickup',
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
                                // SizedBox(height: 20.0),
                                // Text(
                                //   '  Waste Collection Info',
                                //   style: TextStyle(
                                //     color: white,
                                //     fontSize: 18.0,
                                //   ),
                                // ),
                                // SizedBox(height: 5.0),

                                // GestureDetector(
                                //     onTap: () {
                                //       Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (context) =>
                                //                   C_WasteInfo()));
                                //     },
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         color: white,
                                //         boxShadow: shadowMidColor,
                                //         borderRadius: BorderRadius.circular(10),
                                //       ),
                                //       child: ListTile(
                                //         contentPadding: EdgeInsets.all(10),
                                //         leading: Icon(
                                //           Icons.view_list,
                                //           color: deepPurple,
                                //         ),
                                //         title: Text(
                                //           'Type of Waste',
                                //           style: TextStyle(
                                //             fontSize: 18.0,
                                //           ),
                                //         ),
                                //       ),
                                //     )),

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
                                      title: user == 'customer'? 'Total Requests': 'Total Pickup',
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
                      : Positioned.fill(
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
            ),
            // if (isLoading)
            //   Positioned.fill(
            //     child: InkWell(
            //       onTap: () {},
            //       child: Center(
            //         child: CircularProgressIndicator(
            //           color: Colors.green,
            //           strokeWidth: 10,
            //           strokeAlign: 2,
            //           backgroundColor: Colors.deepPurple,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
        // bottomNavigationBar: C_BottomNavBar(
        //   currentIndex: 0,
        // ),
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
        borderRadius: BorderRadius.circular(10.0),
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
