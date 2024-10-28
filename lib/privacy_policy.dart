// import 'package:flutter/material.dart';

// class PrivacyPolicy extends StatelessWidget {
//   const PrivacyPolicy({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Privacy Policy'),
//       ),
//       body: Container(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize the ConfettiController
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    _confettiController.stop();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confetti Example'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti widget positioned in the center of the screen
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            blastDirection: 3.14 / 2, // right
            particleDrag: 0.05, // apply drag to the particles
            emissionFrequency: 0.05, // frequency of particles
            numberOfParticles: 100, // number of particles to emit
            colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple], // Customize colors
            gravity: 0.1, // gravity affects the falling speed of particles
            shouldLoop: false,
          ),
          Center(
            child: ElevatedButton(
              onPressed: _onButtonPressed,
              child: Text('Celebrate!'),
            ),
          ),
        ],
      ),
    );
  }

  // Optional: Function to create star-shaped confetti
  Path drawStar(Size size) {
    // Adjust to customize star shape
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(width * 0.5, 0);
    path.lineTo(width * 0.67, height * 0.5);
    path.lineTo(width, height * 0.5);
    path.lineTo(width * 0.75, height * 0.75);
    path.lineTo(width * 0.85, height);
    path.lineTo(width * 0.5, height * 0.9);
    path.lineTo(width * 0.15, height);
    path.lineTo(width * 0.25, height * 0.75);
    path.lineTo(0, height * 0.5);
    path.lineTo(width * 0.33, height * 0.5);
    path.close();
    return path;
  }
}
