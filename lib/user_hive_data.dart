import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/api_cus_data.dart'; // For imageBytes if applicable
import 'dart:convert';
import 'package:trashtrack/styles.dart';

// import 'package:logger/logger.dart';
// final Logger logger = Logger();

Future<void> storeDataInHive() async {
  try {
    // Fetch data from the API or another source
    final data = await fetchCusData();

    if (data == null) {
      console('FETCH USER DATA IS NULL');
    } else {
// Determine the prefix based on the data
      String prefix;
      bool verified = false;
      String usertype = 'type';
      String address = '';
      if (data.containsKey('cus_id')) {
        prefix = 'cus_';
        verified = data['cus_isverified'];
      } else if (data.containsKey('emp_id')) {
        prefix = 'emp_';
        usertype = 'role';
        address = data['emp_address'];
        //print(data['emp_role']);
      } else {
        // Handle cases where neither cus_id nor haul_id is found
        throw Exception('Invalid data format');
      }

      // Extract data fields with the appropriate prefix
      final String? user = data['user'];

      final int? id = data['${prefix}id'];
      final String? fname = data['${prefix}fname'];
      final String? mname = data['${prefix}mname'];
      final String? lname = data['${prefix}lname'];
      final String? contact = data['${prefix}contact'];
      final String? province = prefix == 'cus_' ? data['${prefix}province'] : '';
      final String? city = prefix == 'cus_' ? data['${prefix}city'] : '';
      final String? brgy = prefix == 'cus_' ? data['${prefix}brgy'] : '';
      final String? street = prefix == 'cus_' ? data['${prefix}street'] : '';
      final String? postal = prefix == 'cus_' ? data['${prefix}postal'] : '';

      final String? type = data['${prefix}${usertype}']; //type /role
      final String? status = data['${prefix}status'];
//////////////
      final String? email = data['${prefix}email'];
      final String? auth = data['${prefix}auth_method'];
      final Uint8List? imageBytes = data['profileImage'] != null ? base64Decode(data['profileImage']) : null;

      // Open Hive box
      var box = await Hive.openBox('mybox');

      // Store data in Hive
      await box.put('user', user);
      await box.put('id', id);
      await box.put('fname', fname);
      await box.put('mname', mname);
      await box.put('lname', lname);
      await box.put('contact', contact);
      await box.put('province', province);
      await box.put('city', city);
      await box.put('brgy', brgy);
      await box.put('street', street);
      await box.put('postal', postal);
      await box.put('email', email);
      await box.put('status', status);
      await box.put('type', type);
      await box.put('auth', auth);
      await box.put('profile', imageBytes);
      await box.put('address', address);
      await box.put('verified', verified);

      if (user == 'customer') {
        //notification count
        List<Map<String, dynamic>>? notifications;
        int unreadCount = 0;
        try {
          final notifData = await fetchCusNotifications();
          if (notifData != null) {
            notifications = notifData;
            // Count unread notifications
            unreadCount = notifications.where((notification) {
              return notification['notif_read'] == false;
            }).length;
          } else {
            console('NOTIFICATION USER DATA IS NULL');
          }
        } catch (e) {
          console(e.toString());
        }

        await box.put('notif_count', unreadCount);

        //print('Data has been saved to Hive.');
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

// //notification count
// Future<void> notificationCount() async{
//    //notification count
//     List<Map<String, dynamic>>? notifications;
//     int unreadCount = 0;

//      try {
//       final notifData = await fetchCusNotifications();
//       if (notifData != null) {
//         notifications = notifData;
//         // Count unread notifications
//         unreadCount = notifications.where((notification) {
//           return notification['notif_read'] == false;
//         }).length;
//       } else {
//         print('NOTIFICATION USER DATA IS NULL');
//       }
//     } catch (e) {
//       //showErrorSnackBar(context, e.toString());
//     }

//     // Open Hive box
//     var box = await Hive.openBox('countNotif');
//     await box.put('notif_count', unreadCount);
// }

/////////////////////////
Future<Map<String, dynamic>> userDataFromHive() async {
  // Open Hive box
  var box = await Hive.openBox('mybox');

  // Retrieve data from Hive
  final Map<String, dynamic> data = {
    'user': box.get('user'),
    'id': box.get('id'),
    'fname': box.get('fname'),
    'mname': box.get('mname'),
    'lname': box.get('lname'),
    'contact': box.get('contact'),
    'province': box.get('province'),
    'city': box.get('city'),
    'brgy': box.get('brgy'),
    'street': box.get('street'),
    'postal': box.get('postal'),
    'email': box.get('email'),
    'status': box.get('status'),
    'type': box.get('type'),
    'auth': box.get('auth'),
    'profile': box.get('profile'),
    'address': box.get('address'),
    'verified': box.get('verified'),
    'notif_count': box.get('notif_count'),
  };
  // Optionally, print a message or handle UI updates
  //print('Data has been retrieved from Hive.');

  //await box.close();
  return data;
}







// import 'dart:typed_data';

// class UserCache {
//   // Singleton instance
//   static final UserCache _instance = UserCache._internal();
  
//   // Data fields to cache
//   String? id;
//   String? fname;
//   String? mname;
//   String? lname;
//   String? contact;
//   String? province;
//   String? city;
//   String? brgy;
//   String? street;
//   String? postal;
//   String? email;
//   String? type;
//   String? auth;
//   Uint8List? imageBytes;

//   // Factory constructor for singleton pattern
//   factory UserCache() {
//     return _instance;
//   }

//   // Internal constructor
//   UserCache._internal();

//   // Method to clear all cached data (used when logging out)
//   void clearCache() {
//     id = null;
//     fname = null;
//     mname = null;
//     lname = null;
//     contact = null;
//     province = null;
//     city = null;
//     brgy = null;
//     street = null;
//     postal = null;
//     email = null;
//     type = null;
//     auth = null;
//     imageBytes = null;
//   }
// }


// //store cache
// void storeUserData(String id, String fname, String mname, String lname, String contact, String province, String city, String brgy, String street, String postal, String email, String type, String auth, Uint8List imageBytes) {
//   var cache = UserCache();
//   cache.id = id;
//   cache.fname = fname;
//   cache.mname = mname;
//   cache.lname = lname;
//   cache.contact = contact;
//   cache.province = province;
//   cache.city = city;
//   cache.brgy = brgy;
//   cache.street = street;
//   cache.postal = postal;
//   cache.email = email;
//   cache.type = type;
//   cache.auth = auth;
//   cache.imageBytes = imageBytes;
  
// }

// //view 
// void viewUserDetails() {
//   var cache = UserCache();
//   String? userId = cache.id;
//   String? userFname = cache.fname;
//   // Access other data as needed
// }

// ////log out
// //UserCache().clearCache();