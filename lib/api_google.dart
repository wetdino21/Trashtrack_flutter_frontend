import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/create_acc.dart';
import 'package:trashtrack/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trashtrack/user_date.dart';

// final String baseUrl = 'http://192.168.254.187:3000';
String baseUrl = globalUrl();

// Google Sign-In instance
final GoogleSignIn _googleSignIn = GoogleSignIn();

//store the fetch google data
class GoogleAccountDetails {
  final String fname;
  final String lname;
  final String email;
  final Uint8List? photoBytes;

  GoogleAccountDetails({
    required this.fname,
    required this.lname,
    required this.email,
    this.photoBytes,
  });
}

Future<GoogleAccountDetails?> handleGoogleSignUp(BuildContext context) async {
  try {
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user != null) {
      // final GoogleSignInAuthentication auth = await user.authentication;
      // final String? accessToken = auth.accessToken;
      // final String? idToken = auth.idToken;

      // Extract user info
      String fullname = user.displayName == null ? '' : user.displayName!;
      // String fname = fullname != null ? fullname.split(' ').first : '';
      // String lname = fullname != null ? fullname.split(' ').last : '';
      String email = user.email;
      String? photoUrl = user.photoUrl;

      List<String> nameParts = fullname.trim().split(RegExp(r'\s+'));

      String? fname;
      String? lname;

      // Handle based on the number of words
      switch (nameParts.length) {
        case 1:
          // If only one word, it's the first name, last name is null
          fname = nameParts[0];
          lname = null;
          break;
        case 2:
          // If two words, first word is first name, second word is last name
          fname = nameParts[0];
          lname = nameParts[1];
          break;
        case 3:
          // If three words, first two words are first name, last word is last name
          fname = '${nameParts[0]} ${nameParts[1]}';
          lname = nameParts[2];
          break;
        case 4:
          // If four words, first two words are first name, last two are last name
          fname = '${nameParts[0]} ${nameParts[1]}';
          lname = '${nameParts[2]} ${nameParts[3]}';
          break;
        default:
          // If five or more words, first three are first name, the rest are last name
          fname = '${nameParts[0]} ${nameParts[1]} ${nameParts[2]}';
          lname = nameParts.sublist(3).join(' ');
      }

      //// Fetch Google profile photo
      // Uint8List? photoBytes;
      // if (photoUrl != null) {
      //   http.Response response = await http.get(Uri.parse(photoUrl));
      //   if (response.statusCode == 200) {
      //     photoBytes = response.bodyBytes;
      //   }
      // }
      Uint8List? photoBytes;
      if (photoUrl != null) {
        try {
          http.Response response = await http.get(Uri.parse(photoUrl));
          if (response.statusCode == 200) {
            photoBytes = response.bodyBytes; // Fetch the image as bytes
          } else {
            print("Failed to load Google profile image");
          }
        } catch (e) {
          print("Error fetching Google profile image: $e");
        }
      }

      // Check if email already exists in the database
      String? dbMessage = await emailCheck(email);
      if (dbMessage != null) {
        showErrorSnackBar(context, dbMessage); // Show error if email exists
        await _handleSignOut();
        return null;
      } else {
        // If email doesn't exist, create a new Google account
        //await createGoogleAccount(context, fname, lname, email, photoBytes);

        // If successful, return GoogleAccountDetails
        return GoogleAccountDetails(
          fname: fname,
          lname: lname == null ? '' : lname,
          email: email,
          photoBytes: photoBytes,
        );
      }
    } else {
      await _handleSignOut();
      print('Sign-in canceled');
    }

    // Sign out from Google after creating the account or checking the email
    await _handleSignOut();
  } catch (error) {
    print('Sign-in failed: $error');
    showErrorSnackBar(context, 'Sign-in failed: $error');
     _handleSignOut();
    return null;
  }
  await _handleSignOut();
  return null;
}

// Sign-out from Google
Future<void> _handleSignOut() async {
  await _googleSignIn.signOut();
  print('Google Signed out');
}

Future<void> createGoogleAccount(
  BuildContext context,
  String email,
  Uint8List? photoBytes,
  String fname,
  String mname,
  String lname,
  String contact,
  String province,
  String city,
  String brgy,
  String street,
  String postal,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/signup_google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'photo': photoBytes != null ? base64Encode(photoBytes) : null,
      'fname': fname,
      'mname': mname,
      'lname': lname,
      'contact': contact,
      'province': province,
      'city': city,
      'brgy': brgy,
      'street': street,
      'postal': postal,
    }),
  );

  if (response.statusCode == 201) {
    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    await storeDataInHive(context); // store data to local

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessfulGoogleRegistration(),
      ),
    );
  } else {
    showSuccessSnackBar(context, response.body);
    print('Failed to create account');
  }
}

//for global call
Future<void> handleSignOut() async {
  await _googleSignIn.signOut();
  print('Google Signed out');
}

//////handle GOOGLE login
Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user != null) {
      // print('Signed in: ${user.displayName}');
      // print('Email: ${user.email}');
      // print('Photo URL: ${user.photoUrl}');

      String email = user.email;

      String? dbMessage = await loginWithGoogle(context, email);
      if (dbMessage == 'customer') {
        Navigator.pushReplacementNamed(context, 'c_home');
      } else if (dbMessage == 'hauler') {
        Navigator.pushReplacementNamed(context, 'home');
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
    _handleSignOut();
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

  if (response.statusCode == 200 || response.statusCode == 201) {
    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    await storeDataInHive(context); // store data to local

    if (response.statusCode == 200) {
      print('Login successfully');
      return 'customer'; // No error
    }
    // else if (response.statusCode == 201) {
    //   print('Login successfully');
    //   return 'hauler'; // No error
    // }
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
