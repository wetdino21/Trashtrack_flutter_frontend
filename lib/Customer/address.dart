import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://psgc.gitlab.io/api';

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

class DropDownExample extends StatefulWidget {
  @override
  _DropDownExampleState createState() => _DropDownExampleState();
}

class _DropDownExampleState extends State<DropDownExample> {
  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvince;
  String? _selectedCityMunicipality;
  String? _selectedBarangay;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinces = provinces;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
    }
  }

  Future<void> _loadCitiesMunicipalities(String provinceCode) async {
    try {
      final citiesMunicipalities = await fetchCitiesMunicipalities(provinceCode);
      setState(() {
        _citiesMunicipalities = citiesMunicipalities;
        _barangays = []; // Clear barangays when a new city is selected
        _selectedCityMunicipality = null;
        _selectedBarangay = null;
      });
    } catch (e) {
      print('Error fetching cities/municipalities: $e');
    }
  }

  Future<void> _loadBarangays(String cityMunicipalityCode) async {
    try {
      final barangays = await fetchBarangays(cityMunicipalityCode);
      setState(() {
        _barangays = barangays;
        _selectedBarangay = null;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cebu Location Dropdowns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedProvince,
              hint: Text('Select Province'),
              items: _provinces.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['code'], // Province code
                  child: Text(item['name']), // Province name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value;
                });
                _loadCitiesMunicipalities(value!);
              },
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedCityMunicipality,
              hint: Text('Select City/Municipality'),
              items: _citiesMunicipalities.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['code'], // City/Municipality code
                  child: Text(item['name']), // City/Municipality name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCityMunicipality = value;
                });
                _loadBarangays(value!);
              },
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedBarangay,
              hint: Text('Select Barangay'),
              items: _barangays.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['code'], // Barangay code
                  child: Text(item['name']), // Barangay name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBarangay = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

