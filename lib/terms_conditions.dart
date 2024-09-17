// import 'package:flutter/material.dart';

// class TermsAndConditions extends StatelessWidget {
//   const TermsAndConditions({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Terms and Conditions'),
//       ),
//       body: Container(),
//     );
//   }
// }



////////////////////////////////////////////////////////
import 'package:flutter/material.dart';

class TermsAndConditions extends StatefulWidget {
  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fade Transition Example'),
      ),
      body: Center(
        child: Column(
          children: [
            // First Row (Flex: 1)
            Expanded(
              flex: 1,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    color: _colorTween.value,
                    child: Center(
                      child: Text(
                        'Row 1 (Flex: 1)',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/material.dart';

// class TermsAndConditions extends StatefulWidget {
//   @override
//   _TermsAndConditionsState createState() => _TermsAndConditionsState();
// }

// class _TermsAndConditionsState extends State<TermsAndConditions> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize the animation controller
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this, // This is the ticker provider
//     )..repeat(reverse: true); // Makes the animation repeat
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Request Pickup Screen'),
//       ),
//       body: Center(
//         child: FadeTransition(
//           opacity: _controller,
//           child: Container(
//             width: 200,
//             height: 200,
//             color: Colors.blue,
//             child: Center(
//               child: Text(
//                 'Fading Box',
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

