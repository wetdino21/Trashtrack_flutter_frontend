import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/Customer/c_drawer.dart';
import 'package:trashtrack/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class C_MapScreen extends StatefulWidget {
  final LatLng? pickupPoint;

  C_MapScreen({this.pickupPoint});

  @override
  _C_MapScreenState createState() => _C_MapScreenState();
}

class _C_MapScreenState extends State<C_MapScreen> {
  final GlobalKey<_C_MapScreenState> _mapScreenKey =
      GlobalKey<_C_MapScreenState>();
  bool hideScreen = false;
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
  int? nearestRoute;

  bool failGetRoute = false;
  bool failGetPlaceName = false;
  bool isLoading = false;
  bool currentLocStreaming = false;
  bool startLocStreaming = false;
  StreamSubscription<Position>? _positionStream;

  final TextEditingController _startController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();
  StreamSubscription<Position>? _startPositionStream;
  //List<String> _foundPlaces = [];
  List<Map<String, dynamic>> _foundPlaces = [];

  bool startfound = true;
  bool destinationfound = true;
  bool startIsSearching = false;
  bool destinationIsSearching = false;

  //bool isLocationOn = false;
  //Timer? _locationCheckTimer;

  @override
  void initState() {
    super.initState();
    if (widget.pickupPoint != null) {
      print('finding route');
      pickUpDirection();
    }

    //startRealTimeLocationCheck();
  }

  @override
  void dispose() {
    _stopLocationUpdates(); // Stop location updates when the widget is disposed
    _mapController.dispose();
    _startController.dispose();
    _destinationController.dispose();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();

    print('mappppp disposeeee');
    super.dispose();
  }

//LOCATION PERMISSION
  Future<void> pickUpDirection() async {
    try {
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

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Specify accuracy
        distanceFilter: 10, // Update when the user moves 10 meters
      );
      //////real time current position
      _startPositionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          String? getCurrentName =
              await getPlaceName(position.latitude, position.longitude);
          String? getDestiantionName = await getPlaceName(
              widget.pickupPoint!.latitude, widget.pickupPoint!.longitude);
          setState(() {
            _startController.text = getCurrentName!;
            startPoint = LatLng(position.latitude, position.longitude);
            if (!startLocStreaming)
              _mapController.move(startPoint!, _mapController.zoom);

            startLocStreaming = true;
            destinationPoint = widget.pickupPoint;
            fetchRoutes(startPoint!, destinationPoint!);
            // if (destinationPoint != null) {
            //   fetchRoutes(startPoint!, destinationPoint!);
            // }
            _startController.text = getCurrentName;
            _destinationController.text = getDestiantionName!;
            isSelectingDirections = true;
            startLocStreaming = true;
          });
        },
        onError: (error) async {
          print('Error occurred in location stream: $error');
        },
      );
    } catch (e) {
      print('fail to get current location!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _stopLocationUpdates() {
    if (_positionStream != null) {
      _positionStream?.cancel();
      _positionStream = null;
      print('Single Current Stream is now off!');
    }
    if (_startPositionStream != null) {
      _startPositionStream?.cancel();
      _startPositionStream = null;
      print('Direction Current Stream is now off!');
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
    if (!startLocStreaming)
      setState(() {
        isLoading = true;
      });

    int retryCount = 0;
    const int maxRetries = 10;

    while (retryCount < maxRetries) {
      try {
        final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}'
          '?alternatives=true&geometries=geojson',
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
          retryCount = 10; //no retry
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
            routeDurations = routesData.map<double>((route) {
              double originalDuration = (route['duration'] as num).toDouble();

              // Assuming 2 minutes added per kilometer
              double distanceInKm = route['distance'] / 1000;
              double addedDuration =
                  distanceInKm * 1.2 * 60; // 1.2 minutes per km in seconds

              return originalDuration + addedDuration; // Adjusted duration
            }).toList();

            // routeDurations = routesData
            //     .map<double>((route) => (route['duration'] as num).toDouble())
            //     .toList();

            if (routesData.length == 1) {
              nearestDuration = formatDuration(routeDurations[0]);
              nearestDistance = formatDistance(routeDistances[0]);
              nearestRoute = 1;
            } else {
              if (routeDurations[0] < routeDurations[1]) {
                nearestDuration = formatDuration(routeDurations[0]);
                nearestDistance = formatDistance(routeDistances[0]);
                nearestRoute = 1;
              } else {
                nearestDuration = formatDuration(routeDurations[1]);
                nearestDistance = formatDistance(routeDistances[1]);
                nearestRoute = 2;
              }
            }
          });
        } else {
          retryCount++; //retry
          setState(() {
            nearestDuration = 'Loading . . .';
            nearestDistance = '';
          });
          print('Failed to load routes');
        }
      } catch (e) {
        retryCount++; //retry
        print('Failed to load routes: ${e}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void resetSelection() {
    setState(() {
      //foundRoute = false;
      hideScreen = false;
      _currentLocation = null; // current location
      currentLocStreaming = false;
      startLocStreaming = false;
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
    setState(() {
      if (startPoint == null) {
        startPoint = point; // Set start point
        fetchStartPlaceName();
        if (startPoint != null && destinationPoint != null) {
          fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
        }
      } else if (destinationPoint == null) {
        destinationPoint = point; // Set destination point
        //fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
        fetchDestinationPlaceName();
        if (startPoint != null && destinationPoint != null) {
          fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
        }
      }

      // if (startPoint != null && destinationPoint != null) {
      //   fetchRoutes(startPoint!, destinationPoint!); // Fetch routes
      // }
    });
  }

  LatLng calculateMidpoint(LatLng a, LatLng b) {
    return LatLng(
        (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
  }

  Future<String?> getPlaceName(double lat, double lng) async {
    if (!currentLocStreaming && !startLocStreaming)
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

  //current live
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
        // open the location settings:
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
        distanceFilter: 3, // Update when the user moves 10 meters
      );
      //////real time current position
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          String? getCurrentName =
              await getPlaceName(position.latitude, position.longitude);
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
            selectedCurrentName = getCurrentName;

            // Move the map to the new location
            _mapController.move(_currentLocation!, _mapController.zoom);

            // // Fetch routes with the updated current location and static destination
            // if (destinationPoint != null) {
            //   fetchRoutes(_currentLocation!, destinationPoint!);
            // }
          });
          currentLocStreaming = true;
          print('Single Current Stream is now ON!');
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
      //  selectedCurrentName = getCurrentName;
      //   _mapController.move(
      //       _currentLocation!, 13.0); // Move to current location

      // });
    } catch (e) {
      print('fail to get current location!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //start live
  Future<void> _startCurrentLocation() async {
    try {
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

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Specify accuracy
        distanceFilter: 3,
      );
      //////real time current position
      _startPositionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          String? getCurrentName =
              await getPlaceName(position.latitude, position.longitude);
          setState(() {
            _startController.text = getCurrentName!;
            startPoint = LatLng(position.latitude, position.longitude);
            if (!startLocStreaming)
              _mapController.move(startPoint!, _mapController.zoom);

            startLocStreaming = true;
            if (destinationPoint != null) {
              fetchRoutes(startPoint!, destinationPoint!);
            }
          });
          print('Direction Current Stream is now ON!');
        },
        onError: (error) async {
          print('Error occurred in location stream: $error');
        },
      );
    } catch (e) {
      print('fail to get current location!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onhideScreen() {
    setState(() {
      if (hideScreen == true) {
        hideScreen = false;
      } else {
        hideScreen = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mapScreenKey,
      appBar: C_CustomAppBar(title: 'Map'),
      drawer: C_Drawer(),
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
              onTap: (tapPosition, point) => currentLocStreaming
                  ? null
                  : routes.isNotEmpty || routes.isNotEmpty
                      ? onhideScreen()
                      : isSelectingDirections
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
                        color:
                            i + 1 == nearestRoute ? Colors.blue : Colors.orange,
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
                              height: 200,
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
                                        route: i + 1, // Indexing the route
                                        nearestRoute:
                                            nearestRoute!, // Pass nearestRoute
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
          // if (isLoading)
          //   Center(
          //     child: CircularProgressIndicator(
          //       color: Colors.green,
          //       strokeWidth: 10,
          //       strokeAlign: 2,
          //       backgroundColor: Colors.deepPurple,
          //     ),
          //   ),

          //top layer
          isSelectingDirections && !hideScreen
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(15)),
                        boxShadow: shadowColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        (!startIsSearching && !destinationIsSearching) ||
                                startIsSearching ||
                                !destinationIsSearching
                            ? Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.green),
                                  SizedBox(width: 3),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1, color: Colors.grey)),
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
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.normal),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  startIsSearching
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              startIsSearching = false;
                                              _startFocusNode.unfocus();
                                            });
                                          },
                                          icon: Icon(Icons.close))
                                      : SizedBox(
                                          width: 10,
                                        ),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(height: 3),
                        (!startIsSearching && !destinationIsSearching) ||
                                destinationIsSearching ||
                                !startIsSearching
                            ? Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 3),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1, color: Colors.grey)),
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
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.normal),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  destinationIsSearching
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              destinationIsSearching = false;
                                              _destinationFocusNode.unfocus();
                                            });
                                          },
                                          icon: Icon(Icons.close))
                                      : SizedBox(
                                          width: 10,
                                        ),
                                ],
                              )
                            : SizedBox(),
                        (!startIsSearching && !destinationIsSearching) &&
                                _startController.text.isEmpty
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _startCurrentLocation();
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.my_location,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  title: Text('Your Location'),
                                ),
                              )
                            : SizedBox(),
                        startIsSearching
                            ? Column(
                                children: [
                                  _startFocusNode.hasFocus &&
                                          _startController.text.isEmpty &&
                                          !startLocStreaming
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _startFocusNode.unfocus();
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                _startCurrentLocation();
                                              },
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.my_location,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                title: Text('Your Location'),
                                              ),
                                            ),
                                            //Divider(height: 0,)
                                          ],
                                        )
                                      : SizedBox(),
                                  _startController.text.isEmpty || startfound
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        )
                                      : _foundPlaces.isEmpty &&
                                              _startController
                                                  .text.isNotEmpty &&
                                              !startfound
                                          ? Center(
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.location_on_outlined,
                                                  size: 20,
                                                ),
                                                title:
                                                    Text('No Location found'),
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
                                                        leading: Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 20,
                                                        ),
                                                        minLeadingWidth: .5,
                                                        title: Text(
                                                          place['name'],
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _foundPlaces = [];
                                                            startIsSearching =
                                                                false;
                                                            startfound = true;
                                                            _startController
                                                                    .text =
                                                                place['name'];
                                                            startPoint = LatLng(
                                                                double.parse(
                                                                    place[
                                                                        'lat']),
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
                                ],
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
                                            _destinationController
                                                .text.isNotEmpty &&
                                            !destinationfound
                                        ? Center(
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.location_on_outlined,
                                                size: 20,
                                              ),
                                              title: Text('No Location found'),
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
                                                      leading: Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 20,
                                                      ),
                                                      title: Text(
                                                        place['name'],
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          _foundPlaces = [];
                                                          destinationIsSearching =
                                                              false;
                                                          destinationfound =
                                                              true;
                                                          _destinationController
                                                                  .text =
                                                              place['name'];
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
          !hideScreen
              ? Positioned(
                  //bottom: 200,
                  bottom: MediaQuery.of(context).size.height * 0.2,
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
                                  isLoading = true;
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
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: shadowColor),
                          child: InkWell(
                            onTap: () {
                              if (!isLoading) {
                                if (isSelectingDirections) {
                                  resetSelection(); // Reset when closing direction selection
                                } else {
                                  resetSelection(); // Optional: reset for fresh start
                                  setState(() {
                                    isSelectingDirections =
                                        true; // Switch to directions mode
                                  });
                                }
                              }
                            },
                            child: Icon(
                              isSelectingDirections
                                  ? Icons.close
                                  : Icons.directions,
                              color: Colors.white,
                              size: 30,
                            ),
                          )),
                    ],
                  ),
                )
              : SizedBox(),
          if (isLoading)
            Positioned.fill(
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 10,
                    strokeAlign: 2,
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomSheet: selectedPoint != null && !isLoading
          ? Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Colors.white,
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
                              color: Colors.grey[700],
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
                    '${selectedPoint?.latitude.toStringAsFixed(8)}, ${selectedPoint?.longitude.toStringAsFixed(8)}',
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
          : nearestDuration != null && !isLoading && !hideScreen
              ? Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      boxShadow: shadowColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            '${nearestDuration} ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: nearestDistance == ''
                                    ? Colors.red
                                    : Colors.blue),
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
                          SizedBox(width: 10),
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
                          color: Colors.white,
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
                                      color: Colors.grey[700],
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
  final int route;
  final int nearestRoute; // Add nearestRoute to compare

  const RouteMarker({
    Key? key,
    required this.duration,
    required this.distance,
    required this.route,
    required this.nearestRoute, // Add nearestRoute
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if this is the fastest route and apply special styling
    final isFastestRoute = route == nearestRoute;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: isFastestRoute
                ? Colors.blue
                : Colors.white, // Highlight if fastest
            borderRadius: BorderRadius.circular(5),
            boxShadow: shadowColor,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 18,
                    color: isFastestRoute
                        ? Colors.white
                        : Colors.black, // Icon color change
                  ),
                  SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isFastestRoute
                          ? Colors.white
                          : Colors.black, // Text color change
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    distance,
                    style: TextStyle(
                      fontSize: 12,
                      color: isFastestRoute
                          ? Colors.white
                          : Colors.black, // Text color change
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(children: [
          Container(
            height: 50,
          ),
          Positioned(top: 0, bottom: 0, left: 25, child: 
          Image.asset(isFastestRoute? 'assets/pin_blue.png' :  'assets/pin_white.png'))
        ]),
        // Container(
        //   height: 50,
        //   child: Row(
        //     children: [
        //       Expanded(
        //         flex: 6,
        //         child: Container(),
        //       ),
        //       Expanded(
        //         flex: 1,
        //         child: Container(
        //           color: isFastestRoute
        //               ? Colors.blue
        //               : Colors.white, // Highlight if fastest
        //           // Set the width and height for the stick
        //           height: double.infinity, // Fills the parent height
        //         ),
        //       ),
        //       Expanded(
        //         flex: 6,
        //         child: SizedBox(),
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}

//CHECK LOCATION PERMISSION FROM OTHER CLASS
Future<bool> checkLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false; // Location services are not enabled
      }
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Optionally, open the location settings:
      await Geolocator.openLocationSettings();
      return false;
    }

    print('Location is on');
    return true;
  } catch (e) {
    print('fail to get location permission');
  }
  return false;
}
