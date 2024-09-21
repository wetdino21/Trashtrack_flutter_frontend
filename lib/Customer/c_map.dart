import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';
import 'package:geolocator/geolocator.dart';

class C_MapScreen extends StatefulWidget {
  @override
  _C_MapScreenState createState() => _C_MapScreenState();
}

class _C_MapScreenState extends State<C_MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  LatLng? selectedPoint;
  LatLng? startPoint;
  LatLng? destinationPoint;
  List<List<LatLng>> routes = [];
  bool isSelectingDirections = false;

  // Add two lists to store distance and duration
  List<double> routeDistances = [];
  List<double> routeDurations = [];

  String? selectedCurrentName;
  String? selectedPlaceName;
  String? startName;
  String? destinationName;

  // String? nearestDistance;
  // String? nearestTime;

  double nearestDistance = 0; // To store the nearest distance
  double nearestDuration = 0; // To store the nearest duration

  double currentLocBtn = 150;

  // Utility function to format distance
  String formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toStringAsFixed(0)} m';
    }
  }

  // Utility function to format duration
  String formatDuration(double duration) {
    int totalSeconds = duration.toInt();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$seconds s';
    }
  }

  Future<void> fetchRoutes(LatLng start, LatLng destination) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}'
      '?alternatives=true&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List routesData = data['routes'];

      print('Number of routes returned: ${routesData.length}');

      setState(() {
        routes = routesData.map<List<LatLng>>((route) {
          final List coordinates = route['geometry']['coordinates'];
          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]); // reverse longitude/latitude
          }).toList();
        }).toList();

        // Store distance and duration for each route
        routeDistances = routesData
            .map<double>((route) => (route['distance'] as num).toDouble())
            .toList();
        routeDurations = routesData
            .map<double>((route) => (route['duration'] as num).toDouble())
            .toList();
      });
    } else {
      //throw Exception('Failed to load routes');
      print('Failed to load routes');
    }
  }

  void resetSelection() {
    setState(() {
      selectedPoint = null;
      startPoint = null;
      destinationPoint = null;
      routes.clear();
      isSelectingDirections = false;
      currentLocBtn = 150;
      selectedCurrentName = null;

      selectedPlaceName = null;
      startName = null;
      destinationName = null;

      nearestDistance = 0;
      nearestDuration = 0;
    });
  }

  void handleOnePoint(LatLng point) {
    setState(() {
      selectedPoint = point;
      fetchSelectedPlaceNames();
    });
  }

  void handleDirections(LatLng point) {
    setState(() {
      if (startPoint == null) {
        startPoint = point; // Set start point
        fetchStartPlaceName();
      } else if (destinationPoint == null) {
        destinationPoint = point; // Set destination point
        fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
        fetchDestinationPlaceName();
      }
    });
  }

  LatLng calculateMidpoint(LatLng a, LatLng b) {
    return LatLng(
        (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
  }

  Future<String?> getPlaceName(double lat, double lng) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');

    final response = await http.get(url, headers: {
      'User-Agent':
          'MyApp/1.0 (krazyclips101@gmail.com)' // Required by Nominatim
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('address')) {
        // final address = data['address'];
        final displayName = data['display_name'];
        return displayName;
      }
    }
    return null;
  }

  //   void fetchCurrentName() async {
  //   String? getCurrentName =
  //       await getPlaceName(startPoint!.latitude, startPoint!.longitude);

  //   setState(() {
  //     selectedCurrentName = getCurrentName;
  //   });
  // }

  void fetchSelectedPlaceNames() async {
    // Get the place name first by awaiting the result
    String? placeName =
        await getPlaceName(selectedPoint!.latitude, selectedPoint!.longitude);

    // Then call setState to update the UI
    setState(() {
      selectedPlaceName = placeName;
    });
  }

  void fetchStartPlaceName() async {
    String? startPlace =
        await getPlaceName(startPoint!.latitude, startPoint!.longitude);

    setState(() {
      startName = startPlace;
    });
  }

  void fetchDestinationPlaceName() async {
    String? destinationPlace = await getPlaceName(
        destinationPoint!.latitude, destinationPoint!.longitude);

    setState(() {
      destinationName = destinationPlace;
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return; // Location services are not enabled
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String? getCurrentName =
        await getPlaceName(position.latitude, position.longitude);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 13.0); // Move to current location

      selectedCurrentName = getCurrentName;
      currentLocBtn = 200;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: C_CustomAppBar(title: 'Map'),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(10.3157, 123.8854), // Example: Cebu City
              zoom: 13.0,
              //maxZoom: 19,
              maxZoom: 19, // Maximum zoom in level
              minZoom: 5, // Minimum zoom out level
              onTap: (tapPosition, point) => isSelectingDirections
                  ? handleDirections(point)
                  : handleOnePoint(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                maxZoom: 19, // Maximum zoom in level
                minZoom: 5, // Minimum zoom out level
              ),

              // PolylineLayer for multiple routes
              if (routes.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    for (int i = 0; i < routes.length && i < 3; i++)
                      Polyline(
                        points: routes[i],
                        strokeWidth: 4.0,
                        color: i == 0
                            ? Colors.blue
                            : i == 1
                                ? Colors.orange
                                : Colors.purple,
                      ),
                  ],
                ),

              // Display markers
              if (selectedCurrentName !=
                  null) // Add a marker for the current location
                MarkerLayer(
                  markers: [
                    Marker(
                        point: _currentLocation!,
                        builder: (ctx) => Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                        rotate: true),
                  ],
                ),

              if (selectedPoint != null) ...[
                MarkerLayer(
                  markers: [
                    Marker(
                        width: 80.0,
                        height: 80.0,
                        point: selectedPoint!,
                        builder: (ctx) => Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                        rotate: true),
                  ],
                ),
              ],
              if (startPoint != null) ...[
                MarkerLayer(
                  markers: [
                    Marker(
                      rotate: true,
                      width: 80.0,
                      height: 80.0,
                      point: startPoint!,
                      builder: (ctx) => Icon(Icons.location_pin,
                          color: Colors.green, size: 40),
                    ),
                  ],
                ),
              ],
              if (destinationPoint != null) ...[
                MarkerLayer(
                  markers: [
                    Marker(
                      rotate: true,
                      width: 80.0,
                      height: 80.0,
                      point: destinationPoint!,
                      builder: (ctx) =>
                          Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],

              // Display distance and duration on the map
              if (routes.isNotEmpty)
                for (int i = 0; i < routes.length && i < 3; i++)
                  for (int j = 0; j < routes[i].length - 1; j++)
                    if (j ==
                        (routes[i].length - 2) ~/
                            2) // Check if it's the middle segment
                      MarkerLayer(
                        markers: [
                          Marker(
                              rotate: true,
                              width: 100,
                              height: 100,
                              point: LatLng(
                                calculateMidpoint(
                                            routes[i][j], routes[i][j + 1])
                                        .latitude +
                                    0.0001, // Adjust as needed
                                calculateMidpoint(
                                        routes[i][j], routes[i][j + 1])
                                    .longitude,
                              ),
                              builder: (ctx) {
                                double currentDistance = routeDistances[i];
                                double currentDuration = routeDurations[i];

                                if (nearestDistance == 0) {
                                  nearestDistance = currentDistance;
                                  nearestDuration = currentDuration;
                                }
                                if (currentDistance < nearestDistance) {
                                  nearestDistance = currentDistance;
                                  nearestDuration = currentDuration;
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Triangular Pin
                                    Container(
                                      child: RouteMarker(
                                        duration:
                                            formatDuration(routeDurations[i]),
                                        distance:
                                            formatDistance(routeDistances[i]),
                                      ),
                                    ),
                                    //arrowButtomBox(),
                                  ],
                                );
                              }),
                        ],
                      ),
            ],
          ),
          isSelectingDirections
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(15)),
                        boxShadow: shadowColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Directions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.green), // Icon for starting point
                            SizedBox(
                                width: 8), // Add space between icon and text
                            Expanded(
                              // Makes the text wrap within the available space
                              child: Text(
                                startName == null
                                    ? 'Select Starting Point'
                                    : startName!,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                                softWrap:
                                    true, // Allow wrapping to the next line
                                overflow: TextOverflow
                                    .visible, // Prevent clipping, allow text to expand
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.flag,
                                color:
                                    Colors.red), // Icon for destination point
                            SizedBox(
                                width: 8), // Add space between icon and text
                            Expanded(
                              // Makes the text wrap within the available space
                              child: Text(
                                destinationName == null
                                    ? 'Select Destination Point'
                                    : destinationName!,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                                softWrap:
                                    true, // Allow wrapping to the next line
                                overflow: TextOverflow
                                    .visible, // Prevent clipping, allow text to expand
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          Positioned(
            bottom: selectedPoint != null ? 200 : currentLocBtn,
            right: 0,
            child: Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: shadowColor),
                child: InkWell(
                  onTap: () {
                    if (selectedCurrentName != null) {
                      resetSelection();
                    } else {
                      resetSelection();
                      _getCurrentLocation();
                    }
                  },
                  child: Icon(
                    selectedCurrentName != null
                        ? Icons.close
                        : Icons.my_location,
                    color: Colors.red,
                    size: 30,
                  ),
                )),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(
            isSelectingDirections || selectedPoint != null
                ? Icons.close
                : Icons.directions,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            if (isSelectingDirections || selectedPoint != null) {
              resetSelection(); // Reset when closing direction selection
            } else {
              resetSelection(); // Optional: reset for fresh start
              setState(() {
                isSelectingDirections = true; // Switch to directions mode
              });
            }
          },
        ),
      ),
      bottomSheet: selectedPoint != null
          ? Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedPlaceName == null ? '' : selectedPlaceName!,
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow
                              .visible, // Prevent clipping, allow text to expand
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Text(
                    '${selectedPoint?.latitude}, ${selectedPoint?.longitude}',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [],
                  ),
                ],
              ),
            )
          : nearestDistance > 0 && nearestDistance > 0
              ? Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      boxShadow: shadowColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            formatDuration(nearestDuration) + ' ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.green),
                          ),
                          Text(
                            ' (${formatDistance(nearestDistance)})',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Fastest Route',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : selectedCurrentName != null
                  ? Container(
                      padding: EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCurrentName == null
                                      ? ''
                                      : selectedCurrentName!,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  overflow: TextOverflow
                                      .visible, // Prevent clipping, allow text to expand
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Text(
                            '${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
                            style: TextStyle(color: Colors.blue),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [],
                          ),
                        ],
                      ),
                    )
                  : null,
      bottomNavigationBar: C_BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

// Custom Marker Widget
class RouteMarker extends StatelessWidget {
  final String duration;
  final String distance;

  const RouteMarker({Key? key, required this.duration, required this.distance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Triangular Pin
        Container(
          width: 0,
          height: 0,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: shadowColor,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.directions_car, size: 18),
                  SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    distance,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


  // @override
  // Widget arrowButtomBox() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       // First Box: Diagonal Gradient (transparent to black)
  //       Container(
  //         width: 40,
  //         height: 40,
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //             ],
  //             begin: Alignment.bottomLeft,
  //             end: Alignment.topRight,
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 40,
  //         height: 40,
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.white,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //               Colors.transparent,
  //             ],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }