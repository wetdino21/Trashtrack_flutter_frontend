import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
// import 'package:app_links/app_links.dart';


String baseUrl = globalUrl();

Future<void> _launchPaymentUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

// Function to create payment intent and get checkout URL
Future<void> launchPaymentLink(BuildContext context) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout user
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
        await _launchPaymentUrl(checkoutUrl);
      } else {
        throw Exception('No checkout URL in the response');
      }
    } else {
      throw Exception('Failed to create payment intent');
    }
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error creating payment link'),
    ));
  }
}

Future<void> launchPaymentLink2(BuildContext context) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout user
    return;
  }

 try {
      // API call to backend to create payment intent
      final response = await http.post(
        Uri.parse('$baseUrl/payment_link2'), // Backend endpoint
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
       
        // Get the checkoutUrl from the response
        final checkoutUrl = data['checkoutUrl'];
         print(checkoutUrl);
        if (checkoutUrl != null) {
          // Open the checkout URL
          await _launchPaymentUrl(checkoutUrl);
        } else {
          throw Exception('No checkout URL in the response');
        }
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error creating payment link'),
      ));
    } 
    // finally {
    //   setState(() {
    //     _loading = false;
    //   });
    // }
}

/////
Future<void> checkPaymentStatus(
    BuildContext context, String paymentIntentId) async {
  final tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout user
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/payment_status/$paymentIntentId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentStatus = data['status'];
      print(paymentStatus);
      if (paymentStatus == 'paid') {
        print('Payment successful');
      } else if (paymentStatus == 'failed') {
        print('Payment failed');
      }
    } else {
      throw Exception('Failed to fetch payment status');
    }
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error checking payment status'),
    ));
  }
}


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




