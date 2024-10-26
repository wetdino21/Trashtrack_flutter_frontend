import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class C_AboutUs extends StatefulWidget {
  const C_AboutUs({super.key});

  @override
  State<C_AboutUs> createState() => _C_AboutUsState();
}

class _C_AboutUsState extends State<C_AboutUs> {
  double _height = 0.3;
  double _position = 0;
  final int textCount = 200; // Total number of text widgets
  final double textHeight = 32.0; // Estimated height per text widget including padding
  int showSecsAnimation = 20;
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 100));

    if (!mounted) return;
    setState(() {
      _height = (textHeight * textCount) / MediaQuery.of(context).size.height;
    });

    await Future.delayed(Duration(seconds: showSecsAnimation + 1));

    if (!mounted) return;
    setState(() {
      _position = MediaQuery.of(context).size.width; // Move it off-screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
      ),
      body: SafeArea(
        child: Container(
          color: deepGreen,
          child: Stack(
            children: [
              Container(color: deepGreen),
              ListView(
                shrinkWrap: true,
                children: [
                  AnimatedContainer(
                    duration: Duration(seconds: showSecsAnimation),
                    curve: Curves.easeInOut,
                    height: MediaQuery.of(context).size.height * _height,
                    color: Colors.deepPurple,
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
                                top: 200,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      textCount,
                                      (index) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          'Sample Text ${index + 1}',
                                          style: TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: Duration(seconds: 1),
                                left: _position,
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:trashtrack/styles.dart';

// class C_AboutUs extends StatefulWidget {
//   const C_AboutUs({super.key});

//   @override
//   State<C_AboutUs> createState() => _C_AboutUsState();
// }

// class _C_AboutUsState extends State<C_AboutUs> {
//   double _height = 0.3; 
//   double _position = 0; 

//   @override
//   void initState() {
//     super.initState();
//     _startAnimation();
//   }

//   void _startAnimation() async {
//     // First, wait for a moment
//     await Future.delayed(Duration(milliseconds: 100));

//     // Animate height change
//     if (!mounted) return;
//     setState(() {
//       _height = 0.8; // Expand height to 80%
//     });

//     // Wait for height animation to complete
//     await Future.delayed(Duration(seconds: 1));

//     // Now move the image to the right
//     if (!mounted) return;
//     setState(() {
//       _position = MediaQuery.of(context).size.width; // Move it off-screen
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: deepPurple,
//       body: SafeArea(
//         child: Container(
//           color: deepGreen,
//           child: Stack(
//             children: [
//               Container(
//                 color: deepGreen, // Background color
//               ),
//               ListView(
//                 shrinkWrap: true,
//                 children: [
//                   AnimatedContainer(
//                     duration: Duration(seconds: 1),
//                     curve: Curves.easeInOut,
//                     height: MediaQuery.of(context).size.height * _height,
//                     color: Colors.deepPurple, // Purple color
//                     alignment: Alignment.topCenter,
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: Stack(
//                             alignment: Alignment.bottomCenter,
//                             children: [
//                               Positioned(
//                                 top: 50,
//                                 left: 5,
//                                 child: Image.asset(
//                                   'assets/image/cloud2.png',
//                                   height: MediaQuery.of(context).size.height * 0.15,
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 170,
//                                 right: 20,
//                                 child: Image.asset(
//                                   'assets/image/cloud1.png',
//                                   height: MediaQuery.of(context).size.height * 0.15,
//                                 ),
//                               ),
//                               AnimatedPositioned(
//                                 duration: Duration(seconds: 1),
//                                 left: _position, // Position for the image
//                                 bottom: 0,
//                                 child: Column(
//                                   children: [
//                                     Image.asset(
//                                       'assets/icon/trashtrack_car.png',
//                                       scale: 3,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           color: deepGreen,
//                           child: Column(
//                             children: [
//                               Container(height: 5, color: greySoft),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     'assets/image/window_blinder.png',
//                                     height: MediaQuery.of(context).size.height * 0.15,
//                                   )
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 500),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
