import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/booking_pending_list.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';

import 'package:trashtrack/user_hive_data.dart';
import 'package:flutter_cube/flutter_cube.dart';

class C_HomeScreen extends StatefulWidget {
  @override
  State<C_HomeScreen> createState() => _C_HomeScreenState();
}

class _C_HomeScreenState extends State<C_HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? user;

  //user data
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  final Object _obj = Object(
    scale: Vector3(11.0, 11.0, 11.0),
    //position: Vector3(0, 0, 0),
    rotation: Vector3(0, -90, 0), // Start sideways
    fileName: 'assets/objects/base.obj',
  );
  //Object? _obj;
  UserModel? userModel;
  Offset position = Offset(50, 150); // Initial position
  bool objDragged = false;
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
    TickerCanceled;
    _controller.dispose();
    super.dispose();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      // final data = await fetchCusData(context);
      if (!mounted) return null;
      setState(() {
        userData = data;
        user = data['user'];
        isLoading = false;
      });
    } catch (e) {
      // setState(() {
      //   errorMessage = e.toString();
      //   isLoading = false;
      // });
    }
  }

  // // Fetch user data from the server
  // Future<void> _objLoad() async {
  //   try {
  //     if (!mounted) return;
  //     _obj = Object(
  //       scale: Vector3(11.0, 11.0, 11.0),
  //       //position: Vector3(0, 0, 0),
  //       rotation: Vector3(0, -90, 0), // Start sideways
  //       fileName: 'assets/objects/base.obj',
  //     );
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  void _loadObject(Scene scene) {
    if (!mounted) return;

    try {
      // Attempt to load the object
      if (!mounted) return;
      scene.world.add(Object(
        scale: Vector3(11.0, 11.0, 11.0),
        rotation: Vector3(0, -90, 0), // Start sideways
        fileName: 'assets/objects/base.obj',
      ));
    } catch (e) {
      print("Error loading object: $e");
      showErrorSnackBar(context, e.toString());
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
                    userData == null
                        ? Container(
                            padding: EdgeInsets.all(20),
                            child: LoadingHomeAnimation(
                                _controller, _colorTween, _colorTween2),
                          )
                        : ListView(
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      child: !objDragged
                                                          ? Cube(
                                                              onSceneCreated:
                                                                  (Scene
                                                                      scene) {
                                                                scene.world
                                                                    .add(_obj);
                                                              },
                                                            )
                                                          : SizedBox()),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Icon(Icons.arrow_right,
                                                      color: deepPurple),
                                                ),
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
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0,
                                                    horizontal: 30.0),
                                              ),
                                              child: Text(
                                                user == 'customer'
                                                    ? 'Request Pickup Now'
                                                    : 'Go to Pickup',
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
                                        title: user == 'customer'
                                            ? 'Total Requests'
                                            : 'Total Pickup',
                                        value:
                                            userModel!.totalRequest.toString(),
                                        iconColor: accentColor,
                                      ),
                                      StatisticBox(
                                        icon: Icons.delete,
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
                          )),
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

            // // The draggable widget
            // Positioned(
            //   left: position.dx,
            //   top: position.dy,
            //   child: LongPressDraggable(
            //     feedback: Container(
            //       width: 300,
            //       height: 200,
            //       color: Colors.green.withOpacity(0.7),
            //       //child: Center(child: Text('Dragging')),
            //     ),
            //     child: Container(
            //       color: Colors.transparent,
            //       width: 300,
            //       height: 200,
            //       child: objDragged
            //           ? Cube(
            //               onSceneCreated: (Scene scene) {
            //                 _loadObject(scene);
            //               },
            //             )
            //           : Align(
            //             alignment: Alignment.topCenter,
            //             child: Text(
            //                 'Long Drag Me',
            //                 style: TextStyle(
            //                   color: deepPurple,
            //                   fontSize: 18.0,
            //                 ),
            //               ),
            //           ),
            //     ),
            //     onDragEnd: (details) {
            //       setState(() {
            //         objDragged = true;
            //         position = Offset(
            //           details.offset.dx,
            //           details.offset.dy - 100,
            //         );
            //       });
            //     },
            //   ),
            // ),
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
