import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_token.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_date.dart';

// final String baseUrl = 'http://192.168.254.187:3000';
String baseUrl = globalUrl();

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
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    //store token to storage
    final responseData = jsonDecode(response.body);
    final String accessToken = responseData['accessToken'];
    final String refreshToken = responseData['refreshToken'];
    storeTokens(accessToken, refreshToken);
    await storeDataInHive(context); // store data to local

    print('Login successfully');
    if (response.statusCode == 200) {
      return 'customer'; // No error
    } else if (response.statusCode == 201) {
      return 'hauler'; // No error
    }
  } else if (response.statusCode == 202) {
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
  return response.body;
}

Future<String?> updatepassword(String email, String newPassword) async {
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
) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout user
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
        String? refreshMsg = await refreshAccessToken(context);
        if (refreshMsg == null) {
          return await userUpdate(context, bookId, fname, mname, lname, email,
              photoBytes, contact, province, city, brgy, street, postal);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired. Please login again.');
        await deleteTokens(context); // Logout user
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
    await deleteTokens(context); // Logout use
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
      String? refreshMsg = await refreshAccessToken(context);
      if (refreshMsg == null) {
        return await updateProfile(context, fname, lname);
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      showErrorSnackBar(
          context, 'Active time has been expired please login again.');
      await deleteTokens(context); // Logout use
    } else {
      print('Response: ${response.body}');
    }

    //showErrorSnackBar(context, response.body);
  }
}

//booking
Future<String?> booking(
    BuildContext context,
    int id,
    DateTime date,
    String province,
    String city,
    String brgy,
    String street,
    String postal,
    double latitude,
    double longitude,
    List<Map<String, dynamic>> selectedWasteTypes) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/booking'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'date': date.toIso8601String(),
        'province': province,
        'city': city,
        'brgy': brgy,
        'street': street,
        'postal': postal,
        'latitude': latitude,
        'longitude': longitude,
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
        String? refreshMsg = await refreshAccessToken(context);
        if (refreshMsg == null) {
          return await booking(context, id, date, province, city, brgy, street,
              postal, longitude, latitude, selectedWasteTypes);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(context); // Logout use
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
    await deleteTokens(context);
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
      String? refreshMsg = await refreshAccessToken(context);
      if (refreshMsg == null) {
        return await fetchBookingData(context);
      } else {
        // Refresh token is invalid or expired, logout the user
        await deleteTokens(context); // Logout user
        return null;
      }
    } else if (response.statusCode == 403) {
      // Access token is invalid. logout
      print('Access token invalid. Attempting to logout...');
      await deleteTokens(context); // Logout user
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
    DateTime date,
    String province,
    String city,
    String brgy,
    String street,
    String postal,
    double latitude,
    double longitude,
    List<Map<String, dynamic>> selectedWasteTypes) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
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
        'date': date.toIso8601String(),
        'province': province,
        'city': city,
        'brgy': brgy,
        'street': street,
        'postal': postal,
        'latitude': latitude,
        'longitude': longitude,
        'wasteTypes': selectedWasteTypes,
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Saved Changes');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken(context);
        if (refreshMsg == null) {
          return await bookingUpdate(context, bookId, date, province, city,
              brgy, street, postal, latitude, longitude, selectedWasteTypes);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(context); // Logout use
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
    await deleteTokens(context); // Logout use
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
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken(context);
        if (refreshMsg == null) {
          return await bookingCancel(context, bookId);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(context); // Logout use
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


//deactivate
//booking update
Future<String?> deactivateUser(
    BuildContext context,
    String email) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];
  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens(context); // Logout use
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/deactivate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
       'email': email
      }),
    );

    if (response.statusCode == 200) {
      showSuccessSnackBar(context, 'Your account has been deactivated!');
      return 'success';
    } else {
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken(context);
        if (refreshMsg == null) {
          return await deactivateUser(context, email);
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. logout
        print('Access token invalid. Attempting to logout...');
        showErrorSnackBar(
            context, 'Active time has been expired please login again.');
        await deleteTokens(context); // Logout use
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