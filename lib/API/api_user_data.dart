import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trashtrack/API/api_network.dart';
import 'package:trashtrack/API/api_token.dart';
import 'package:flutter/material.dart';

import 'package:trashtrack/styles.dart';

String baseUrl = globalUrl();

Future<Map<String, dynamic>?> fetchCusData() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/fetch_user_data'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await fetchCusData();
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //error user not found
      //showErrorSnackBar(context, '${response.body} in fetching data');
      console('${response.body} in fetching data');
      return null;
    }
  } catch (e) {
    print(e.toString());
    return null;
  }
}

//fetch profile pic
Future<String?> fetchProfile(BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_profile'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    // Extract the profile image from the JSON response
    final responseData = jsonDecode(response.body);
    return responseData['profileImage']; // Returns the base64 image string
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchProfile(context);
      } else {
        // Refresh token is invalid or expired, logout the user
        await deleteTokens(); // Logout user
        return null;
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      await deleteTokens(); // Logout use
    } else {
      print('Response: ${response.body}');
    }

    showErrorSnackBar(context, response.body);
    return null;
  }
}

//notification
Future<List<Map<String, dynamic>>?> fetchCusNotifications() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/customer/fetch_notifications'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchCusNotifications();
      } else {
        // Refresh token is invalid or expired, logout the user
        await deleteTokens(); // Logout user
        return null;
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      await deleteTokens(); // Logout user
    } else if (response.statusCode == 404) {
      print('No notification found');
      return null;
    }

    //showErrorSnackBar(context, response.body);
    print('Response: ${response.body}');
    return null;
  }
}
