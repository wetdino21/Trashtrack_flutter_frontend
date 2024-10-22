import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

// final String baseUrl = 'http://192.168.254.187:3000';
String baseUrl = globalUrl();
//String? baseUrl = globalUrl().getBaseUrl();

Future<String?> createCode(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('Email is already taken');

    return 'Email is already taken'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check customer email');
    return 'error';
  }
}

Future<String?> emailCheck(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/email_check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      print('Good Email');
      return null; // No error, return null
    } else if (response.statusCode == 400) {
      print('Email is already taken');

      return 'Email is already taken'; // Return the error message from the server
    } else {
      //print('Error response: ${response.body}');
      print('Failed to check customer email');
      return 'error';
    }
  } catch (e) {
    return 'Check your internet connection.';
  }
}

Future<String?> contactCheck(String contact) async {
  String contactnum = '0' + contact;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/contact_check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contact': contactnum,
      }),
    );

    if (response.statusCode == 200) {
      print('Good contact');
      return null; // No error, return null
    } else if (response.statusCode == 400) {
      print('contact number is already taken');
      return 'Contact number is already taken!';
    } else {
      print('Error response: ${response.body}');
      print('Failed to check customer contact number');
      return 'error';
    }
  } catch (e) {
    return 'Check your internet connection.';
  }
}

Future<String?> emailCheckforgotpass(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check_forgotpass'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Existing Email');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('email doesn\'t exists');

    return 'No account associated with the email'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check account email');
    return 'error';
  }
}

// //FETCH USER DATA
// Future<Map<String, dynamic>?> fetchUserData(String email) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/fetch_user_data'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'email': email}),
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     print('Failed to fetch user data: ${response.body}');
//     return null;
//   }
// }

Future<String?> createCustomer(
    BuildContext context,
    String email,
    String password,
    String fname,
    String mname,
    String lname,
    String contact,
    String? province,
    String? city,
    String? brgy,
    String street,
    String postal) async {
  final response = await http.post(
    Uri.parse('$baseUrl/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'fname': fname,
      'mname': mname,
      'lname': lname,
      'contact': contact,
      'province': province,
      'city': city,
      'brgy': brgy,
      'street': street,
      'postal': postal,
    }),
  );

  if (response.statusCode == 201) {
    print('Successfully created an account');

    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    await storeDataInHive(context); // store data to local

    return null; // No error, return null
  } else {
    //print('Error response: ${response.body}');
    print('Failed to create customer');
    return 'error';
  }
}

Future<String?> loginAccount(
    BuildContext context, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      //store token to storage
      final responseData = jsonDecode(response.body);
      final String accessToken = responseData['accessToken'];
      final String refreshToken = responseData['refreshToken'];
      storeTokens(accessToken, refreshToken);
      //await storeDataInHive(context); // store data to local

      print('Login successfully');
      return 'success'; // No error
    } else if (response.statusCode == 202) {
      // Store data in Hive
      final responseData = jsonDecode(response.body);
      var box = await Hive.openBox('mybox');
      await box.put('type', responseData['type']);
      await box.put('email', responseData['email']);

      print('deactivated account');
      return response.statusCode.toString();
    } else if (response.statusCode == 203) {
      print('suspended account');
      return response.statusCode.toString();
    } else if (response.statusCode == 404) {
      return 'No account associated with this email';
    } else if (response.statusCode == 401) {
      return 'Incorrect Password';
    } else if (response.statusCode == 402) {
      print('Error response: ${response.body}');
      return 'Looks like this account is signed up with google. \nPlease login with google';
    } else {
      print('Error response: ${response.body}');
      return response.body;
    }
  } catch (e) {
    console(e.toString());
  }
}

Future<String?> updateForgotPassword(String email, String newPassword) async {
  final response = await http.post(
    Uri.parse('$baseUrl/update_password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'newPassword': newPassword,
    }),
  );

  if (response.statusCode == 200) {
    print('Successfully updated password');
    return null; // No error, return null
  } else if (response.statusCode == 400) {
    print('New password cannot be the same as the old password');

    return 'New password cannot be the same as the old password'; // Return the error message from the server
  } else if (response.statusCode == 404) {
    print('Email not found');

    return 'Email not found'; // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Database error');
    return 'error';
  }
}

//user update
Future<String?> userUpdate(
    BuildContext context,
    int bookId,
    String fname,
    String mname,
    String lname,
    String email,
    Uint8List? photoBytes,
    String contact,
    String province,
    String city,
    String brgy,
    String street,
    String postal,
    String address) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout user
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user_update'), // Update endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fname': fname,
        'mname': mname,
        'lname': lname,
        'email': email,
        'photo': photoBytes != null ? base64Encode(photoBytes) : null,
        'contact': contact,
        'province': province,
        'city': city,
        'brgy': brgy,
        'street': street,
        'postal': postal,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      //store token to storage
      final responseData = jsonDecode(response.body);
      final String accessToken = responseData['accessToken'];
      final String refreshToken = responseData['refreshToken'];
      storeTokens(accessToken, refreshToken);
      await storeDataInHive(context); // store data to local

      showSuccessSnackBar(context, 'User updated successfully');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await userUpdate(
              context,
              bookId,
              fname,
              mname,
              lname,
              email,
              photoBytes,
              contact,
              province,
              city,
              brgy,
              street,
              postal,
              address);
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
    print('Update user is not successful!');
    return response.body;
  } catch (e) {
    print('Exception occurred: ${e.toString()}');
  }
  return null;
}

//waste category
// Function to fetch waste categories from API
Future<List<Map<String, dynamic>>?> fetchWasteCategory() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/waste_category'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // Extracting category names and prices as a list of maps
      return data
          .map<Map<String, dynamic>>((item) => {
                'name': item['wc_name'].toString(),
                'unit': item['wc_unit'],
                'price': item['wc_price']
              })
          .toList();
    } else {
      print(response.body);
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

////////REQUESTS WITH TOKEN///////////////////////////////////////////////////////////////////////////////
Future<void> updateProfile(
    BuildContext context, String fname, String lname) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  print('$fname $lname');
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
    return;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/update_customer'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fname': fname,
      'lname': lname,
    }),
  );

  if (response.statusCode == 200) {
    print('name updated successfully');
    showSuccessSnackBar(context, 'Updated Successfully');
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await updateProfile(context, fname, lname);
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      showErrorSnackBar(
          context, 'Active time has been expired please login again.');
      await deleteTokens(); // Logout use
    } else {
      print('Response: ${response.body}');
    }

    //showErrorSnackBar(context, response.body);
  }
}

//booking
Future<String?> booking(
    BuildContext context,
    String fullname,
    String contact,
    String province,
    String city,
    String brgy,
    String street,
    String postal,
    double latitude,
    double longitude,
    DateTime date,
    List<Map<String, dynamic>> selectedWasteTypes) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/booking'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullname': fullname,
        'contact': contact,
        'province': province,
        'city': city,
        'brgy': brgy,
        'street': street,
        'postal': postal,
        'latitude': latitude,
        'longitude': longitude,
        'date': date.toIso8601String(),
        'wasteTypes': selectedWasteTypes,
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Pending booking');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await booking(context, fullname, contact, province, city, brgy,
              street, postal, latitude, longitude, date, selectedWasteTypes);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//fetch_booking
Future<Map<String, List<Map<String, dynamic>>>?> fetchBookingData(
    BuildContext context) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  // try {
  final response = await http.post(
    Uri.parse('$baseUrl/fetch_booking'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    //print(response.body);
    //return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    Map<String, dynamic> data = jsonDecode(response.body);

    // Extract 'booking' and 'wasteTypes' from the response
    List<Map<String, dynamic>> bookingList =
        List<Map<String, dynamic>>.from(data['booking']);
    List<Map<String, dynamic>> wasteTypeList =
        List<Map<String, dynamic>>.from(data['wasteTypes']);

    // Optionally: Combine them if needed or pass them individually
    return {'booking': bookingList, 'wasteTypes': wasteTypeList};
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchBookingData(context);
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
      print('No booking found');
      return null;
    }

    //showErrorSnackBar(context, response.body);
    print('Response: ${response.body}');
    return null;
  }
  // } catch (e) {
  //   print(e);
  // }
  //return null;
}

//fetch_booking
Future<Map<String, List<Map<String, dynamic>>>?> fetchBookingDetails(
    BuildContext context, int bookID) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  // try {
  final response = await http.post(
    Uri.parse('$baseUrl/fetch_booking_details'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'bookID': bookID}),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);

    // Returning the data as a map
    return {
      'booking': List<Map<String, dynamic>>.from(data['booking']),
      'wasteTypes': List<Map<String, dynamic>>.from(data['wasteTypes'])
    };
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchBookingDetails(context, bookID);
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
      print('No booking found');
      return null;
    }

    //showErrorSnackBar(context, response.body);
    print('Response: ${response.body}');
    return null;
  }
  // } catch (e) {
  //   print(e);
  // }
  //return null;
}

//booking update
Future<String?> bookingUpdate(
    BuildContext context,
    int bookId,
    String fullname,
    String contact,
    String province,
    String city,
    String brgy,
    String street,
    String postal,
    double latitude,
    double longitude,
    DateTime date,
    List<Map<String, dynamic>> selectedWasteTypes) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/booking_update'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookingId': bookId,
        'fullname': fullname,
        'contact': contact,
        'province': province,
        'city': city,
        'brgy': brgy,
        'street': street,
        'postal': postal,
        'latitude': latitude,
        'longitude': longitude,
        'date': date.toIso8601String(),
        'wasteTypes': selectedWasteTypes,
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Saved Changes');
      return 'success';
    } else if (response.statusCode == 409) {
      showErrorSnackBar(context, 'Unable to update booking, Already ongoing!');
      return 'ongoing';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await bookingUpdate(
              context,
              bookId,
              fullname,
              contact,
              province,
              city,
              brgy,
              street,
              postal,
              latitude,
              longitude,
              date,
              selectedWasteTypes);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Update Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//booking cancel
Future<String?> bookingCancel(BuildContext context, int bookId) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/booking_cancel'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bookingId': bookId}),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Successfully Cancelled');
      return 'success';
    } else if (response.statusCode == 409) {
      showErrorSnackBar(context, 'Unable to cancel booking, Already ongoing!');
      return 'ongoing';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await bookingCancel(context, bookId);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Cancel Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//fetch_pending_booking pickup
Future<Map<String, List<Map<String, dynamic>>>?> fetchPendingBooking() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  // try {
  final response = await http.post(
    Uri.parse('$baseUrl/fetch_pickup_booking'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    //print(response.body);
    //return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    Map<String, dynamic> data = jsonDecode(response.body);

    // Extract 'booking' and 'wasteTypes' from the response
    List<Map<String, dynamic>> bookingList =
        List<Map<String, dynamic>>.from(data['booking']);
    List<Map<String, dynamic>> wasteTypeList =
        List<Map<String, dynamic>>.from(data['wasteTypes']);

    // Optionally: Combine them if needed or pass them individually
    return {'booking': bookingList, 'wasteTypes': wasteTypeList};
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchPendingBooking();
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
      print('No booking found');
      return null;
    }

    //showErrorSnackBar(context, response.body);
    print('Response: ${response.body}');
    return null;
  }
  // } catch (e) {
  //   print(e);
  // }
  //return null;
}

//booking
Future<String?> bookingAccept(
    BuildContext context, int bookID, double latitude, double longitude) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/accept_booking'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookID': bookID,
        'haulLat': latitude,
        'haulLong': longitude,
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Booking is now accepted');
      return 'success';
    } else if (response.statusCode == 409) {
      showErrorSnackBar(context, 'Someone already accepted this booking!');
      return 'ongoing';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await bookingAccept(context, bookID, latitude, longitude);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

// Fetch haul latitude and longitude
Future<Map<String, dynamic>?> fetchAllLatLong(int bookID) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/fetch_all_latlong'), // Updated endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bookID': bookID}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // Return the fetched latitude and longitude as a map
      return {
        'haul_lat': data['haul_lat'],
        'haul_long': data['haul_long'],
        'cus_lat': data['cus_lat'],
        'cus_long': data['cus_long'],
      };
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await fetchAllLatLong(bookID);
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        print('No booking found');
        return null;
      }

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e'); // Handle exceptions
    return null;
  }
}

// update haul latitude and longitude
Future<String?> updateHaulLatLong(int bookID, double lat, double long) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/update_haul_latlong'), // Updated endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bookID': bookID, 'lat': lat, 'long': long}),
    );

    if (response.statusCode == 200) {
      // Return the fetched latitude and longitude as a map
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await updateHaulLatLong(bookID, lat, long);
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        print('No booking found');
        return null;
      }

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e'); // Handle exceptions
    return null;
  }
}

//fetch_pending_booking pickup
Future<Map<String, List<Map<String, dynamic>>>?> fetchCurrentPickup() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  // try {
  final response = await http.post(
    Uri.parse('$baseUrl/fetch_hauler_pickup'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    //print(response.body);
    //return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    Map<String, dynamic> data = jsonDecode(response.body);

    // Extract 'booking' and 'wasteTypes' from the response
    List<Map<String, dynamic>> bookingList =
        List<Map<String, dynamic>>.from(data['booking']);
    List<Map<String, dynamic>> wasteTypeList =
        List<Map<String, dynamic>>.from(data['wasteTypes']);
    List<Map<String, dynamic>> bookingList2 =
        List<Map<String, dynamic>>.from(data['booking2']);
    List<Map<String, dynamic>> wasteTypeList2 =
        List<Map<String, dynamic>>.from(data['wasteTypes2']);

    // Optionally: Combine them if needed or pass them individually
    return {
      'booking': bookingList,
      'wasteTypes': wasteTypeList,
      'booking2': bookingList2,
      'wasteTypes2': wasteTypeList2
    };
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchCurrentPickup();
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
      print('No booking found');
      return null;
    }

    //showErrorSnackBar(context, response.body);
    print('Response: ${response.body}');
    return null;
  }
  // } catch (e) {
  //   print(e);
  // }
  //return null;
}

//deactivate
Future<String?> deactivateUser(BuildContext context, String email) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/deactivate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Your account has been deactivated!');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await deactivateUser(context, email);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Update Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//binding password-email update
Future<String?> binding_trashtrack(
    BuildContext context, String? password) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/binding_trashtrack'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      await storeDataInHive(context);
      showSuccessSnackBar(context, 'Bound Successfully');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await binding_trashtrack(context, password);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Update Booking is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//binding password-email update
Future<String?> binding_google(BuildContext context, String? email) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/binding_google'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      //store token to storage
      final responseData = jsonDecode(response.body);
      final String accessToken = responseData['accessToken'];
      final String refreshToken = responseData['refreshToken'];
      storeTokens(accessToken, refreshToken);
      await storeDataInHive(context); // store data to local

      showSuccessSnackBar(context, 'Bound Successfully');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await binding_google(context, email);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Failed to Bind account with google!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

// update password
Future<String?> change_password(
    BuildContext context, String? newPassword) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/change_password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Password Changed');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await change_password(context, newPassword);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(); // Logout use
      } else {
        print('Response: ${response.body}');
      }

      //showErrorSnackBar(context, response.body);
    }
    print('Change password is not successful!');
    return response.body;
  } catch (e) {
    print(e.toString());
  }
  return null;
}

//deactivate
Future<String?> reactivate() async {
  var box = await Hive.openBox('mybox');
  String email = box.get('email');
  String type = box.get('type');

  final response = await http.post(
    Uri.parse('$baseUrl/reactivate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'type': type,
    }),
  );

  if (response.statusCode == 200) {
    return response.statusCode.toString();
  } else if (response.statusCode == 400) {
    return 'error';
  } else {
    print('Error response: ${response.body}');
    return response.body;
  }
}

// arrival notif
Future<String?> arrivalNotify(int bookID) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/arrival_notif'), // Updated endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bk_id': bookID}),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await arrivalNotify(bookID);
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        print('notify arrival failed');
        return null;
      }

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e'); // Handle exceptions
    return null;
  }
}

// read notification
Future<String?> readNotif(int notif_id) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/read_notification'), // Updated endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'notif_id': notif_id}),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await readNotif(notif_id);
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        return null;
      }

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e'); // Handle exceptions
    return null;
  }
}

// total request cus
Future<int?> totalPickupRequest() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/total_pickup_request'), // Updated endpoint
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody != null && responseBody['total'] != null) {
        return int.tryParse(
            responseBody['total'].toString()); // Ensure it's an int
      }
      return null;
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await totalPickupRequest();
        } else {
          // Refresh token is invalid or expired, logout the user
          await deleteTokens(); // Logout user
          return null;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        return null;
      }

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e'); // Handle exceptions
    return null;
  }
}

//fetch billing
Future<List<Map<String, dynamic>>?> fetchBill() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_bill'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> decodedList = jsonDecode(response.body);
    return decodedList.map((item) => item as Map<String, dynamic>).toList();
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchBill();
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

    print('Response: ${response.body}');
    return null;
  }
}

//fetch billing
Future<Map<String, dynamic>?> fetchBillDetails(int billId) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_bill_details'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'billId': billId}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchBillDetails(billId);
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

    print('Response: ${response.body}');
    return null;
  }
}

//fetch payment
Future<List<Map<String, dynamic>>?> fetchPayment() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_payment'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> decodedList = jsonDecode(response.body);
    return decodedList.map((item) => item as Map<String, dynamic>).toList();
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchPayment();
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

    print('Response: ${response.body}');
    return null;
  }
}

//fetch payment details
Future<Map<String, dynamic>?> fetchPaymentDetails(int billId) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_payment_details'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'billId': billId}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchPaymentDetails(billId);
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

    print('Response: ${response.body}');
    return null;
  }
}

//fetch pdf all bills
Future<List<Map<String, dynamic>>?> fetchAllPdfBills(int gb_id) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  final response = await http.post(
    Uri.parse('$baseUrl/fetch_pdf_bills'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'gb_id': gb_id}),
  );

  if (response.statusCode == 200) {
    List<dynamic> decodedList = jsonDecode(response.body);

    // Map each bill to extract and decode the PDF
    return decodedList.map((item) {
      String pdfBase64 = item['bd_file'];
      Uint8List pdfBytes = base64Decode(pdfBase64);

      return {
        'bd_created_at': item['bd_created_at'],
        'bd_total_amnt': item['bd_total_amnt'],
        'bd_file': pdfBytes,
      };
    }).toList();
  } else {
    if (response.statusCode == 401) {
      // Access token might be expired, attempt to refresh it
      print('Access token expired. Attempting to refresh...');
      String? refreshMsg = await refreshAccessToken();
      if (refreshMsg == null) {
        return await fetchAllPdfBills(gb_id);
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

    print('Response: ${response.body}');
    return null;
  }
}

// //fetch pdf all bills
// Future<List<Uint8List>?> fetchPdf(int gb_id) async {
//   Map<String, String?> tokens = await getTokens();
//   String? accessToken = tokens['access_token'];

//   if (accessToken == null) {
//     print('No access token available. User needs to log in.');
//     await deleteTokens();
//     return null;
//   }

//   final response = await http.post(
//     Uri.parse('$baseUrl/fetch_pdf'),
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode({'gb_id': gb_id}),
//   );

//   if (response.statusCode == 200) {
//     List<dynamic> decodedList = jsonDecode(response.body);
//     print('Decoded List: $decodedList');

//     List<Uint8List> pdfData = decodedList.map((item) {
//       if (item is Map && item.containsKey('data')) {
//         final byteArray = Uint8List.fromList(List<int>.from(item['data']));
//         print('Byte array: $byteArray'); // Ensure this is printed correctly
//         return byteArray;
//       } else {
//         print('Invalid item: $item');
//         return Uint8List(
//             0); // Return an empty byte array in case of an invalid item
//       }
//     }).toList();

//     print('PDF Data: $pdfData');
//     return pdfData;
//   } else {
//     if (response.statusCode == 401) {
//       // Access token might be expired, attempt to refresh it
//       print('Access token expired. Attempting to refresh...');
//       String? refreshMsg = await refreshAccessToken();
//       if (refreshMsg == null) {
//         return await fetchPdf(gb_id);
//       } else {
//         // Refresh token is invalid or expired, logout the user
//         await deleteTokens(); // Logout user
//         return null;
//       }
//     } else if (response.statusCode == 403) {
//       // Access token is invalid. logout
//       print('Access token invalid. Attempting to logout...');
//       await deleteTokens(); // Logout user
//     } else if (response.statusCode == 404) {
//       print('PDF not found');
//       return null;
//     }

//     print('Response: ${response.body}');
//     return null;
//   }
// }

//fetch billing
Future<List<Map<String, dynamic>>?> fetchVehicles() async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return null;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/fetch_all_vehicles'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Cast the list of dynamic to a list of Map<String, dynamic>
      List<Map<String, dynamic>> vehicles =
          List<Map<String, dynamic>>.from(data);

      return vehicles;
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await fetchVehicles();
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

      print('Response: ${response.body}');
      return null;
    }
  } catch (e) {
    print(e.toString());
    return null;
  }
}
