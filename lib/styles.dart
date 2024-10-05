import 'package:flutter/material.dart';

//final Color backgroundColor = Color(0xFF001E00);
// final Color accentColor = Color(0xFF6AA920);
const Color buttonColor = Color(0xFF86BF3E);
const Color boxColor = Color(0xFF103510);
const Color accentColor = Colors.greenAccent;
const Color iconBoxColor = Color(0xFF001E03);
Color deepGreen = Color(0xFF388E3C);
Color deepPurple = Colors.deepPurple;
Color darkPurple = Color(0xFF3A0F63);

const Color white = Colors.white;

List<BoxShadow> shadowColor = [
  BoxShadow(
    color: Colors.grey.withOpacity(0.7),
    spreadRadius: 2, // Softness of the shadow
    blurRadius: 5, // How much the shadow spreads
    offset: Offset(3, 3), //Offset(-5, -5) right  and bottom
  ),
];

List<BoxShadow> shadowBigColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.7),
    spreadRadius: 5,
    blurRadius: 20,
    offset: Offset(5, 5), // Position of the shadow
  ),
];

List<BoxShadow> shadowMidColor = [
  BoxShadow(
    color: Colors.black.withOpacity(.7),
    spreadRadius: 5,
    blurRadius: 10,
    offset: Offset(5, 5), // Only right (5px) and bottom (5px) shadow
  ),
];

BorderRadius borderRadius5 = BorderRadius.circular(5);
BorderRadius borderRadius10 = BorderRadius.circular(10);
BorderRadius borderRadius15 = BorderRadius.circular(15);
BorderRadius borderRadius50 = BorderRadius.circular(15);
BoxDecoration boxDecoration1 = BoxDecoration(boxShadow: shadowColor, borderRadius: borderRadius10, color: white);
BoxDecoration boxDecorationBig = BoxDecoration(boxShadow: shadowBigColor, borderRadius: borderRadius50, color: white);
//snackbar
void showErrorSnackBar(BuildContext context, String errorMessage) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void showSuccessSnackBar(BuildContext context, String successMessage) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class CustomOverlay extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  CustomOverlay({required this.message, this.backgroundColor = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight, // Position below the AppBar
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: backgroundColor,
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => CustomOverlay(message: message),
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  // Remove the overlay after a delay
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
