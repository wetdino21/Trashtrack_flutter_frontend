import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';


// final String baseUrl = 'http://192.168.254.187:3000';
String baseUrl = globalUrl();

Future<String?> createCode(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('Email is already taken');

    return 'Email is already taken'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check customer email');
    return 'error';
  }
}

Future<String?> emailCheck(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('Email is already taken');

    return 'Email is already taken'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check customer email');
    return 'error';
  }
}

Future<String?> emailCheckforgotpass(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check_forgotpass'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Existing Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('email doesn\'t exists');

    return 'No account associated with the email'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check account email');
    return 'error';
  }
}

// //FETCH USER DATA
// Future<Map<String, dynamic>?> fetchUserData(String email) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/fetch_user_data'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'email': email}),
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     print('Failed to fetch user data: ${response.body}');
//     return null;
//   }
// }

Future<String?> createCustomer(
    String fname, String lname, String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fname': fname,
      'lname': lname,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    print('Successfully created an account');

    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    
    return null; // No error, return null
  }
  // else if (response.statusCode == 400) {
  //   print('Customer with this email already exists');

  //   return 'Customer with this email already exists';  // Return the error message from the server
  // }
  else {
    //print('Error response: ${response.body}');
    print('Failed to create customer');
    return 'error';
  }
}

Future<String?> loginAccount(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    print('Login successfully');
    if (response.statusCode == 200) {
      return 'customer'; // No error
    } else if (response.statusCode == 201) {
      return 'hauler'; // No error
    }
  } else if (response.statusCode == 202) {
    print('deactivated account');
    return response.statusCode.toString();
  } else if (response.statusCode == 203) {
    print('suspended account');
    return response.statusCode.toString();
  } else if (response.statusCode == 404) {
    return 'No account associated with this email';
  } else if (response.statusCode == 401) {
    return 'Incorrect Password';
  } else if (response.statusCode == 402) {
    print('Error response: ${response.body}');
    return 'Looks like this account is signed up with google. \nPlease login with google';
  } else {
    print('Error response: ${response.body}');
    return response.body;
  }
}

Future<String?> updatepassword(String email, String newPassword) async {
  final response = await http.post(
    Uri.parse('$baseUrl/update_password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'newPassword': newPassword,
    }),
  );

  if (response.statusCode == 200) {
    print('Successfully updated password');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('New password cannot be the same as the old password');

    return 'New password cannot be the same as the old password'; // Return the error message from the server
  } else if (response.statusCode == 404) {
    print('Email not found');

    return 'Email not found'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Database error');
    return 'error';
  }
}

////////REQUESTS WITH TOKEN///////////////////////////////////////////////////////////////////////////////
Future<void> updateProfile(
    BuildContext context, String fname, String lname) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  print('$fname $lname');
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
    return;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/update_customer'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fname': fname,
      'lname': lname,
    }),
  );

  if (response.statusCode == 200) {
    print('name updated successfully');
    showSuccessSnackBar(context, 'Updated Successfully');
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken(context);
      if (refreshMsg == null) {
        await updateProfile(context, fname, lname);
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      showErrorSnackBar(context,'Active time has been expired please login again.');
      await deleteTokens(context); // Logout use
      
    } else {
      print('Response: ${response.body}');
    }

    //showErrorSnackBar(context, response.body);
  }
}
