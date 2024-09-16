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
      String? fullname = user.displayName;
      String fname = fullname != null ? fullname.split(' ').first : '';
      String lname = fullname != null ? fullname.split(' ').last : '';
      String email = user.email;
      String? photoUrl = user.photoUrl;

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
          lname: lname,
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
    await _handleSignOut();
    return null;
  }
  await _handleSignOut();
  return null;
}

// void onPressedSignUp(BuildContext context) async {
//   GoogleAccountDetails? accountDetails = await handleGoogleSignUp(context);

//   if (accountDetails != null) {
//     // If the sign-up was successful, navigate to the next page
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NextPage(accountDetails: accountDetails),
//       ),
//     );
//   } else {
//     // Stay on the page if there's an error
//     print('Error occurred during sign-up, staying on the same page');
//   }
// }

// // Method to handle Google Sign-In
// Future<void> handleGoogleSignUp(BuildContext context) async {
//   try {
//     GoogleSignInAccount? user = await _googleSignIn.signIn();

//     if (user != null) {
//       final GoogleSignInAuthentication auth = await user.authentication;
//       // Access token and other details
//       final String? accessToken = auth.accessToken;
//       final String? idToken = auth.idToken;

//       print('Signed in: ${user.displayName}');
//       print('Email: ${user.email}');
//       print('Photo URL: ${user.photoUrl}');

//       print('Access Token: $accessToken');
//       print('ID Token: $idToken');
//       // Extract user info
//       String? fullname = user.displayName;
//       String fname = fullname != null ? fullname.split(' ').first : '';
//       String lname = fullname != null ? fullname.split(' ').last : '';
//       String email = user.email;
//       String? photoUrl = user.photoUrl;

//       // Fetch Google profile photo
//       Uint8List? photoBytes;
//       if (photoUrl != null) {
//         http.Response response = await http.get(Uri.parse(photoUrl));
//         if (response.statusCode == 200) {
//           photoBytes = response.bodyBytes;
//         }
//       }

//       // Check if email already exists in the database
//       String? dbMessage = await emailCheck(email);
//       if (dbMessage != null) {
//         showErrorSnackBar(context, dbMessage); // Show error if email exists
//       } else {
//         // If email doesn't exist, create a new Google account
//        await createGoogleAccount(context, fname, lname, email, photoBytes);
//          // If successful, return GoogleAccountDetails
//       }
//     } else {
//       print('Sign-in canceled');
//     }

//     // Sign out from Google after creating the account or checking the email
//     await _handleSignOut();
//   } catch (error) {
//     print('Sign-in failed: $error');
//     showErrorSnackBar(context, 'Sign-in failed: $error');
//   }
// }

// Sign-out from Google
Future<void> _handleSignOut() async {
  await _googleSignIn.signOut();
  print('Signed out');
}

Future<void> createGoogleAccount(BuildContext context,  String email, Uint8List? photoBytes, String fname, String mname,
    String lname, String contact, String province, String city, String brgy, String street, String postal,) async {
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  SuccessfulGoogleRegistration(),
      ),
    );
    // showSuccessSnackBar(context, 'Successfully Created Account');

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => C_HomeScreen(),
    //   ),
    // );
  } else {
    showSuccessSnackBar(context, response.body);
    print('Failed to create account');
  }
}

//for global call
Future<void> handleSignOut() async {
  await _googleSignIn.signOut();
  print('Signed out');
}

// Future<void> createGoogleAccount(BuildContext context, String fname,
//     String lname, String email, Uint8List? photoBytes) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/signup_google'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'fname': fname,
//       'lname': lname,
//       'email': email,
//       'photo': photoBytes != null ? base64Encode(photoBytes) : null,
//     }),
//   );

//   if (response.statusCode == 201) {
//     //store token to storage
//     final responseData = jsonDecode(response.body);
//     final String accessToken = responseData['accessToken'];
//     final String refreshToken = responseData['refreshToken'];
//     storeTokens(accessToken, refreshToken);

//     showSuccessSnackBar(context, 'Successfully Created Account');

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => C_HomeScreen(),
//       ),
//     );
//   } else {
//     print('Failed to create account');
//   }
// }

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
