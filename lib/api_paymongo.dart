import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/styles.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
// import 'package:app_links/app_links.dart';

String baseUrl = globalUrl();
//String? baseUrl = globalUrl().getBaseUrl();

Future<void> _launchPaymentUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

// Future<void> _launchPaymentUrl(String url) async {
//   final Uri uri = Uri.parse(url);
//   if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $uri');
//   }
// }

// Function to create payment intent and get checkout URL
Future<void> launchPaymentLink(BuildContext context) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout user
    return;
  }

  try {
    // Corrected API call to backend to create payment intent
    final response = await http.post(
      Uri.parse('$baseUrl/payment_link'), // Update this to the correct endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': 10000, // 100.00 PHP (amount in centavos)
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Log the entire response to debug
      print('Response data: $data');

      // Check if the checkoutUrl is present and not null
      final checkoutUrl = data['checkoutUrl'];
      if (checkoutUrl != null) {
        // Open the checkout URL
        //await _launchPaymentUrl(checkoutUrl);
      } else {
        throw Exception('No checkout URL in the response');
      }
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await launchPaymentLink(context);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired. Please login again.');
        await deleteTokens(); // Logout user
      } else {
        print('Error updating user: ${response.body}');
        showErrorSnackBar(context, 'Error updating user: ${response.body}');
      }
    }
    print('Unable to access the link!');
    return;
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error creating payment link'),
    ));
  }
}

//final
Future<String?> launchPaymentLinkSession(int? gb_id) async {
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
      body: jsonEncode({
        'amount': 12345, // 100.00 PHP (amount in centavos)
        'gb_id': gb_id
      }),
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
          throw Exception('No checkout URL in the response');
        }
      } else {
        throw Exception('No checkout URL in the response');
      }
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await launchPaymentLinkSession(gb_id);
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
  // finally {
  //   setState(() {
  //     _loading = false;
  //   });
  // }
}
//////////////////////////

Future<String?> checkPaymentStatus(String sessionId) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout user
    return null;
  }
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/payment_status/$sessionId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentStatus = data['status'];

      if (paymentStatus == 'paid') {
        return 'success';
      } else {
        return 'failed';
      }
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await checkPaymentStatus(sessionId);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else {
        print('Error updating user: ${response.body}');
      }
    }
  } catch (error) {
    print('Error checking payment status: $error');
    //showErrorSnackBar(context, 'Error checking payment status');
  }
  return null;
}

// Future<void> launchPaymentLinkSession(BuildContext context) async {
//   final tokens = await getTokens();
//   String? accessToken = tokens['access_token'];
//   if (accessToken == null) {
//     print('No access token available. User needs to log in.');
//     await deleteTokens(); // Logout user
//     return;
//   }

//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/payment_link_Session'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'amount': 10000, // 100.00 PHP (amount in centavos)
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final checkoutUrl = data['checkoutUrl'];
//       final sessionId = data['sessionId'];

//       if (data != null) {
//         await _launchPaymentUrl(checkoutUrl, sessionId);

//         // Poll for payment status
//         //await checkPaymentStatus(sessionId);
//       } else {
//         throw Exception('No checkout URL in the response');
//       }
//     } else {
//       if (response.statusCode == 401) {
//         print('Access token expired. Attempting to refresh...');
//         String? refreshMsg = await refreshAccessToken();
//         if (refreshMsg == null) {
//           return await launchPaymentLinkSession(context);
//         }
//       } else if (response.statusCode == 403) {
//         print('Access token invalid. Attempting to logout...');
//         showErrorSnackBar(
//             context, 'Active time has been expired. Please login again.');
//         await deleteTokens(); // Logout user
//       } else {
//         print('Error updating user: ${response.body}');
//         showErrorSnackBar(context, 'Error updating user: ${response.body}');
//       }
//     }
//   } catch (error) {
//     print('Error: $error');
//     showErrorSnackBar(context, 'Error payment link');
//   }
// }

/////
// Future<void> checkPaymentStatus(
//     BuildContext context, String paymentIntentId) async {
//   final tokens = await getTokens();
//   String? accessToken = tokens['access_token'];
//   if (accessToken == null) {
//     print('No access token available. User needs to log in.');
//     await deleteTokens(); // Logout user
//     return;
//   }

//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/payment_link_status/$paymentIntentId'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final paymentStatus = data['status'];
//       print(paymentStatus);
//       if (paymentStatus == 'paid') {
//         print('Payment successful');
//       } else if (paymentStatus == 'failed') {
//         print('Payment failed');
//       }
//     } else {
//       throw Exception('Failed to fetch payment status');
//     }
//   } catch (error) {
//     print('Error: $error');
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Error checking payment status'),
//     ));
//   }
// }

//
// Initialize App Links for deep linking
// Future<void> initAppLinks(BuildContext context) async {
//   final appLinks = AppLinks();

//   try {
//     // Get the initial app link
//     final initialLink = await appLinks.getInitialLink();
//     _handleIncomingLink(context, initialLink);

//     // Listen for incoming app links
//     appLinks.uriLinkStream.listen((Uri? link) {
//       _handleIncomingLink(context, link);
//     });
//   } catch (e) {
//     print('Failed to get initial link: $e');
//   }
// }

// // Handle incoming links
// void _handleIncomingLink(BuildContext context, Uri? link) {
//   if (link != null) {
//     // Convert the Uri to a string for comparison
//     String linkString = link.toString();

//     if (linkString.contains('/success')){
//       print('successss');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment successful!')),
//       );
//     } else if (linkString.contains('/cancel')) {
//        print('failllll');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment cancelled.')),
//       );
//     }
//   }
// }
