import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _locations = [];
  String? _errorMessage;

  Future<void> _searchLocation(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _locations = json.decode(response.body);
        if (_locations.isEmpty) {
          _errorMessage = 'No locations found.';
        } else {
          _errorMessage = null; // Clear error message if locations are found
        }
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load locations. Please try again.';
      });
      throw Exception('Failed to load locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Search')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Search for a location'),
            ),
            ElevatedButton(
              onPressed: () {
                _searchLocation(_controller.text);
              },
              child: Text('Search'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  var location = _locations[index];
                  return ListTile(
                    title: Text(location['display_name']),
                    onTap: () {
                      final lat = location['lat'];
                      final lon = location['lon'];
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Selected Location'),
                          content: Text('Latitude: $lat, Longitude: $lon'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
