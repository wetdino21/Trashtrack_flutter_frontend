import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trashtrack/api_token.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Preload images to avoid white flicker
  //   precacheImage(AssetImage('assets/splash1.jpg'), context);
  //   precacheImage(AssetImage('assets/splash2.jpg'), context);
  //   precacheImage(AssetImage('assets/splash3.jpg'), context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Swipeable image area with dots indicator
          PageView(
            controller: _controller,
            children: [
              Image.asset('assets/splash1.jpg', fit: BoxFit.cover),
              Image.asset('assets/splash2.jpg', fit: BoxFit.cover),
              Image.asset('assets/splash3.jpg', fit: BoxFit.cover),
            ],
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    //stops: [0.1, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Center content
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                      "TrashTrack",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                SizedBox(height: 20),

                Text(
                      "Welcome to our TrashTrack! \n We've got your waste needs covered, \n from residential to commercial, big or small.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                SizedBox(height: 40),

                // Dots Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    dotHeight: 18,
                    dotWidth: 18,
                    activeDotColor: Colors.green,
                    paintStyle: PaintingStyle.fill,
                    dotColor: Colors.white,
                    spacing: 20,
                  ),
                ),
                SizedBox(height: 40),

                // Next button
                ElevatedButton(
                  onPressed: () {
                    storeNewUser('false');
                    Navigator.pushNamed(context, 'login');
                  },
                  child: Text("Get Started",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
