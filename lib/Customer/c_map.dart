

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class C_MapScreen extends StatefulWidget {
  @override
  _C_MapScreenState createState() => _C_MapScreenState();
}

class _C_MapScreenState extends State<C_MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(10.3157, 123.8854); // Cebu coordinates

  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Inayawan Sunshine Village',
      'coords': LatLng(10.262550, 123.856429),
    },
    {
      'name': 'Bacayan Villa Leyson',
      'coords': LatLng(10.384937, 123.915956),
    },
    {
      'name': 'San Miguel Lorega',
      'coords': LatLng(10.306606, 123.904336),
    },
  ];

  void _updateLocation(LatLng newLocation) {
    setState(() {
      _currentLocation = newLocation;
    });
    _mapController.move(
        newLocation, _mapController.zoom); // Animate to the new location
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: C_CustomAppBar(title: 'Map'),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[300],
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 13.0,
                minZoom: 1.0,
                maxZoom:
                    19.0, // Set the maximum zoom level (19 is typically max for OSM)
                onPositionChanged: (position, hasGesture) {
                  if (position.zoom != null && position.zoom! > 18.0) {
                    _mapController.move(
                        _mapController.center, 18.0); // Enforce max zoom
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  maxZoom: 19, // Tile layer max zoom
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      builder: (context) => Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SlidingUpPanel(
            minHeight: 40,
            maxHeight: MediaQuery.of(context).size.height / 2.9,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            panel: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ..._locations.map((location) => GestureDetector(
                        onTap: () => _updateLocation(location['coords']),
                        child: RouteCard(
                          title: location['name'],
                          arrivalTime:
                              'N/A', // Update this if you have arrival times
                          isHighlighted: false,
                        ),
                      )),
                  SizedBox(height: 8),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       // Handle Okay button press
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.green[900],
                  //       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  //     ),
                  //     child: Text(
                  //       'Okay',
                  //       style: TextStyle(color: Colors.white, fontSize: 18),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: C_BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String title;
  final String arrivalTime;
  final bool isHighlighted;

  RouteCard({
    required this.title,
    required this.arrivalTime,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? null : Border.all(color: Colors.green[900]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_pin,
                color: isHighlighted ? Colors.white : Colors.green[900],
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.green[900],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Arrival $arrivalTime',
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.green[900],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}


