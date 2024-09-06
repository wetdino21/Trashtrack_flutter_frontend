import 'dart:convert';
import 'package:http/http.dart' as http;

//final String baseUrl = 'http://localhost:3000/api'; 

final String baseUrl = 'http://192.168.254.187:3000/api'; 

Future<String?> emailCheck(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/email_check'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print('Good Email');
    return null;  // No error, return null
  } else if (response.statusCode == 400) {
    print('Customer with this email already exists');
    
    return 'Customer with this email already exists';  // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check customer email');
    return 'error'; 
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
    return null;  // No error, return null
  } else if (response.statusCode == 400) {
    print('email doesn\'t exists');
    
    return 'No account associated with the email';  // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Failed to check account email');
    return 'error'; 
  }
}

Future<String?> createCustomer(String fname, String lname, String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fname': fname,
      'lname': lname,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    print('Customer created successfully');
    return null;  // No error, return null
  } 
  // else if (response.statusCode == 400) {
  //   print('Customer with this email already exists');
    
  //   return 'Customer with this email already exists';  // Return the error message from the server
  // } 
  else {
    //print('Error response: ${response.body}');
    print('Failed to create customer');
    return 'error'; 
  }
}

Future<String?> loginAccount(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    print('Login successfully');
    return 'customer';  // No error
  } else if (response.statusCode == 201) {
     print('Login successfully');
    return 'hauler';  // No error
  } else if (response.statusCode == 404) {
    return 'Email address not found'; 
  } 
   else if (response.statusCode == 401) {
    return 'Incorrect Password'; 
  } else {
    //print('Error response: ${response.body}');
    return 'error'; 
  }
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
    return null;  // No error, return null
  } else if (response.statusCode == 400) {
    print('New password cannot be the same as the old password');
    
    return 'New password cannot be the same as the old password';  // Return the error message from the server
  } else if (response.statusCode == 404) {
    print('Email not found');
    
    return 'Email not found';  // Return the error message from the server
  } else {
    //print('Error response: ${response.body}');
    print('Database error');
    return 'error'; 
  }
}
