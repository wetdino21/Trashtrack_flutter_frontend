import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/API/api_email_service.dart';

String baseURL = 'http://192.168.254.187:3000';

Future<bool> createUser(String name, int grade, Uint8List picture) async {
  final response = await http.post(
    //endpoint
    Uri.parse('$baseURL/create'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
      {'name': name, 'grade': grade, 'picture': base64Encode(picture)},
    ),
  );

  if (response.statusCode == 200) {
    print(response.body);
    return true;
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    return false; // Handle non-200 status codes gracefully.
  }
}

Future<bool> updateUser(String name, int grade, Uint8List picture) async {
  final Response = await http.post(Uri.parse('$baseURL/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'grade': grade, 'picture': picture}));

  if (Response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<bool> deleteUser(int grade) async {
  final response = await http.post(
    Uri.parse('$baseURL/delete'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'grade': grade}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<List<Map<String, dynamic>>?> fetchUsers() async {
  try {
    final response = await http.post(
      Uri.parse('$baseURL/fetch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body)); // array of array
      print(data);
      return data;
    } else {
      return null;
    }
  } catch (e) {
    print('catch error: $e');
    return null;
  }
}
