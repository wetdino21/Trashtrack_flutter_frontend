// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:trashtrack/api_network.dart';
// import 'package:trashtrack/api_token.dart';
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';

// String baseUrl = globalUrl();

// class PaymentScreen extends StatefulWidget {
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _loading = false;

//   // Function to create payment intent and get checkout URL
//   Future<void> _launchPaymentLink() async {
//     setState(() {
//       _loading = true;
//     });

//     final tokens = await getTokens();
//     String? accessToken = tokens['access_token'];
//     if (accessToken == null) {
//       print('No access token available. User needs to log in.');
//       await deleteTokens(context); // Logout user
//       return;
//     }

//     try {
//       // Corrected API call to backend to create payment intent
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment_link'), // Update this to the correct endpoint
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'amount': 10000, // 100.00 PHP (amount in centavos)
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Log the entire response to debug
//         print('Response data: $data');

//         // Check if the checkoutUrl is present and not null
//         final checkoutUrl = data['checkoutUrl'];
//         if (checkoutUrl != null) {
//           // Open the checkout URL
//           await _launchPaymentUrl(checkoutUrl);
//         } else {
//           throw Exception('No checkout URL in the response');
//         }
//       } else {
//         throw Exception('Failed to create payment intent');
//       }
//     } catch (error) {
//       print('Error: $error');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Error creating payment link'),
//       ));
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _launchPaymentUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//   if (!await launchUrl(uri)) {
//     throw Exception('Could not launch $uri');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pay with PayMongo'),
//       ),
//       body: Center(
//         child: _loading
//             ? CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed: _launchPaymentLink,
//                 child: Text('Pay 100.00 PHP'),
//               ),

//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

String baseUrl = globalUrl();

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  // Function to create payment intent and get checkout URL
  Future<void> _launchPaymentLink() async {
    setState(() {
      _loading = true;
    });

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
        Uri.parse(
            '$baseUrl/payment_link'), // Update this to the correct endpoint
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
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  Future<void> _checkPaymentStatus(String paymentIntentId) async {
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

  Future<void> _launchPaymentUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay with PayMongo'),
      ),
      body: Column(
        children: [
          Center(
            child: _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _launchPaymentLink,
                    child: Text('Pay 100.00 PHP'),
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              _checkPaymentStatus('pay_5skzgHWeEYqwFptqnKvWqGZE');
            },
            child: Text('Check'),
          ),
        ],
      ),
    );
  }
}
