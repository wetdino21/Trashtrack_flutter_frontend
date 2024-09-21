import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class C_MapScreen extends StatefulWidget {
  @override
  _C_MapScreenState createState() => _C_MapScreenState();
}

class _C_MapScreenState extends State<C_MapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  LatLng? startPoint;
  LatLng? destinationPoint;
  List<List<LatLng>> routes = [];

  // Function to fetch routes using OSRM API
  Future<void> fetchRoutes(LatLng start, LatLng destination) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}'
      '?alternatives=true&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List routesData = data['routes'];

      setState(() {
        routes = routesData.map<List<LatLng>>((route) {
          final List coordinates = route['geometry']['coordinates'];
          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]); // reverse longitude/latitude
          }).toList();
        }).toList();
      });
    } else {
      throw Exception('Failed to load routes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Route'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(10.3157, 123.8854), // Example: Cebu City
          zoom: 13.0,
          maxZoom: 19,
          onTap: (tapPosition, point) {
            setState(() {
              if (startPoint == null) {
                startPoint = point;
              } else if (destinationPoint == null) {
                destinationPoint = point;
              }
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            maxZoom: 19,
          ),
          if (startPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: startPoint!,
                  builder: (ctx) => Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
            ),
          if (destinationPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: destinationPoint!,
                  builder: (ctx) => Icon(Icons.location_pin, color: Colors.green, size: 40),
                ),
              ],
            ),
          // PolylineLayer for multiple routes
          if (routes.isNotEmpty)
            PolylineLayer(
              polylines: [
                for (int i = 0; i < routes.length && i < 3; i++) // Display up to 3 routes
                  Polyline(
                    points: routes[i],
                    strokeWidth: 4.0,
                    color: i == 0
                        ? Colors.blue // First route (main)
                        : i == 1
                            ? Colors.orange // Second route (alternative 1)
                            : Colors.purple, // Third route (alternative 2)
                  ),
              ],
            ),
        ],
      ),
      floatingActionButton: (startPoint != null && destinationPoint != null)
          ? FloatingActionButton(
              child: Icon(Icons.directions),
              onPressed: () {
                fetchRoutes(startPoint!, destinationPoint!);
              },
            )
          : null,
    );
  }
}


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
//         Uri.parse(
//             '$baseUrl/payment_link'), // Update this to the correct endpoint
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


//   Future<void> _checkPaymentStatus(String paymentIntentId) async {
//     final tokens = await getTokens();
//     String? accessToken = tokens['access_token'];
//     if (accessToken == null) {
//       print('No access token available. User needs to log in.');
//       await deleteTokens(context); // Logout user
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment_status/$paymentIntentId'),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final paymentStatus = data['status'];
//          print(paymentStatus);
//         if (paymentStatus == 'paid') {
//           print('Payment successful');
//         } else if (paymentStatus == 'failed') {
//           print('Payment failed');
//         }
//       } else {
//         throw Exception('Failed to fetch payment status');
//       }
//     } catch (error) {
//       print('Error: $error');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Error checking payment status'),
//       ));
//     }
//   }

//   Future<void> _launchPaymentUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       throw Exception('Could not launch $uri');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pay with PayMongo'),
//       ),
//       body: Column(
//         children: [
//           Center(
//             child: _loading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _launchPaymentLink,
//                     child: Text('Pay 100.00 PHP'),
//                   ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _checkPaymentStatus('pay_5skzgHWeEYqwFptqnKvWqGZE');
//             },
//             child: Text('Check'),
//           ),
//         ],
//       ),
//     );
//   }
// }
