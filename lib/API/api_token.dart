import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/API/api_network.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/main.dart';
import 'package:trashtrack/styles.dart';
import 'package:hive/hive.dart';

final storage = FlutterSecureStorage();

// final String baseUrl = 'http://192.168.254.187:3000';
String baseUrl = globalUrl();
//String? baseUrl = globalUrl().getBaseUrl();

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
Future<void> deleteTokens({String? action}) async {
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');

  //delete hive boxe
  await Hive.deleteBoxFromDisk('mybox');

  // Clear user data from the model
  UserModel globalUserModel = UserModel();
  globalUserModel.clearModelData();
  //navigatorKey.currentState?.pushNamedAndRemoveUntil('/logout');

  //
  // void clearExpired() {
  //   isExpired = null; // Update expired state here
  // }

  action = action ?? 'exp';

  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => LoginPage(action: action),
    ),
    (Route<dynamic> route) => false,
  );

  // // no context that's why use global key
  // navigatorKey.currentState?.pushNamedAndRemoveUntil(
  //   '/logout',
  //   (Route<dynamic> route) => false,
  // );
}

// Function to make API call (with token verification)
Future<void> makeApiRequest(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
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
    String? refreshMsg = await refreshAccessToken();
    if (refreshMsg == null) {
      return await makeApiRequest(context);
    } else {
      // Refresh token is invalid or expired, logout the user
      await deleteTokens(); // Logout user
    }
  } else if (response.statusCode == 403) {
    // Access token is invalid. logout
    print('Access token invalid. Attempting to logout...');
    await deleteTokens(); // Logout use
  } else {
    print('Error: ${response.body}');
  }
}

// Function to refresh the access token
Future<String?> refreshAccessToken() async {
  Map<String, String?> tokens = await getTokens();
  String? refreshToken = tokens['refresh_token'];

  if (refreshToken == null) {
    print('No refresh token available. User needs to log in.');
    await deleteTokens(); // Logout use
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
  } else if (response.statusCode == 403) {
    // showExpiredSessionDialog();
    print('Refresh token expired or invalid. Logging out...');
    await deleteTokens(); // Logout user if refresh token is invalid
    return 'invalid/expired token';
  }
  return response.body;
}

// On open App stay login?
Future<String> onOpenApp(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  String? newUser = tokens['new_user'];
  if (newUser == null || newUser.isEmpty) {
    print('New user welcome');
    await storeNewUser('true'); // new user
    return 'splash';
  }
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(action: 'logout'); // Logout use
    return 'login';
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/onOpenApp'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return '/mainApp';

      // if (response.statusCode == 200) {
      //   return 'c_home';
      // } else if (response.statusCode == 201) {
      //   return 'home';
      // }
    } else {
      if (response.statusCode == 401) {
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await onOpenApp(context);
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          //return 'login';
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens();
      } else {
        print('Response: ${response.body}');
      }

      showErrorSnackBar(context, response.body);
      return 'err';
    }
  } catch (e) {
    print(e.toString());
    return 'err';
  }
}

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Text('Logout', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              deleteTokens(action: 'logout');
              Navigator.of(context).pop();
            },
            child: Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

void showExpiredSessionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Text('Session Expired', style: TextStyle(color: redSoft)),
        content: Text('Your time with us has come to an end. Please login again.', style: TextStyle(color: blackSoft)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: blackSoft, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
