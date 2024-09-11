import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

final storage = FlutterSecureStorage();

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
  return {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}

// Retrieve tokens from secure storage
Future<Map<String, String?>> getAccesToken() async {
  String? accessToken = await storage.read(key: 'access_token');
  return {
    'access_token': accessToken
  };
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
Future<void> deleteTokens() async {
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');
}

// Function to make API call (with token verification)
Future<void> makeApiRequest() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    return;
  }

  final response = await http.get(
    Uri.parse('http://your-server-url.com/api/protected'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('API Response: ${jsonDecode(response.body)}');
  } else if (response.statusCode == 403 || response.statusCode == 401) {
    // Access token might be expired, attempt to refresh it
    print('Access token expired. Attempting to refresh...');
    await refreshAccessToken();
  } else {
    print('Error: ${response.statusCode}');
  }
}

// Function to refresh the access token
Future<void> refreshAccessToken() async {
  Map<String, String?> tokens = await getTokens();
  String? refreshToken = tokens['refresh_token'];

  if (refreshToken == null) {
    print('No refresh token available. User needs to log in.');
    await deleteTokens(); // Logout user
    return;
  }

  final response = await http.post(
    Uri.parse('http://your-server-url.com/api/token/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refreshToken': refreshToken}),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    String newAccessToken = responseData['accessToken'];

    // Store the new access token
    await storage.write(key: 'access_token', value: newAccessToken);
    print('Access token refreshed successfully');
  } else {
    print('Refresh token expired or invalid. Logging out...');
    await deleteTokens(); // Logout user if refresh token is invalid
  }
}
