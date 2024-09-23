import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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

  // two lists to store distance and duration
  List<double> routeDistances = [];
  List<double> routeDurations = [];

  String? selectedCurrentName;
  String? selectedPlaceName;
  String? startName;
  String? destinationName;

  String? nearestDistance;
  String? nearestDuration;

  bool failGetRoute = false;
  bool failGetPlaceName = false;
  bool isLoading = false;
  bool currentLocStreaming = false;
  StreamSubscription<Position>? _positionStream;

  final TextEditingController _startController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();
  //List<String> _foundPlaces = [];
  List<Map<String, dynamic>> _foundPlaces = [];

  bool startfound = true;
  bool destinationfound = true;
  bool startIsSearching = false;
  bool destinationIsSearching = false;
  //bool isLocationOn = false;
  //Timer? _locationCheckTimer;

  // @override
  // void initState() {
  //   super.initState();
  //   startRealTimeLocationCheck();
  // }

  @override
  void dispose() {
    _stopLocationUpdates(); // Stop location updates when the widget is disposed
    _mapController.dispose();
    _startFocusNode.dispose();
    super.dispose();
  }

  void _stopLocationUpdates() {
    if (_positionStream != null) {
      _positionStream?.cancel();
      _positionStream = null;
    }
  }

  // void startRealTimeLocationCheck() {
  //   print('checkinggggg locationnnnnn');
  //   _locationCheckTimer =
  //       Timer.periodic(Duration(milliseconds: 1), (timer) async {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  //     if (!serviceEnabled) {
  //       setState(() {
  //         isLocationOn = false;
  //       });

  //     } else {
  //       setState(() {
  //         isLocationOn = true;
  //       });
  //     }
  //   });
  // }

  // Fetch places using the OpenStreetMap Nominatim API
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _foundPlaces = [];
      });
      return;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query, Philippines&format=json&addressdetails=1&limit=5');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        url,
        // headers: {
        //   'Accept-Language': 'tl' // Set the preferred language to Filipino
        // },
      );

      if (response.statusCode == 200) {
        final List<dynamic> placesData = json.decode(response.body);
        setState(() {
          _foundPlaces = placesData.map((place) {
            return {
              'name': place['display_name'] as String,
              'lat': place['lat'] as String,
              'lon': place['lon'] as String,
            };
          }).toList();
        });
      } else {
        setState(() {
          _foundPlaces = [];
        });
      }
    } catch (error) {
      print('Error fetching places: $error');
      setState(() {
        _foundPlaces = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

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
    // int totalSeconds = duration.toInt();
    // int hours = totalSeconds ~/ 3600;
    // int minutes = (totalSeconds % 3600) ~/ 60;
    // int seconds = totalSeconds % 60;
    int totalSeconds = duration.toInt();
    int days = totalSeconds ~/ 86400; // 86400 seconds in a day
    int hours = (totalSeconds % 86400) ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (days > 0) {
      return '$days d $hours h';
    } else if (hours > 0) {
      return '$hours h $minutes min';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$seconds s';
    }
  }

  Future<void> fetchRoutes(LatLng start, LatLng destination) async {
    setState(() {
      isLoading = true;
    });

    try {
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

          if (routesData.length == 1) {
            nearestDuration = formatDuration(routeDurations[0]);
            nearestDistance = formatDistance(routeDistances[0]);
          } else {
            if (routeDurations[0] < routeDurations[1]) {
              nearestDuration = formatDuration(routeDurations[0]);
              nearestDistance = formatDistance(routeDistances[0]);
            } else {
              nearestDuration = formatDuration(routeDurations[1]);
              nearestDistance = formatDistance(routeDistances[1]);
            }
          }
        });
      } else {
        setState(() {
          nearestDuration = 'No available route/s';
          nearestDistance = '';
        });
        print('Failed to load routes');
      }
    } catch (e) {
      print('Failed to load routes: ${e}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetSelection() {
    setState(() {
      _currentLocation = null; // current location
      currentLocStreaming = false;
      _stopLocationUpdates();

      _startController.text = '';

      selectedPoint = null;
      startPoint = null;
      destinationPoint = null;
      routes.clear();
      isSelectingDirections = false;
      selectedCurrentName = null;

      selectedPlaceName = null;
      startName = null;
      destinationName = null;

      nearestDistance = null;
      nearestDuration = null;

      failGetRoute = false;
      failGetPlaceName = false;

      startfound = true;
      destinationfound = true;
      startIsSearching = false;
      destinationIsSearching = false;
      _startController.text = '';
      _destinationController.text = '';
    });
  }

  void handleOnePoint(LatLng point) {
    setState(() {
      selectedPoint = point;
      fetchSelectedPlaceNames();
    });
  }

  void handleDirections(LatLng point) {
    print('111111');
    setState(() {
      if (startPoint == null) {
        startPoint = point; // Set start point
        fetchStartPlaceName();
      } else if (destinationPoint == null) {
        destinationPoint = point; // Set destination point
        //fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
        fetchDestinationPlaceName();
      }

      if(startPoint != null && destinationPoint != null){
         fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
      }
      
    });
  }

  LatLng calculateMidpoint(LatLng a, LatLng b) {
    return LatLng(
        (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
  }

  Future<String?> getPlaceName(double lat, double lng) async {
    if (!currentLocStreaming)
      setState(() {
        isLoading = true;
      });
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');

      final response = await http.get(url, headers: {
        'User-Agent':
            'Testing/1.0 (krazyclips101@gmail.com)' // Required by Nominatim
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('address')) {
          // final address = data['address'];
          final displayName = data['display_name'];
          return displayName;
        }
      }
      setState(() {
        failGetPlaceName = true;
      });
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return 'No location name found';
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
    _startController.text = startPlace!;
    setState(() {
      startName = startPlace;
    });
  }

  void fetchDestinationPlaceName() async {
    String? destinationPlace = await getPlaceName(
        destinationPoint!.latitude, destinationPoint!.longitude);
    _destinationController.text = destinationPlace!;
    setState(() {
      destinationName = destinationPlace;
    });
  }

  //LOCATION PERMISSION
  Future<void> _getCurrentLocation() async {
    try {
      //if (!currentLocStreaming)
      // setState(() {
      //   isLoading = true;
      // });
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return; // Location services are not enabled
        }
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optionally, open the location settings:
        await Geolocator.openLocationSettings();
        return;
      }

      // LocationSettings locationSettings = LocationSettings(
      //   accuracy: LocationAccuracy.high, // Specify accuracy
      //   distanceFilter: 10, // Update when the user moves 10 meters
      // );

      // _positionStream = Geolocator.getPositionStream(
      //   locationSettings: locationSettings,
      // ).listen((Position position) async {
      //   String? currentLocationName = await getPlaceName(
      //     position.latitude,
      //     position.longitude,
      //   );

      //   setState(() {
      //     _currentLocation = LatLng(position.latitude, position.longitude);
      //     selectedCurrentName = currentLocationName;

      //     // Move map to current location
      //     _mapController.move(_currentLocation!, _mapController.zoom);

      //     // Redraw the route to the static destination
      //     //_drawRoute(_currentLocation!, _staticDestination);
      //   });
      // });

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Specify accuracy
        distanceFilter: 10, // Update when the user moves 10 meters
      );
      //////real time current position
      _positionStream = Geolocator.getPositionStream().listen(
        (Position position) async {
          String? getCurrentName =
              await getPlaceName(position.latitude, position.longitude);
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
            selectedCurrentName = getCurrentName;

            // Move the map to the new location
            _mapController.move(_currentLocation!, _mapController.zoom);

            // Fetch routes with the updated current location and static destination
            if (destinationPoint != null) {
              fetchRoutes(_currentLocation!, destinationPoint!);
            }
          });
          currentLocStreaming = true;
        },
        onError: (error) async {
          print('Error occurred in location stream: $error');
        },
      );

      // ///current pstion
      // Position position = await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.high);
      // String? getCurrentName =
      //     await getPlaceName(position.latitude, position.longitude);

      // setState(() {
      //   _currentLocation = LatLng(position.latitude, position.longitude);
      //   _mapController.move(
      //       _currentLocation!, 13.0); // Move to current location

      //   selectedCurrentName = getCurrentName;
      // });
    } catch (e) {
      print('fail to get current location!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                              width: routeDurations[i] > 360000
                                  ? 140
                                  : routeDurations[i] > 36000
                                      ? 130
                                      : routeDurations[i] > 3600
                                          ? 120
                                          : 100,
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
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 10,
                strokeAlign: 2,
                backgroundColor: Colors.deepPurple,
              ),
            ),

          //top layer
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

                        (!startIsSearching && !destinationIsSearching) ||
                        startIsSearching || !destinationIsSearching?
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green),
                            SizedBox(width: 3),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        width: 2, color: Colors.green)),
                                child: TextField(
                                  controller: _startController,
                                  focusNode: _startFocusNode,
                                  onChanged: (value) {
                                    startIsSearching = true;
                                    destinationIsSearching = false;
                                    startfound = false;
                                    _searchPlaces(
                                        value); // Call the search function
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select Starting Point',
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ):SizedBox(),
                        SizedBox(height: 3),

                        (!startIsSearching && !destinationIsSearching) ||
                        destinationIsSearching || !startIsSearching?
                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.red),
                            SizedBox(width: 3),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        width: 2, color: Colors.red)),
                                child: TextField(
                                  controller: _destinationController,
                                  focusNode: _destinationFocusNode,
                                  onChanged: (value) {
                                    destinationIsSearching = true;
                                    startIsSearching = false;
                                    destinationfound = false;
                                    _searchPlaces(
                                        value); // Call the search function
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select Destination Point',
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ):SizedBox(),
                        startIsSearching
                            ? Container(
                                //height: _foundPlaces.isEmpty && _startController.text.isEmpty? 10 : _foundPlaces.isEmpty && _startController.text.isNotEmpty? 100: 500,
                                child: _startController.text.isEmpty ||
                                        startfound
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : _foundPlaces.isEmpty &&
                                            _startController.text.isNotEmpty &&
                                            !startfound
                                        ? Center(
                                            child: ListTile(
                                              title: Text(
                                                  '      No Location found'),
                                            ),
                                          )
                                        : Container(
                                            height: 500,
                                            child: ListView.builder(
                                              itemCount: _foundPlaces.length,
                                              itemBuilder: (context, index) {
                                                final place =
                                                    _foundPlaces[index];
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title:
                                                          Text(place['name']),
                                                      onTap: () {
                                                        setState(() {
                                                           _foundPlaces = [];
                                                          startIsSearching =
                                                              false;
                                                          startfound = true;
                                                          _startController
                                                                  .text =
                                                              place['name'];
                                                          // _foundPlaces =
                                                          //     []; // Clear the results after selection
                                                          print(place['lat']);
                                                          print(place['lon']);
                                                          startPoint = LatLng(
                                                              double.parse(
                                                                  place['lat']),
                                                              double.parse(
                                                                  place[
                                                                      'lon']));
                                                          routes.clear();
                                                          if (startPoint !=
                                                                  null &&
                                                              destinationPoint !=
                                                                  null) {
                                                            fetchRoutes(
                                                                startPoint!,
                                                                destinationPoint!);
                                                          }
                                                          _mapController.move(
                                                              startPoint!,
                                                              _mapController
                                                                  .zoom);
                                                          _startFocusNode
                                                              .unfocus();
                                                        });
                                                      },
                                                    ),
                                                    Divider(
                                                      height: 0,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                              )
                            : SizedBox(),
                        destinationIsSearching
                            ? Container(
                                //height: _foundPlaces.isEmpty && _startController.text.isEmpty? 10 : _foundPlaces.isEmpty && _startController.text.isNotEmpty? 100: 500,
                                child: _destinationController.text.isEmpty ||
                                        destinationfound
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : _foundPlaces.isEmpty &&
                                            _destinationController.text.isNotEmpty &&
                                            !destinationfound
                                        ? Center(
                                            child: ListTile(
                                              title: Text(
                                                  '      No Location found'),
                                            ),
                                          )
                                        : Container(
                                            height: 500,
                                            child: ListView.builder(
                                              itemCount: _foundPlaces.length,
                                              itemBuilder: (context, index) {
                                                final place =
                                                    _foundPlaces[index];
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title:
                                                          Text(place['name']),
                                                      onTap: () {
                                                        setState(() {
                                                          _foundPlaces = [];
                                                            destinationIsSearching =
                                                              false;
                                                          destinationfound = true;
                                                          _destinationController
                                                                  .text =
                                                              place['name'];
                                                          // _foundPlaces =
                                                          //     []; // Clear the results after selection
                                                          print(place['lat']);
                                                          print(place['lon']);
                                                          destinationPoint = LatLng(
                                                              double.parse(
                                                                  place['lat']),
                                                              double.parse(
                                                                  place[
                                                                      'lon']));
                                                          routes.clear();
                                                          if (destinationPoint !=
                                                                  null &&
                                                              startPoint !=
                                                                  null) {
                                                            fetchRoutes(
                                                                startPoint!,
                                                                destinationPoint!);
                                                          }
                                                          _mapController.move(
                                                              destinationPoint!,
                                                              _mapController
                                                                  .zoom);
                                                          _destinationFocusNode
                                                              .unfocus();
                                                        });
                                                      },
                                                    ),
                                                    Divider(
                                                      height: 0,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                )
              : Container(),

          //floating 2 btns
          Positioned(
            bottom: 200,
            right: 0,
            child: Column(
              children: [
                //current location btn
                Container(
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: shadowColor),
                    child: InkWell(
                      onTap: () {
                        if (!isLoading) {
                          if (selectedCurrentName != null) {
                            resetSelection();
                          } else {
                            resetSelection();
                            _getCurrentLocation();
                          }
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

                //direction btn
                Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: shadowColor),
                    child: InkWell(
                      onTap: () {
                        if (!isLoading) {
                          if (isSelectingDirections) {
                            resetSelection(); // Reset when closing direction selection
                            print(nearestDuration);
                          } else {
                            resetSelection(); // Optional: reset for fresh start
                            print(nearestDuration);
                            setState(() {
                              isSelectingDirections =
                                  true; // Switch to directions mode
                            });
                          }
                        }
                      },
                      child: Icon(
                        isSelectingDirections ? Icons.close : Icons.directions,
                        color: Colors.white,
                        size: 30,
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
      bottomSheet: selectedPoint != null && !isLoading
          ? Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  boxShadow: shadowColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => resetSelection(),
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
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
          // : nearestDistance > 0 || nearestDistance > 0
          : nearestDuration != null && !isLoading
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
                            '${nearestDuration} ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: nearestDistance == ''
                                    ? Colors.red
                                    : Colors.green),
                          ),
                          Text(
                            '(${nearestDistance})',
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
              : selectedCurrentName != null && !isLoading
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
                          Text(
                            'Current Location',
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

  const RouteMarker({
    Key? key,
    required this.duration,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
