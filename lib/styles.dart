import 'package:flutter/material.dart';

final Color backgroundColor = Color(0xFF001E00);
// final Color accentColor = Color(0xFF6AA920);
final Color buttonColor = Color(0xFF86BF3E);
final Color boxColor = Color(0xFF103510);
final Color accentColor = Colors.greenAccent;
final Color iconBoxColor = Color(0xFF001E03);
final List<BoxShadow> shadowColor = [
  BoxShadow(
    color: Colors.grey.withOpacity(0.5), // Adjust opacity as needed
    blurRadius: 5,
    spreadRadius: 2,
    offset: Offset(0, 3), // Position of the shadow
  ),
];

final List<BoxShadow> shadowBigColor = [
  BoxShadow(
    color: Colors.black, // Adjust opacity as needed
    blurRadius: 20,
    spreadRadius: 2,
    offset: Offset(0, 3), // Position of the shadow
  ),
];

//snackbar
void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String successMessage) {
  ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing SnackBars
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(successMessage),
      backgroundColor: Colors.green,
    ),
  );
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
