import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:trashtrack/API/api_network.dart';
import 'package:trashtrack/API/api_token.dart';
import 'package:trashtrack/styles.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

String baseUrl = globalUrl();

Future<void> _launchPaymentUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    console('Could not launch $uri');
  }
}

// link session
Future<String?> launchPaymentLinkSession(int gbId, int bkId) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout user
    return null;
  }

  try {
    // API call to backend to create payment intent
    final response = await http.post(
      Uri.parse('$baseUrl/payment_link_Session'), // Backend endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'gb_id': gbId, 'bk_id': bkId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final checkoutUrl = data['checkoutUrl'];
      final sessionId = data['sessionId'];

      if (data != null) {
        if (checkoutUrl != null) {
          // Open the checkout URL
          await _launchPaymentUrl(checkoutUrl);
          //fetch
          return sessionId;
        } else {
          console('No checkout URL in the response');
        }
      } else {
        console('No checkout URL in the response');
      }
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await launchPaymentLinkSession(gbId, bkId);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        //showErrorSnackBar(context, 'Active time has been expired. Please login again.');
        await deleteTokens(); // Logout user
      } else {
        print('Error updating user: ${response.body}');
        // showErrorSnackBar(context, 'Error updating user: ${response.body}');
      }
    }
    print('Unable to access the link!');
    return null;
  } catch (error) {
    print('Error: $error');
    return null;
  }
}

// //////////////////////////
// Future<String?> checkPaymentStatus(String sessionId) async {
//   final tokens = await getTokens();
//   String? accessToken = tokens['access_token'];
//   if (accessToken == null) {
//     print('No access token available. User needs to log in.');
//     await deleteTokens(); // Logout user
//     return null;
//   }
//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/payment_status/$sessionId'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final paymentStatus = data['status'];

//       if (paymentStatus == 'paid') {
//         return 'success';
//       } else {
//         return 'failed';
//       }
//     } else {
//       if (response.statusCode == 401) {
//         // Access token might be expired, attempt to refresh it
//         print('Access token expired. Attempting to refresh...');
//         String? refreshMsg = await refreshAccessToken();
//         if (refreshMsg == null) {
//           return await checkPaymentStatus(sessionId);
//         }
//       } else if (response.statusCode == 403) {
//         // Access token is invalid. Logout
//         print('Access token invalid. Attempting to logout...');
//         await deleteTokens(); // Logout user
//       } else {
//         print('Error updating user: ${response.body}');
//       }
//     }
//   } catch (error) {
//     print('Error checking payment status: $error');
//     //showErrorSnackBar(context, 'Error checking payment status');
//   }
//   return null;
// }
