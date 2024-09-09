import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';

//final String baseUrl = 'http://localhost:3000/api';
final String baseUrl = 'http://192.168.254.187:3000/api';

// Google Sign-In instance
final GoogleSignIn _googleSignIn = GoogleSignIn();

// Method to handle Google Sign-In
Future<void> handleGoogleSignUp(BuildContext context) async {
  try {
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user != null) {
      print('Signed in: ${user.displayName}');
      print('Email: ${user.email}');
      print('Photo URL: ${user.photoUrl}');

      // Extract user info
      String? fullname = user.displayName;
      String fname = fullname != null ? fullname.split(' ').first : '';
      String lname = fullname != null ? fullname.split(' ').last : '';
      String email = user.email;
      String? photoUrl = user.photoUrl;

      // Fetch Google profile photo
      Uint8List? photoBytes;
      if (photoUrl != null) {
        http.Response response = await http.get(Uri.parse(photoUrl));
        if (response.statusCode == 200) {
          photoBytes = response.bodyBytes;
        }
      }

      // Check if email already exists in the database
      String? dbMessage = await emailCheck(email);
      if (dbMessage != null) {
        showErrorSnackBar(context, dbMessage); // Show error if email exists
      } else {
        // If email doesn't exist, create a new Google account
        await createGoogleAccount(context, fname, lname, email, photoBytes);
      }
    } else {
      print('Sign-in canceled');
    }

    // Sign out from Google after creating the account or checking the email
    await _handleSignOut();
  } catch (error) {
    print('Sign-in failed: $error');
    showErrorSnackBar(context, 'Sign-in failed: $error');
  }
}

// Sign-out from Google
Future<void> _handleSignOut() async {
  await _googleSignIn.signOut();
  print('Signed out');
}

//final String baseUrl = 'http://192.168.254.187:3000/api';

//final String baseUrl = 'http://localhost:3000/api';

Future<void> createGoogleAccount(BuildContext context, String fname,
    String lname, String email, Uint8List? photoBytes) async {
  final response = await http.post(
    Uri.parse('$baseUrl/signup_google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fname': fname,
      'lname': lname,
      'email': email,
      'photo': photoBytes != null ? base64Encode(photoBytes) : null,
    }),
  );

  if (response.statusCode == 201) {
    // final responseData = json.decode(response.body);

    // final fname = responseData['fname'];
    // final cusProfile = responseData['cus_profile']; // Assuming this is a URL

    // Navigate to HomePage and pass the first name and profile image

    showSuccessSnackBar(context, 'Successfully Created Account');
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => C_HomeScreen(email: responseData['cus_email']),
    //   ),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => C_HomeScreen(),
      ),
    );
  } else {
    print('Failed to create account');
  }
}

//////handle GOOGLE login
Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user != null) {
      print('Signed in: ${user.displayName}');
      print('Email: ${user.email}');
      print('Photo URL: ${user.photoUrl}');

      String email = user.email;

      String? dbMessage = await loginWithGoogle(context, email);
      if (dbMessage == 'customer') {
        Navigator.pushNamed(context, 'c_home');
      } else if (dbMessage == 'hauler') {
        Navigator.pushNamed(context, 'home');
      } else if (dbMessage == '202') {
        Navigator.pushNamed(context, 'deactivated');
      } else if (dbMessage == '203') {
        Navigator.pushNamed(context, 'suspended');
      } else {
        showErrorSnackBar(context, dbMessage);
      }
    } else {
      print('Sign-in canceled');
    }

    // Sign out from Google after creating the account or checking the email
    await _handleSignOut();
  } catch (error) {
    print('Sign-in failed: $error');
    showErrorSnackBar(context, 'Sign-in failed: $error');
  }
}

//////LOGIN GOOGLE
Future<String> loginWithGoogle(BuildContext context, String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login_google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

 
  if (response.statusCode == 200) {
    print('Login successfully');
    return 'customer'; // No error
  } else if (response.statusCode == 201) {
    print('Login successfully');
    return 'hauler'; // No error
  } else if (response.statusCode == 202) {
    print('deactivated account');
    return response.statusCode.toString();
  } else if (response.statusCode == 203) {
    print('suspended account');
    return response.statusCode.toString();
  } else if (response.statusCode == 404) {
    return 'No account associated with this email';
  } else if (response.statusCode == 402) {
    print('Error response: ${response.body}');
    return 'Looks like this account is registered with email and password. Please log in using your email and password.';
  } else {
    print('Error response: ${response.body}');
    return response.body;
  }
}
