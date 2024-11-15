import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trashtrack/API/api_network.dart';

String baseUrl = globalAddressUrl();

Future<List<dynamic>> fetchProvinces() async {
  final response = await http.get(Uri.parse('$baseUrl/provinces.json'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // Filter for Cebu and sort alphabetically by name
    final List<dynamic> cebuProvinces = data.where((province) => province['name'].toLowerCase() == 'cebu').toList();
    cebuProvinces.sort((a, b) => a['name'].compareTo(b['name']));
    return cebuProvinces;
  } else {
    throw Exception('Failed to load provinces');
  }
}

Future<List<dynamic>> fetchCitiesMunicipalities(String provinceCode) async {
  final response = await http.get(Uri.parse('$baseUrl/provinces/$provinceCode/cities-municipalities.json'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // Sort alphabetically by name
    data.sort((a, b) => a['name'].compareTo(b['name']));
    return data;
  } else {
    throw Exception('Failed to load cities/municipalities');
  }
}

Future<List<dynamic>> fetchBarangays(String cityMunicipalityCode) async {
  final response = await http.get(Uri.parse('$baseUrl/cities-municipalities/$cityMunicipalityCode/barangays.json'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // Sort alphabetically by name
    data.sort((a, b) => a['name'].compareTo(b['name']));
    return data;
  } else {
    throw Exception('Failed to load barangays');
  }
}

