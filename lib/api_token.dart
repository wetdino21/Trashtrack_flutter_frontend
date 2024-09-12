import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

final storage = FlutterSecureStorage();

final String baseUrl = 'http://192.168.254.187:3000';

// Store tokens in secure storage
Future<void> storeNewUser(String newUser) async {
  await storage.write(key: 'new_user', value: newUser);
}

// Store tokens in secure storage
Future<void> storeTokens(String accessToken, String refreshToken) async {
  await storage.write(key: 'access_token', value: accessToken);
  await storage.write(key: 'refresh_token', value: refreshToken);

  // String? accessToken1 = await storage.read(key: 'access_token');
  // String? refreshToken1 = await storage.read(key: 'refresh_token');

  // if (accessToken1 == null) {
  //   print('No access token found');
  //   return;
  // }

  // try {
  //   final decodedToken = JwtDecoder.decode(accessToken1);
  //   final email = decodedToken['email'];
  //   print('User email: $email');
  // } catch (e) {
  //   print('Error decoding token: $e');
  // }
}

// Retrieve tokens from secure storage
Future<Map<String, String?>> getTokens() async {
  String? accessToken = await storage.read(key: 'access_token');
  String? refreshToken = await storage.read(key: 'refresh_token');
   String? newUser = await storage.read(key: 'new_user');
  return {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'new_user': newUser,
  };
}

// Retrieve tokens from secure storage
Future<Map<String, String?>> getAccesToken() async {
  String? accessToken = await storage.read(key: 'access_token');
  return {'access_token': accessToken};
}

// Retrieve tokens from secure storage
Future<String?> getEmailToken() async {
  String? accessToken = await storage.read(key: 'access_token');

  if (accessToken == null) {
    print('No access token found');
    return null;
  }

  try {
    final decodedToken = JwtDecoder.decode(accessToken);
    final email = decodedToken['email'];
    print('User email: $email');
    return email;
  } catch (e) {
    print('Error decoding token: $e');
    return e.toString();
  }
}

// Looged in
Future<bool> loggedIn() async {
  String? accessToken = await storage.read(key: 'access_token');

  if (accessToken == null) {
    print('No access token found');
    return false;
  }

  try {
    final decodedToken = JwtDecoder.decode(accessToken);
    final email = decodedToken['email'];
    print('User email: $email');
    return true;
  } catch (e) {
    print('Error decoding token: $e');
    return false;
  }
}

// Delete tokens (for logout)
Future<void> deleteTokens(BuildContext context) async {
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');

   showErrorSnackBar(context,'Your active time has been expired. \nPlease login again.');
  Navigator.pushNamedAndRemoveUntil(
    context,
    'login',
    (Route<dynamic> route) => false, // Remove all previous routes
  );
}

// Function to make API call (with token verification)
Future<void> makeApiRequest(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
    return;
  }

  final response = await http.get(
    Uri.parse('$baseUrl/protected'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('API Response: ${jsonDecode(response.body)}');
  } else if (response.statusCode == 401) {
    // Access token might be expired, attempt to refresh it
    print('Access token expired. Attempting to refresh...');
    String? refreshMsg = await refreshAccessToken(context);
    if (refreshMsg == null) {
        return await makeApiRequest(context);
      } else {
        // Refresh token is invalid or expired, logout the user
        await deleteTokens(context); // Logout user
      }
  } else if (response.statusCode == 403) {
    // Access token is invalid. logout
    print('Access token invalid. Attempting to logout...');
    await deleteTokens(context); // Logout use
  } else {
    print('Error: ${response.body}');
  }
}

// Function to refresh the access token
Future<String?> refreshAccessToken(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? refreshToken = tokens['refresh_token'];

  if (refreshToken == null) {
    print('No refresh token available. User needs to log in.');
    await deleteTokens(context); // Logout use
    return 'invalid/expired token';
  }

  final response = await http.post(
    Uri.parse('$baseUrl/refresh_token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken}),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    String newAccessToken = responseData['accessToken'];

    // Store the new access token
    await storage.write(key: 'access_token', value: newAccessToken);
    print('Access token refreshed successfully');
    return null;
  } else if (response.statusCode == 403){
    print('Refresh token expired or invalid. Logging out...');
    await deleteTokens(context); // Logout user if refresh token is invalid
    return 'invalid/expired token';
  }
}

// On open App stay login?
Future<String> onOpenApp(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  String? newUser = tokens['new_user'];
  print(tokens);
    if (newUser == null || newUser.isEmpty) {
    print('New user welcome');
    await storeNewUser('true'); // new user
    return 'splash';
  }
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
    return 'login';
  }


  final response = await http.post(
    Uri.parse('$baseUrl/onOpenApp'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return 'c_home';
  } else if (response.statusCode == 201) {
    return 'home';
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken(context);
      if (refreshMsg == null) {
        return await onOpenApp(context);
      } else {
        // Refresh token is invalid or expired, logout the user
        await deleteTokens(context); // Logout user
        return 'login';
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      await deleteTokens(context); // Logout use
    } else {
      print('Response: ${response.body}');
    }

    showErrorSnackBar(context, response.body);
    return 'login';
  }
}

////update user
// Future<void> updateProfile(BuildContext context, String fname, String lname) async {
//   Map<String, String?> tokens = await getTokens();
//   String? accessToken = tokens['access_token'];

//   if (accessToken == null) {
//     print('No access token available. User needs to log in.');
//       await deleteTokens(context); // Logout use
//     return;
//   }

//   final response = await http.post(
//     Uri.parse('$baseUrl/update_profile'),
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({
//       'fname': fname,
//       'lname': lname,  // Assume base64-encoded image
//     }),
//   );

//   if (response.statusCode == 200) {
//     print('name updated successfully');
//   } else if (response.statusCode == 401) {
//     // Access token might be expired, attempt to refresh it
//     print('Access token expired. Attempting to refresh...');
//     String? refreshMsg = await refreshAccessToken(context);
//     if (refreshMsg == null) {
//       await makeApiRequest(context);
//     }
//   } else if (response.statusCode == 403) {
//     // Access token is invalid. logout
//     print('Access token invalid. Attempting to logout...');
//     await deleteTokens(context); // Logout use
//   } else {
//     print('Response: ${response.body}');
//   }
// }

