import 'dart:convert';
import 'package:http/http.dart' as http;

//final String baseUrl = 'http://localhost:3000/api'; 

final String baseUrl = 'http://192.168.254.187:3000/api'; 
Future<void> createUser(String name, String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'email': email}),
  );

  if (response.statusCode == 201) {
    print('User created successfully');
  } else {
    print('Failed to create user');
  }
}

Future<void> fetchUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/users'));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print('Users: $data');
  } else {
    print('Failed to fetch users');
  }
}

Future<void> updateUser(int id, String name, String email) async {
  final response = await http.put(
    Uri.parse('$baseUrl/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'email': email}),
  );

  if (response.statusCode == 200) {
    print('User updated successfully');
  } else {
    print('Failed to update user');
  }
}

Future<void> deleteUser(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

  if (response.statusCode == 200) {
    print('User deleted successfully');
  } else {
    print('Failed to delete user');
  }
}
