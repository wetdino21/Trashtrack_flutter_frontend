import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart'; // For imageBytes if applicable
import 'dart:convert';
import 'dart:io';

import 'package:trashtrack/main.dart';
import 'package:trashtrack/styles.dart';

////////////////////////////////////////////////////////////////////////
//final String baseUrl = 'http://localhost:3000';

//http://192.168.119.156
globalAddressUrl() {
  return 'https://psgc.gitlab.io/api';
}

//my pc network

globalUrl() {
  return 'http://192.168.254.187:3000';
}


// ////// COMMENT THIS IF IP STATIC ///////////////////////////////////////////////////////////////////

// class globalUrl {
//   // Private constructor to prevent instantiation
//   globalUrl._privateConstructor();

//   // Static instance of the class
//   static final globalUrl _instance = globalUrl._privateConstructor();

//   // Variable to store the base URL
//   String? baseUrl;

//   // Factory constructor to return the same instance every time
//   factory globalUrl() {
//     return _instance;
//   }

//   // Method to set the base URL
//   void setBaseUrl(String ipAddress) {
//     baseUrl = 'http://$ipAddress:3000';
//   }

//   // Method to retrieve the base URL
//   String? getBaseUrl() {
//     return baseUrl;
//   }
// }


// //for storing network on open
// class StoreNetwork extends StatefulWidget {
//   @override
//   _StoreNetworkState createState() => _StoreNetworkState();
// }

// class _StoreNetworkState extends State<StoreNetwork> {
//   TextEditingController _networkController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkNetworkExist();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _networkController.dispose();
//   }

//   Future<void> _checkNetworkExist() async {
//     String? BaseUrl = globalUrl().getBaseUrl();

//     if (BaseUrl != null) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => TokenCheck()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: deepPurple,
//       body: Center(
//         child: Column(
//           children: [
//             Center(
//               child: Image.asset('assets/truck.png'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Type the PC SERVER NETWORK IP ADDRESS',
//               style: TextStyle(fontSize: 15, color: white),
//             ),
//             Container(
//               alignment: Alignment.center,
//               margin: EdgeInsets.all(20),
//               decoration: boxDecorationBig,
//               child: Column(
//                 children: [
//                   TextField(
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.all(10)
//                     ),
//                     controller: _networkController,
//                   ),
//                 ],
//               ),
//             ),
//             InkWell(
//                 onTap: () {
//                   if (_networkController.text.isNotEmpty) {
//                     // Set the IP address in the singleton
//                     globalUrl().setBaseUrl(_networkController.text);
//                     // String? baseUrl = globalUrl().getBaseUrl();
//                     // showErrorSnackBar(context, baseUrl!);
//                     // Navigate to the next screen
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => TokenCheck()));
//                   }
//                 },
//                 child: Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       borderRadius: borderRadius15,
//                       color: deepGreen,
//                     ),
//                     child: Text('Set Network',
//                         style: TextStyle(fontSize: 20, color: white)))),
//           ],
//         ), // Show a loading screen while checking the token
//       ),
//     );
//   }
// }











































// globalUrl() async {
//   var box = await Hive.openBox('networkBox');
//   if (box.isNotEmpty) {
//     if (await box.get('ipAddress') != null) {
//       String network = await box.get('ipAddress');
//       return 'http://${network}:3000';
//     }
//   } else {
//     return null;
//   }
//   return null;
//   // return 'http://192.168.254.187:3000';
// }

// //for storing network on open
// class StoreNetwork extends StatefulWidget {
//   @override
//   _StoreNetworkState createState() => _StoreNetworkState();
// }

// class _StoreNetworkState extends State<StoreNetwork> {
//   TextEditingController _networkController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkNetworkExist();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _networkController.dispose();
//   }

//   Future<void> _checkNetworkExist() async {
//     var box = await Hive.openBox('networkBox');

//     if (box.isNotEmpty) {
//       if (await box.get('ipAddress') != null) {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => TokenCheck()));
//       }
//     }
//     // else {
//     //   // Fallback to login if something goes wrong
//     //   Navigator.pushReplacementNamed(context, 'login');
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: deepPurple,
//       body: Center(
//         child: Column(
//           children: [
//             Center(
//               child: Image.asset('assets/truck.png'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Type the PC SERVER NETWORK IP ADDRESS',
//               style: TextStyle(fontSize: 15, color: white),
//             ),
//             Container(
//               alignment: Alignment.center,
//               margin: EdgeInsets.all(20),
//               decoration: boxDecorationBig,
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _networkController,
//                   ),
//                 ],
//               ),
//             ),
//             InkWell(
//                 onTap: () async {
//                   if (_networkController.text.isNotEmpty) {
//                     var box = await Hive.openBox('networkBox');
//                     await box.put('ipAddress', _networkController.text);

//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => TokenCheck()));
//                   }
//                 },
//                 child: Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       borderRadius: borderRadius15,
//                       color: deepGreen,
//                     ),
//                     child: Text('Set Network',
//                         style: TextStyle(fontSize: 20, color: white)))),
//           ],
//         ), // Show a loading screen while checking the token
//       ),
//     );
//   }
// }