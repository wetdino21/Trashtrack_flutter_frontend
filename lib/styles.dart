import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void console(message) {
  if (kDebugMode) {
    print(message);
  }
}

final Logger logger = Logger();
//final Color backgroundColor = Color(0xFF001E00);
// final Color accentColor = Color(0xFF6AA920);
const Color buttonColor = Color(0xFF86BF3E);
const Color boxColor = Color(0xFF103510);
const Color accentColor = Colors.greenAccent;
const Color iconBoxColor = Color(0xFF001E03);
Color green = Colors.green;
Color deepGreen = Color(0xFF388E3C);
Color deepPurple = Colors.deepPurple;
Color deepPurpleAccent = Colors.deepPurpleAccent;
Color? pupleSoft = Colors.deepPurple[200];
Color darkPurple = Color(0xFF3A0F63);
Color? greytitleColor = Colors.grey[700];
Color whiteSoft = Colors.white70;
Color whiteLow = const Color.fromARGB(255, 238, 236, 236);
Color white = Colors.white;
Color black = Colors.black;
Color blackSoft = Colors.grey[600]!;
Color grey = Colors.grey[600]!;
Color greySoft = Colors.grey[400]!;
Color blueSoft = const Color.fromARGB(255, 152, 222, 255);
Color blue = Colors.blue;
Color deepBlue = Colors.blue[900]!;
Color orange = Colors.deepOrange;
Color yellowSoft = Color(0xFFFFD700);
Color greenSoft = Colors.greenAccent;
Color red = Colors.red;
Color redSoft = Colors.redAccent;
Color darkRed = Color(0xFFB00020);

List<BoxShadow> shadowColor = [
  BoxShadow(
    color: Colors.grey.withOpacity(0.7),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(3, 3), //Offset(-5, -5) right  and bottom
  ),
];

List<BoxShadow> shadowIconColor = [
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    spreadRadius: 2,
    blurRadius: 2,
    offset: Offset(2, 2), //Offset(-5, -5) right  and bottom
  ),
];

List<BoxShadow> shadowLessColor = [
  BoxShadow(
    color: Colors.black.withOpacity(0.7),
    spreadRadius: 2,
    //blurRadius: 5,
    offset: Offset(2, 2), //Offset(-5, -5) right  and bottom
  ),
];

List<BoxShadow> shadowTextColor = [
  BoxShadow(
    color: Colors.black.withOpacity(0.5),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0.7, 0.7), //Offset(-5, -5) right  and bottom
  ),
];

List<BoxShadow> shadowBigColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.5), spreadRadius: 5,
    blurRadius: 2,
    offset: Offset(5, 5), // Position of the shadow
  ),
];
//
List<BoxShadow> shadowMidColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.5),
    spreadRadius: 2,
    blurRadius: 2,
    offset: Offset(5, 5), // Only right (5px) and bottom (5px) shadow
  ),
];

List<BoxShadow> shadowLowColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.5),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(5, 5), // Only right (5px) and bottom (5px) shadow
  ),
];

List<BoxShadow> shadowTopColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.5),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(5, -5), // Only right (5px) and bottom (5px) shadow
  ),
];

// List<BoxShadow> shadowTextColor = [
//   BoxShadow(
//     color: Colors.black.withOpacity(0.3),
//     spreadRadius: 1,
//     blurRadius: 10,
//     offset: Offset(5, 5), //Offset(-5, -5) right  and bottom
//   ),
// ];

BorderRadius borderRadius5 = BorderRadius.circular(5);
BorderRadius borderRadius10 = BorderRadius.circular(10);
BorderRadius borderRadius15 = BorderRadius.circular(10);
BorderRadius borderRadius50 = BorderRadius.circular(10);
BoxDecoration boxDecoration1 = BoxDecoration(boxShadow: shadowColor, borderRadius: borderRadius10, color: white);
BoxDecoration boxDecorationBig = BoxDecoration(boxShadow: shadowBigColor, borderRadius: borderRadius50, color: white);
//snackbar
void showErrorSnackBar(BuildContext context, String errorMessage) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        showCloseIcon: true,
      ),
    );
  }
}

Widget showLoadingAction() {
  return Positioned.fill(
    child: InkWell(
      onTap: () {},
      child: Container(
        color: black.withOpacity(0.3),
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
  );
}

void showSuccessSnackBar(BuildContext context, String successMessage) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        showCloseIcon: true,
      ),
    );
  }
}

// class CustomOverlay extends StatelessWidget {
//   final String message;
//   final Color backgroundColor;

//   CustomOverlay({required this.message, this.backgroundColor = Colors.red});

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: kToolbarHeight, // Position below the AppBar
//       left: 0,
//       right: 0,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: EdgeInsets.all(16.0),
//           color: backgroundColor,
//           child: Text(
//             message,
//             style: TextStyle(color: Colors.white),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }

// void showCustomSnackBar(BuildContext context, String message) {
//   final overlay = Overlay.of(context);
//   final overlayEntry = OverlayEntry(
//     builder: (context) => CustomOverlay(message: message),
//   );

//   // Insert the overlay entry
//   overlay.insert(overlayEntry);

//   // Remove the overlay after a delay
//   Future.delayed(Duration(seconds: 2), () {
//     overlayEntry.remove();
//   });
// }

// for loading
Widget loadingAnimation(
    AnimationController _controller, Animation<Color?> _colorTween, Animation<Color?> _colorTween2) {
  return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 30,
                  width: 300,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.white.withOpacity(.6),
                    color: index % 2 == 0 ? _colorTween.value : _colorTween2.value,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 70,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index % 2 == 0 ? _colorTween.value : _colorTween2.value,
                  ),
                ),
              ],
            );
          },
        );
      });
}

// for loading
Widget loadingBookingAnimation(
    AnimationController _controller, Animation<Color?> _colorTween, Animation<Color?> _colorTween2) {
  return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween.value,
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            //color: Colors.white.withOpacity(.6),
                            color: _colorTween2.value,
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 10,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      width: 100,
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        //color: Colors.white.withOpacity(.6),
                                        color: _colorTween2.value,
                                      ),
                                      child: Text(''))),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      width: 250,
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        //color: Colors.white.withOpacity(.6),
                                        color: _colorTween2.value,
                                      ),
                                      child: Text(''))),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      width: 150,
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        //color: Colors.white.withOpacity(.6),
                                        color: _colorTween2.value,
                                      ),
                                      child: Text(''))),
                            ],
                          ))),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 30,
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween2.value,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _colorTween2.value,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 30,
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween.value,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _colorTween.value,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 30,
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween2.value,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _colorTween2.value,
              ),
            ),
          ],
        );
      });
}

// for loading
Widget loadingSingleAnimation(
    AnimationController _controller, Animation<Color?> _colorTween, Animation<Color?> _colorTween2) {
  return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 40,
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween.value,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _colorTween2.value,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween.value,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.white.withOpacity(.6),
                color: _colorTween2.value,
              ),
            ),
          ],
        );
      });
}

Widget loadingHomeAnimation(
    AnimationController _controller, Animation<Color?> _colorTween, Animation<Color?> _colorTween2) {
  return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                height: 350,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _colorTween2.value,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 40,
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //color: Colors.white.withOpacity(.6),
                  color: _colorTween.value,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.white.withOpacity(.6),
                          color: _colorTween.value,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.white.withOpacity(.6),
                          color: _colorTween.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

//animate
Widget showLoadingMovingTruck(BuildContext context, double height, double position) {
  return Scaffold(
    backgroundColor: deepPurple,
    body: SafeArea(
      child: Container(
        color: deepGreen,
        child: Stack(
          children: [
            Container(
              color: deepGreen, // Background color
            ),
            ListView(
              shrinkWrap: true,
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  height: MediaQuery.of(context).size.height * height,
                  color: Colors.deepPurple, // Purple color
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              top: 50,
                              left: 5,
                              child: Image.asset(
                                'assets/image/cloud2.png',
                                height: MediaQuery.of(context).size.height * 0.15,
                              ),
                            ),
                            Positioned(
                              top: 170,
                              right: 20,
                              child: Image.asset(
                                'assets/image/cloud1.png',
                                height: MediaQuery.of(context).size.height * 0.15,
                              ),
                            ),
                            Positioned(
                                top: MediaQuery.of(context).size.height * 0.4,
                                child: Text(
                                  'LOADING...',
                                  style: TextStyle(color: whiteSoft, fontWeight: FontWeight.bold, fontSize: 30),
                                )),
                            AnimatedPositioned(
                              duration: Duration(seconds: 1),
                              left: position, // Position for the image
                              bottom: 0,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icon/trashtrack_car.png',
                                    scale: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: deepGreen,
                        child: Column(
                          children: [
                            Container(height: 5, color: greySoft),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/image/window_blinder.png',
                                  height: MediaQuery.of(context).size.height * 0.15,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 500),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget showLoadingIconAnimate() {
  return Scaffold(
    backgroundColor: deepPurple,
    body: Stack(
      children: [
        Positioned.fill(
          child: InkWell(
            onTap: () {},
            child: Center(
              child: Stack(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(child: Image.asset('assets/icon/trashtrack_icon.png', scale: 10)),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 10,
                      strokeAlign: 5,
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
