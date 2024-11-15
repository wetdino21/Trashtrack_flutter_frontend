import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trashtrack/API/api_network.dart';

// final String Url = 'http://192.168.254.187:3000';
String BaseUrl = globalUrl();
// String? BaseUrl = globalUrl().getBaseUrl();

Future<void> sendEmailSignUp(String to, String subject, String code) async {
  final baseUrl = Uri.parse('$BaseUrl/send_email');

  try {
    final response = await http.post(
      baseUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'to': to,
        'subject': subject,
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Email sent successfully: ${responseData['messageId']}');
    } else {
      print('Failed to send email: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
//////////////////

// send email code Create Acc
Future<String?> sendEmailCodeCreateAcc(String email) async {
  final baseUrl = Uri.parse('$BaseUrl/send_code_createacc');

  final response = await http.post(
    baseUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email to create');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('Email is already taken!');

    return 'Email is already taken!'; // Return the error message from the server
  } else if (response.statusCode == 429) {
    print('Too many requests. Please try again later.');

    // Parse the JSON response body
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    // Get the timeremain value
    final int timeremain = responseBody['timeremain'] ?? 0;

    // Convert timeremain from milliseconds to seconds (or minutes, if needed)
    final int secondsRemaining = (timeremain / 1000).ceil();

    // Show the remaining time in the message
    return 'Too many requests try again later for $secondsRemaining seconds.';
  } else {
    //print('Error response: ${response.body}');
    print('Failed to send verification code');
    return 'error';
  }
}

// send email code Create Acc
Future<String?> sendCodeEmailUpdate(String email) async {
  final baseUrl = Uri.parse('$BaseUrl/send_code_email_update');

  final response = await http.post(
    baseUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email to create');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('Email is already taken!');

    return 'Email is already taken!'; 
  } else if (response.statusCode == 429) {
    print('Too many requests. Please try again later.');

    // Parse the JSON response body
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    // Get the timeremain value
    final int timeremain = responseBody['timeremain'] ?? 0;

    // Convert timeremain from milliseconds to seconds (or minutes, if needed)
    final int secondsRemaining = (timeremain / 1000).ceil();

    return 'Too many requests try again later for $secondsRemaining seconds.';
  } else {
    print('Failed to send verification code');
    return 'error';
  }
}

// send email code ForgotPass
Future<String?> sendEmailCodeTrashtrackBind(String email) async {
  final baseUrl = Uri.parse('$BaseUrl/send_code_trashrack_bind');

  final response = await http.post(
    baseUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('No associated account with this email.');

    return 'No associated account with this email.'; // Return the error message from the server
  } else if (response.statusCode == 429) {
    print('Too many requests. Please try again later.');

    // Parse the JSON response body
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    // Get the timeremain value
    final int timeremain = responseBody['timeremain'] ?? 0;

    // Convert timeremain from milliseconds to seconds (or minutes, if needed)
    final int secondsRemaining = (timeremain / 1000).ceil();

    // Show the remaining time in the message
    return 'Too many requests try again later for $secondsRemaining seconds.';
    //return 'Too many requests try again later for 1 minute.'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to send verification code');
    return 'error';
  }
}

// send email code ForgotPass
Future<String?> sendEmailCodeForgotPass(String email) async {
  final baseUrl = Uri.parse('$BaseUrl/send_code_forgotpass');

  try {
    final response = await http.post(
      baseUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      print('Good Email');
      return null; // No error, return null
    } else if (response.statusCode == 400) {
      print('No associated account with this email.');

      return 'No associated account with this email.'; // Return the error message from the server
    } else if (response.statusCode == 429) {
      print('Too many requests. Please try again later.');

      // Parse the JSON response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Get the timeremain value
      final int timeremain = responseBody['timeremain'] ?? 0;

      // Convert timeremain from milliseconds to seconds (or minutes, if needed)
      final int secondsRemaining = (timeremain / 1000).ceil();

      // Show the remaining time in the message
      return 'Too many requests try again later for $secondsRemaining seconds.';
      //return 'Too many requests try again later for 1 minute.'; // Return the error message from the server
    } else {
      //print('Error response: ${response.body}');
      print('Failed to send verification code');
      return 'error';
    }
  } catch (e) {
    print('Failed to send verification code');
    return 'No Internet Connection';
  }
}

// verify code ForgotPass
Future<String?> verifyEmailCode(String email, String inputCode) async {
  final baseUrl = Uri.parse('$BaseUrl/verify_code');

  final response = await http.post(
    baseUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'userInputCode': inputCode,
    }),
  );

  if (response.statusCode == 200) {
    print('Successful Email Verification ');
    return null; // No error, return null
  } else if (response.statusCode == 404) {
    print('No verification record found!');

    return 'No associated account with this email!';
  } else if (response.statusCode == 400) {
    print('Verification code has expired!');

    return 'Verification code has expired!';
  } else if (response.statusCode == 401) {
    print('Incorrect verification code!');

    return 'Incorrect verification code!';
  } else if (response.statusCode == 429) {
    print('Too many failed attempts. Please request a new code.');
    return 'Too many failed attempts. Please request a new code.';
  } else {
    //print('Error response: ${response.body}');
    print('Failed to verify code');
    return 'Failed to verify code';
  }
}
