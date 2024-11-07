import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class C_AboutUs extends StatefulWidget {
  const C_AboutUs({super.key});

  @override
  State<C_AboutUs> createState() => _C_AboutUsState();
}

class _C_AboutUsState extends State<C_AboutUs> {
  final ScrollController _scrollController = ScrollController();
  double _position = 0;
  bool _isTruckAnimating = false;
  final double textHeight = 32.0; // Estimated height per text widget including padding

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isTruckAnimating && _isScrolledToEnd()) {
      _startTruckAnimation();
    }
  }

  bool _isScrolledToEnd() {
    return _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50;
  }

  void _startTruckAnimation() async {
    setState(() {
      _isTruckAnimating = true;
      _position = MediaQuery.of(context).size.width; // Move off-screen to the right
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: Text('About Us'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Who We Are'),
                      _buildSectionContent(
                          'We are a leading waste management solution, dedicated to providing efficient, reliable, and environmentally responsible waste collection services. Our mission is to make waste management easier for communities, businesses, and institutions by offering smart solutions to handle waste responsibly.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Our Vision'),
                      _buildSectionContent(
                          'Our vision is to build a cleaner, greener world by offering a sustainable and innovative waste collection system. We aim to make waste disposal simple, accessible, and environmentally friendly for everyone.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Our Mission'),
                      _buildSectionContent(
                          '• To provide top-notch waste collection services that improve the quality of life.\n'
                          '• To ensure the safe, efficient, and timely collection and disposal of all types of waste.\n'
                          '• To support local communities in managing waste responsibly, minimizing landfill usage, and promoting recycling.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('What We Do'),
                      _buildSectionContent('We offer comprehensive waste collection services to:\n\n'
                          '• Residential Areas: Safe and timely waste collection for homes, ensuring a clean and healthy environment.\n'
                          '• Commercial Businesses: Waste management solutions for businesses of all sizes, helping you comply with environmental regulations.\n'
                          '• Special Services: Tailored waste collection for specific needs, such as electronic waste, hazardous waste, and large item collection.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('How It Works'),
                      _buildSectionContent('Our app-based platform makes it easy for you to:\n\n'
                          '• Book Waste Collection: Choose a time and date for waste pickup based on your schedule.\n'
                          '• Track Your Pickup: Monitor the status of your waste collection and receive notifications.\n'
                          '• Simple Payment: Convenient and secure payment options for all types of waste collection services.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Sustainability Focus'),
                      _buildSectionContent('We are committed to reducing our environmental footprint by:\n\n'
                          '• Recycling Initiatives: Ensuring that recyclables are separated and processed responsibly.\n'
                          '• Green Technology: Using eco-friendly vehicles and advanced systems to minimize emissions and energy consumption.\n'
                          '• Public Awareness: Educating users on best practices for waste segregation, recycling, and disposal.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Why Choose Us'),
                      _buildSectionContent(
                          '• Reliability: On-time, professional, and friendly waste collection services.\n'
                          '• Convenience: Easy-to-use mobile app for booking and managing your waste pickups.\n'
                          '• Environmental Impact: Committed to sustainability through recycling and green technologies.\n'
                          '• Affordable: Competitive pricing with transparent and no-hidden-fee policies.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Join Us in Our Mission'),
                      _buildSectionContent(
                          'At Trashtrack, we believe that waste management is not just about collection — it\'s about responsibility. '
                          'Together, we can create a cleaner, healthier environment for our communities. Get in touch with us today to schedule your waste collection or to learn more about our services.'),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 2),
              left: _position,
              bottom: 0,
              child: Image.asset(
                'assets/icon/trashtrack_car.png',
                scale: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: greenSoft, // You can choose another color
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: white,
          height: 1.6,
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
