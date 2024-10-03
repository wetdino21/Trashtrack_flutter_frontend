import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/styles.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class C_ScheduleCardList extends StatelessWidget {
  final int bookId;
  final String date; //September 15, 2024 (Mon);
  final String dateCreated; // Sept. 10, 2024
  final String wasteType; // food waste, municipal waste ...
  final String status;

  C_ScheduleCardList({
    required this.bookId,
    required this.date,
    required this.dateCreated,
    required this.wasteType,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => C_ScheduleDetails(bookId: bookId)));
      },
      splashColor: Colors.green,
      highlightColor: Colors.green.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(10),
        //color: boxColor,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   color: boxColor,
        // ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: shadowBigColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.deepPurpleAccent,
                  boxShadow: shadowColor
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Pickup Date',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                            status == 'Cancelled' || status == 'Collected'
                                ? Icons.history
                                : Icons.calendar_today,
                            size: status == 'Cancelled' || status == 'Collected'
                                ? 35
                                : 25,
                            color: Colors.white),
                        SizedBox(width: 10.0),
                        Text(
                          date,
                          style: TextStyle(color: Colors.white, fontSize: 23.0),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        wasteType,
                        style: TextStyle(color: Colors.white70, fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.send,
                        size: 15,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        dateCreated,
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ],
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: status == 'Pending'
                          ? Colors.orange
                          : status == 'Ongoing'
                              ? Colors.green
                              : status == 'Cancelled'
                                  ? Colors.red
                                  : Colors.blue,
                      fontSize: 18.0,
                      // shadows: [
                      //   Shadow(
                      //     blurRadius:
                      //         50.0, // How much blur you want for the glow
                      //     color: status == 'Pending'
                      //         ? Colors.orangeAccent
                      //         : status == 'Ongoing'
                      //             ? Colors.greenAccent
                      //             : status == 'Cancelled'
                      //                 ? Colors.pinkAccent
                      //                 : Colors
                      //                     .lightBlueAccent, // The glow color
                      //     offset: Offset(1, 1), // Position of the shadow
                      //   ),
                      //   Shadow(
                      //     blurRadius: 50.0, // Increase blur for a stronger glow
                      //     color: status == 'Pending'
                      //         ? Colors.orangeAccent
                      //         : status == 'Ongoing'
                      //             ? Colors.greenAccent
                      //             : status == 'Cancelled'
                      //                 ? Colors.pinkAccent
                      //                 : Colors.lightBlueAccent,
                      //     offset: Offset(0, 0),
                      //   ),
                      // ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class C_ScheduleDetails extends StatefulWidget {
  final int bookId;

  const C_ScheduleDetails({
    required this.bookId,
  });

  @override
  _C_ScheduleDetailsState createState() => _C_ScheduleDetailsState();
}

class _C_ScheduleDetailsState extends State<C_ScheduleDetails>
    with SingleTickerProviderStateMixin {
  // Controllers for the input fields
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  DateTime? _selectedDate;
  Map<String, dynamic>? userData;

  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  late Animation<Color?> _colorTweenCar;

  bool isLoading = true;

  String fullname = '';
  String contact = '';
  String address = '';
  String street = '';

  bool _acceptTerms = true;

  List<Map<String, dynamic>> _wasteTypes = [];
  List<Map<String, dynamic>> _selectedWasteTypes = [];
  //List<String> _selectedWasteTypes = [];

  final MapController _mapController = MapController();
  LatLng? selectedPoint;
  String? selectedPlaceName;
  bool failGetPlaceName = false;
  bool isLoadingLoc = false;
  bool onMap = false;

  String userDataValidator = '';
  String pinLocValidator = '';
  String wasteCatValidator = '';
  String dateValidator = '';

  Map<String, dynamic>? bookingData;
  List<Map<String, dynamic>>? bookingWasteList;

  bool _isEditing = false;
  Color? boxColorTheme = Colors.teal;
  bool _showOptionsBox = false;

  @override
  void initState() {
    super.initState();

    _dbData();
    _loadWasteCategories();
    _fetchBookingData();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(_controller);

    _colorTweenCar = ColorTween(
      begin: Colors.green,
      end: Colors.transparent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    // implement dispose
    TickerCanceled;
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();

    _controller.dispose();

    // _dbData();
    // _loadWasteCategories();
    super.dispose();
  }

// Fetch booking from the server
  Future<void> _fetchBookingData() async {
    try {
      final data = await fetchBookingData(context);
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          final bookingListdb = data['booking'];
          final bookingWasteListdb = data['wasteTypes'];

          if (bookingListdb != null)
            bookingData = bookingListdb
                .firstWhere((booking) => booking['bk_id'] == widget.bookId);
          if (bookingWasteListdb != null) {
            bookingWasteList = bookingWasteListdb
                .where((waste) => waste['bk_id'] == widget.bookId)
                .toList();
            // Initialize _selectedWasteTypes with the bookingWasteList
            _selectedWasteTypes = List<Map<String, dynamic>>.from(
                bookingWasteList!.map((waste) => {
                      'name': waste['bw_name'],
                      'price': waste['bw_price'],
                      'unit': waste['bw_unit'],
                    }));
          }

          if (bookingData != null) {
            if (bookingData!['bk_status'] == 'Ongoing') {
              boxColorTheme = Colors.deepPurple;
            }
            street = (bookingData!['bk_street'] ?? '');
            address = (bookingData!['bk_brgy'] ?? '') +
                ', ' +
                (bookingData!['bk_city'] ?? '') +
                ', ' +
                (bookingData!['bk_province'] ?? '') +
                ', ' +
                (bookingData!['bk_postal'] ?? '');
            // selectedPoint = LatLng(bookingData!['bk_latitude'] as double,
            //     bookingData!['bk_longitude'] as double);
            double latitude = bookingData!['bk_latitude'];
            double longitude = bookingData!['bk_longitude'];
            _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
            selectedPoint = LatLng(latitude, longitude);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
              _mapController.move(selectedPoint!, 13.0);
            });
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      print('ERROR: ${e}');
      // setState(() {
      //   isLoading = true;
      // });
    }
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      //final data = await userDataFromHive();
      final data = await fetchCusData(context);
      if (!mounted) return;
      setState(() {
        userData = data;

        fullname = (userData!['cus_fname'] ?? '') +
            ' ' +
            (userData!['cus_mname'] ?? '') +
            ' ' +
            (userData!['cus_lname'] ?? '');
        contact = userData!['cus_contact'].substring(1) ?? '';
        // street = (userData!['cus_street'] ?? '');
        // address = (userData!['cus_brgy'] ?? '') +
        //     ', ' +
        //     (userData!['cus_city'] ?? '') +
        //     ', ' +
        //     (userData!['cus_province'] ?? '') +
        //     ', ' +
        //     (userData!['cus_postal'] ?? '');
        //isLoading = false;
      });
      //await data.close();
    } catch (e) {
      if (!mounted) return;
      isLoading = true;
      print(e);
      setState(() {
        //errorMessage = e.toString();
        isLoading = true;
      });
    }
  }

  // Function to load waste categories and update the state
  Future<void> _loadWasteCategories() async {
    try {
      List<Map<String, dynamic>>? categories = await fetchWasteCategory();
      if (!mounted) return;
      if (categories != null) {
        setState(() {
          _wasteTypes = categories;
          // isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load waste categories')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print(e);
      setState(() {
        //errorMessage = e.toString();
        isLoading = true;
      });
    }
  }

  void handleOnePoint(LatLng point) {
    setState(() {
      selectedPoint = point;
      //_mapController.move(selectedPoint!, 16);
      //fetchSelectedPlaceNames();
    });
  }

  //LOCATION PERMISSION
  Future<void> _getCurrentLocation() async {
    try {
      // setState(() {
      //   isLoadingLoc = true;
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

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, // Specify accuracy
      );

      ///current pstion
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      // String? getCurrentName =
      //     await getPlaceName(position.latitude, position.longitude);

      setState(() {
        selectedPoint = LatLng(position.latitude, position.longitude);
        _mapController.move(selectedPoint!, 13.0); // Move to current location

        // selectedPlaceName = getCurrentName;
      });
    } catch (e) {
      print('fail to get current location!');
    } finally {
      setState(() {
        isLoadingLoc = false;
      });
    }
  }

////
  void _confirmUpdateBooking() {
    // check if nothing change
    bool isWasteEqual = const DeepCollectionEquality().equals(
      _selectedWasteTypes,
      List<Map<String, dynamic>>.from(bookingWasteList!.map(
        (waste) => {
          'name': waste['bw_name'],
          'price': waste['bw_price'],
          'unit': waste['bw_unit'],
        },
      )),
    );
    if (selectedPoint ==
            LatLng(bookingData!['bk_latitude'] as double,
                bookingData!['bk_longitude'] as double) &&
        _selectedDate == DateTime.parse(bookingData!['bk_date']).toLocal() &&
        isWasteEqual == true) {
      showSuccessSnackBar(context, 'No Update Changes');
      setState(() {
        _isEditing = false;
        boxColorTheme = Colors.teal;
      });
    } else {
      _showConfirmUpdateBookingDialog(context);
    }
  }

////
  void _showConfirmUpdateBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Save Changes', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to update booking details?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (bookingData != null) {
                  String? dbMessage = await bookingUpdate(
                      context,
                      bookingData!['bk_id'],
                      _selectedDate!,
                      userData!['cus_province'],
                      userData!['cus_city'],
                      userData!['cus_brgy'],
                      userData!['cus_street'],
                      userData!['cus_postal'],
                      selectedPoint!.latitude,
                      selectedPoint!.longitude,
                      _selectedWasteTypes);
                  if (dbMessage == 'success')
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => C_ScheduleScreen()));
                  else
                    showErrorSnackBar(
                        context, 'Somthing\'s wrong. Please try again later.');
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

////
  void _confirmDiscardUpdateBooking() {
    // check if nothing change
    bool isWasteEqual = const DeepCollectionEquality().equals(
      _selectedWasteTypes,
      List<Map<String, dynamic>>.from(bookingWasteList!.map(
        (waste) => {
          'name': waste['bw_name'],
          'price': waste['bw_price'],
          'unit': waste['bw_unit'],
        },
      )),
    );

    if (!_isEditing) {
      Navigator.of(context).pop();
    } else if (selectedPoint ==
            LatLng(bookingData!['bk_latitude'] as double,
                bookingData!['bk_longitude'] as double) &&
        _selectedDate == DateTime.parse(bookingData!['bk_date']).toLocal() &&
        isWasteEqual == true) {
      setState(() {
        _isEditing = false;
        boxColorTheme = Colors.teal;
      });
    } else {
      _showConfirmDiscardUpdateBookingDialog(context);
    }
  }

////
  void _showConfirmDiscardUpdateBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Discard Changes', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to discard any changes?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await _fetchBookingData();
                setState(() {
                  _selectedDate =
                      DateTime.parse(bookingData!['bk_date']).toLocal();
                  _isEditing = false;
                  boxColorTheme = Colors.teal;
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

////
  void _showConfirmCancelBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Cancel Booking', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to Cancel this booking?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                if (bookingData != null) {
                  String? dbMessage =
                      await bookingCancel(context, bookingData!['bk_id']);
                  if (dbMessage == 'success')
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => C_ScheduleScreen()));
                  else
                    showErrorSnackBar(
                        context, 'Somthing\'s wrong. Please try again later.');
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

//////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: Column(
        children: [
          Expanded(child: _buildFirstStep()),
        ],
      ),
    );
  }

  Widget _buildFirstStep() {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Editing Booking Details' : 'Booking Details'),
        // Declare a boolean variable to track the visibility of the options box

        actions: [
          if (bookingData != null)
            bookingData!['bk_status'] == 'Pending' && !_isEditing
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          boxColorTheme = Colors.deepPurple;
                        });
                      },
                      icon: Icon(Icons.edit_outlined),
                    ),
                  )
                : SizedBox(),
          SizedBox(width: 5),
          if (bookingData != null)
            if (bookingData!['bk_status'] == 'Pending')
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      // Toggle the visibility of the options box
                      _showOptionsBox = !_showOptionsBox;
                    });
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ),

          //go to map
          if (bookingData != null)
            bookingData!['bk_status'] == 'Ongoing'
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return TextButton(
                        onPressed: () async {
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => C_MapScreen()));
                          bool onLocation = await checkLocationPermission();
                          if (onLocation)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => C_MapScreen(
                                        pickupPoint: LatLng(
                                            10.25702151, 123.85040322))));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: _colorTweenCar.value,
                          ),
                          child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.drive_eta,
                                color: Colors.black,
                                size: 30,
                              )),
                        ),
                      );
                    })
                : SizedBox(
                    height: 30,
                  ),
          SizedBox(width: 5),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchBookingData();
          await _dbData();
          await _loadWasteCategories();

          if (bookingData != null &&
              bookingWasteList != null &&
              userData != null &&
              _wasteTypes.isNotEmpty) {
            isLoading = false;
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              //padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  PopScope(
                      canPop: false,
                      onPopInvokedWithResult: (didPop, result) async {
                        if (didPop) {
                          return;
                        }
                        _confirmDiscardUpdateBooking();
                      },
                      child: Container()),

                  // //go to map
                  // if (bookingData != null)
                  //   bookingData!['bk_status'] == 'Ongoing'
                  //       ? AnimatedBuilder(
                  //           animation: _controller,
                  //           builder: (context, child) {
                  //             return TextButton(
                  //               onPressed: () {},
                  //               child: Container(
                  //                 padding: EdgeInsets.all(10),
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(50),
                  //                   color: _colorTweenCar.value,
                  //                 ),
                  //                 child: Container(
                  //                     padding: EdgeInsets.all(5),
                  //                     decoration: BoxDecoration(
                  //                       borderRadius: BorderRadius.circular(50),
                  //                       color: Colors.white,
                  //                     ),
                  //                     child: Icon(
                  //                       Icons.drive_eta,
                  //                       color: Colors.black,
                  //                       size: 30,
                  //                     )),
                  //               ),
                  //             );
                  //           })
                  //       : SizedBox(
                  //           height: 30,
                  //         ),

                  isLoading
                      ? AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    //color: Colors.white.withOpacity(.6),
                                    color: _colorTween.value,
                                  ),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                //color: Colors.white.withOpacity(.6),
                                                color: _colorTween2.value,
                                              ),
                                            ),
                                          )),
                                      Expanded(
                                          flex: 10,
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          width: 100,
                                                          margin:
                                                              EdgeInsets.all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            //color: Colors.white.withOpacity(.6),
                                                            color: _colorTween2
                                                                .value,
                                                          ),
                                                          child: Text(''))),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                          width: 250,
                                                          margin:
                                                              EdgeInsets.all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            //color: Colors.white.withOpacity(.6),
                                                            color: _colorTween2
                                                                .value,
                                                          ),
                                                          child: Text(''))),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          width: 150,
                                                          margin:
                                                              EdgeInsets.all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            //color: Colors.white.withOpacity(.6),
                                                            color: _colorTween2
                                                                .value,
                                                          ),
                                                          child: Text(''))),
                                                ],
                                              ))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 30,
                                  width: 300,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    //color: Colors.white.withOpacity(.6),
                                    color: _colorTween2.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _colorTween2.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 30,
                                  width: 300,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    //color: Colors.white.withOpacity(.6),
                                    color: _colorTween.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _colorTween.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 30,
                                  width: 300,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    //color: Colors.white.withOpacity(.6),
                                    color: _colorTween2.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _colorTween2.value,
                                  ),
                                ),
                              ],
                            );
                          })

                      // onload dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
                      : Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: shadowBigColor),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color:
                                          bookingData!['bk_status'] == 'Pending'
                                              ? Colors.orange
                                              : bookingData!['bk_status'] ==
                                                      'Ongoing'
                                                  ? Colors.green
                                                  : bookingData!['bk_status'] ==
                                                          'Cancelled'
                                                      ? Colors.red
                                                      : Colors.blue,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          bookingData == null
                                              ? 'Loading ...'
                                              : bookingData!['bk_status'] ==
                                                          'Pending' ||
                                                      bookingData![
                                                              'bk_status'] ==
                                                          'Ongoing'
                                                  ? 'Your Request Pickup is ${bookingData!['bk_status']}'
                                                  : 'Your Request Pickup was ${bookingData!['bk_status']}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        bookingData!['bk_status'] == 'Ongoing'
                                            ? Text(
                                                'Today is your waste collection day!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : SizedBox()
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      //color: Colors.grey[200],
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10)),
                                    ),
                                    child: Container(
                                      height: 100,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          //color: Colors.white.withOpacity(.6),
                                          color: Colors.white,
                                          boxShadow: shadowColor),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                  height: 35,
                                                  width: 30,
                                                  padding:
                                                      EdgeInsets.only(left: 2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    //color: Colors.white.withOpacity(.6),
                                                    color: Colors.grey[300],
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Icon(
                                                    Icons.pin_drop,
                                                    size: 30,
                                                    color: Colors.redAccent,
                                                  ))),
                                          Expanded(
                                              flex: 10,
                                              child: Container(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                          flex: 1,
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                fullname,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                              Text(
                                                                  '   | +(63)${contact}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  )),
                                                            ],
                                                          )),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${street} \n${address}',
                                                          )),
                                                      Expanded(
                                                          flex: 1,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  //color: Colors.white.withOpacity(.6),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                                child: Text(
                                                                  'Default',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                              .red[
                                                                          300]),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  //color: Colors.white.withOpacity(.6),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                child: Text(
                                                                  'Pickup Address',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54),
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                    ],
                                                  ))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _labelValidator(userDataValidator),
                            SizedBox(height: 5.0),

                            //MAPPPPPPPPPPPPPP
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                  boxShadow: shadowBigColor),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Pin Location',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey[200],
                                            boxShadow: shadowColor),
                                        height: onMap ? 500 : 100,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: FlutterMap(
                                            mapController: _mapController,
                                            options: MapOptions(
                                                center: LatLng(10.29411,
                                                    123.902453), // Example: Cebu City
                                                zoom: 13.0,
                                                //maxZoom: 19,
                                                maxZoom:
                                                    19, // Maximum zoom in level
                                                minZoom:
                                                    5, // Minimum zoom out level
                                                onTap: (tapPosition, point) =>
                                                    handleOnePoint(point),
                                                enableScrollWheel: true),
                                            children: [
                                              TileLayer(
                                                urlTemplate:
                                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                subdomains: ['a', 'b', 'c'],
                                                maxZoom:
                                                    19, // Maximum zoom in level
                                                minZoom:
                                                    5, // Minimum zoom out level
                                              ),
                                              if (selectedPoint != null) ...[
                                                MarkerLayer(
                                                  markers: [
                                                    Marker(
                                                        width: 80.0,
                                                        height: 80.0,
                                                        point: selectedPoint!,
                                                        builder: (ctx) => Icon(
                                                            Icons.location_pin,
                                                            color: Colors.red,
                                                            size: 40),
                                                        rotate: true),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),

                                      //2 btns
                                      if (onMap)
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 25),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.green,
                                                    boxShadow: shadowColor),
                                                child: InkWell(
                                                  onTap: () {
                                                    onMap = false;
                                                    setState(() {
                                                      if (selectedPoint != null)
                                                        _mapController.move(
                                                            selectedPoint!, 13);
                                                      onMap = false;
                                                      pinLocValidator = '';
                                                    });
                                                  },
                                                  child: Text(
                                                    'SAVE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),

                                              //current loc
                                              Container(
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.white,
                                                    boxShadow: shadowColor),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoadingLoc = true;
                                                    });
                                                    _getCurrentLocation();
                                                  },
                                                  child: Icon(
                                                    Icons.my_location,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!onMap)
                                        Positioned.fill(
                                            child: Container(
                                          color: const Color.fromARGB(
                                              0, 163, 145, 145),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                onMap = true;
                                              });
                                              if (selectedPoint == null)
                                                _getCurrentLocation();
                                            },
                                          ),
                                        )),

                                      isLoadingLoc
                                          ? Positioned.fill(
                                              child: InkWell(
                                                onTap: () {},
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.green,
                                                    strokeWidth: 10,
                                                    strokeAlign: 2,
                                                    backgroundColor:
                                                        boxColorTheme,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _labelValidator(pinLocValidator),
                            SizedBox(height: 5.0),
                            _buildDatePicker('Date Schedule', 'Select Date'),
                            _labelValidator(dateValidator),
                            SizedBox(height: 5.0),
                            isLoading
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey[200],
                                        boxShadow: shadowBigColor),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Waste Type',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: shadowColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: _wasteCategoryList(),
                                        ),
                                      ],
                                    ),
                                  ),
                            _labelValidator(wasteCatValidator),

                            SizedBox(height: 5.0),
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                  boxShadow: shadowBigColor),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: shadowColor),
                                child: Column(
                                  children: [
                                    Center(
                                        child: Text(
                                      'Payment Method',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    Image.asset('assets/paymongo.png'),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/visa.png',
                                                    scale: 2,
                                                  ))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/gcash.png',
                                                    scale: 2,
                                                  ))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/paymaya.png',
                                                    scale: 2,
                                                  ))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/grabpay.png',
                                                    scale: 2,
                                                  ))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Image.asset(
                                                    'assets/methods.png',
                                                    scale: 2,
                                                  ))),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            _isEditing
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            side:
                                                BorderSide(color: Colors.white),
                                            value: _acceptTerms,
                                            activeColor: Colors.green,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                _acceptTerms =
                                                    newValue ?? false;
                                              });
                                            },
                                          ),
                                          Text(
                                            'I accept the ',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, 'terms');
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Text(
                                              'terms and conditions.',
                                              style: TextStyle(
                                                color: Colors.green,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.green,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shadowColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0), // Adjust the radius here
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 12.0),
                                                backgroundColor: Colors.blue),
                                            onPressed: () async {
                                              _confirmDiscardUpdateBooking();
                                              // await _fetchBookingData();
                                              // setState(() {
                                              //   _selectedDate = DateTime.parse(
                                              //           bookingData!['bk_date'])
                                              //       .toLocal();
                                              //   _isEditing = false;
                                              //   boxColorTheme = Colors.teal;
                                              // });
                                            },
                                            child: Text(
                                              'DISCARD',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shadowColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0), // Adjust the radius here
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30.0,
                                                    vertical: 12.0),
                                                backgroundColor: Colors.green),
                                            onPressed: () async {
                                              if (userData == null ||
                                                  selectedPoint == null ||
                                                  _selectedWasteTypes.isEmpty ||
                                                  _selectedDate == null) {
                                                setState(() {
                                                  userDataValidator =
                                                      _validateUserData(
                                                          userData);
                                                  pinLocValidator =
                                                      _validatePinLocl(
                                                          selectedPoint);
                                                  wasteCatValidator =
                                                      _validateWaste(
                                                          _selectedWasteTypes);
                                                  dateValidator = _validateDate(
                                                      _selectedDate);
                                                });
                                              } else if (!_acceptTerms) {
                                                showErrorSnackBar(context,
                                                    'Accept the terms and condition');
                                              } else {
                                                _confirmUpdateBooking();
                                              }
                                            },
                                            child: Text(
                                              'SAVE',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 50),
                                    ],
                                  )
                                : SizedBox(),
                          ],
                        )
                ],
              ),
            ),
            _isEditing == false
                ? Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        // Optionally
                      },
                    ),
                  )
                : SizedBox(),

            //more cancellation
            if (_showOptionsBox)
              Positioned.fill(
                child: GestureDetector(
                  onVerticalDragDown: (details) {
                    setState(() {
                      _showOptionsBox = false;
                    });
                  },
                ),
              ),

            if (_showOptionsBox)
              Positioned(
                top: AppBar().preferredSize.height -
                    50, // Adjust this value as needed
                right: 10, // Adjust to align with the IconButton
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 20,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          _showConfirmCancelBookingDialog(context);
                          setState(() {
                            _showOptionsBox = false;
                          });
                        },
                        child: Container(
                            child: Text("Cancel Booking?",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54))),
                      ),
                      Icon(
                        Icons.sentiment_very_dissatisfied,
                        size: 50,
                        color: Colors.red,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Validator All
  _labelValidator(String showValidator) {
    return showValidator != ''
        ? Text(
            showValidator,
            style: TextStyle(color: Colors.redAccent[100]),
          )
        : SizedBox();
  }

  String _validateUserData(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) {
      return 'User Data is Loading . . .';
    }
    return '';
  }

  String _validatePinLocl(LatLng? value) {
    if (value == null) {
      return 'Please provide pin location!';
    }

    return '';
  }

  String _validateWaste(List<Map<String, dynamic>> value) {
    if (value.isEmpty) {
      return 'Please select atleast one waste type!';
    }
    return '';
  }

  String _validateDate(DateTime? value) {
    if (value == null) {
      return 'Please select date schedule!';
    }

    return '';
  }

  Widget _wasteCategoryList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(), // Stop scrolling
      shrinkWrap: true, // Use shrinkWrap to make the list fit its content.
      children: _isEditing
          ? _wasteTypes.map((Map<String, dynamic> category) {
              String type = category['name'];
              var price = category['price'];
              var unit = category['unit'];

              // Check if the waste type is selected by comparing the name
              bool isSelected = _selectedWasteTypes
                  .any((selectedCategory) => selectedCategory['name'] == type);

              return CheckboxListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${type}'),
                    Text(
                      '\₱${price.toString()}\\${unit.toString()}',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ],
                ),
                value: isSelected,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      // Add the entire waste type object
                      _selectedWasteTypes.add({
                        'name': type,
                        'price': price,
                        'unit': unit,
                      });
                    } else {
                      // Remove the waste type object
                      _selectedWasteTypes.removeWhere((selectedCategory) =>
                          selectedCategory['name'] == type);
                    }

                    // Validator
                    if (_selectedWasteTypes.isEmpty) {
                      wasteCatValidator = _validateWaste(_selectedWasteTypes);
                    } else {
                      wasteCatValidator = '';
                    }
                  });
                },
                activeColor:
                    Colors.blue, // Color of the checkbox when selected.
                checkColor: Colors.white, // Color of the checkmark.
              );
            }).toList()
          : _selectedWasteTypes.map((Map<String, dynamic> category) {
              String type = category['name'];
              var price = category['price'];
              var unit = category['unit'];

              return Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${type}'),
                    Text(
                      '\₱${price.toString()}\\${unit.toString()}',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }

//date picker
  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
            boxShadow: shadowBigColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: shadowColor),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green),
                  SizedBox(width: 10.0),
                  Text(
                    _selectedDate == null
                        ? hint
                        // : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        : DateFormat('MMM d, yyyy (EEEE)')
                            .format(_selectedDate!), // Format: Mon 1, 2024
                    style: TextStyle(
                        color: _selectedDate == null ? Colors.grey : null,
                        //fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  SizedBox(width: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year);
    final DateTime lastDate = DateTime(now.year + 1, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate, // Use the current year + 1
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, // Circle color for the selected date
              onPrimary: Colors.white, // Text color inside the circle
              onSurface: Colors.green[900]!, // Text color for dates
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        if (_selectedDate != null) {
          dateValidator = '';
        }
      });
    }
  }
}

// Widget _buildDropDownList() {
//   return DropdownButtonFormField<String>(
//     value: _selectedWasteType,
//     dropdownColor: Colors.white,
//     decoration: InputDecoration(
//       contentPadding: EdgeInsets.symmetric(horizontal: 0),
//       //labelText: 'Select Waste Type',
//       labelStyle: TextStyle(color: accentColor),
//       hintText: 'Select Waste Type',
//       hintStyle: TextStyle(color: Colors.grey),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.0),
//         borderSide: BorderSide.none,
//       ),
//     ),
//     items: _wasteTypes.map((String value) {
//       return DropdownMenuItem<String>(
//         value: value,
//         child: Text(
//           value,
//         ),
//       );
//     }).toList(),
//     onChanged: (newValue) {
//       setState(() {
//         _selectedWasteType = newValue;
//       });
//     },
//   );
// }

///////////////////////////////////
// Widget _buildTextboxField(
//     TextEditingController controller, String label, String hint) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(color: Colors.white, fontSize: 16),
//         ),
//         SizedBox(height: 5),
//         TextFormField(
//           controller: controller,
//           //style: TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(horizontal: 15),
//             filled: true,
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class C_PickUpSchedule extends StatefulWidget {
//   @override
//   _C_PickUpScheduleState createState() => _C_PickUpScheduleState();
// }

// class _C_PickUpScheduleState extends State<C_PickUpSchedule> {
//   int selectedPage = 0;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: selectedPage);
//   }

//   void onPageSelected(int pageIndex) {
//     setState(() {
//       selectedPage = pageIndex;
//     });
//     _pageController.jumpToPage(pageIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         foregroundColor: Colors.white,
//         title: Text('Schedule'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 20.0),
//           Center(
//             child: Text(
//               'List Of Pickup Schedules',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 18.0,
//               ),
//             ),
//           ),
//           SizedBox(height: 20.0),
//           Container(
//             padding: EdgeInsets.all(5.0),
//             decoration: BoxDecoration(
//               color: Color(0xFF103510),
//               borderRadius: BorderRadius.circular(30.0),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   child: ElevatedButton(
//                     onPressed: () => onPageSelected(0),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           selectedPage == 0 ? buttonColor : Color(0xFF001E00),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                     ),
//                     child: Text(
//                       'All',
//                       style: TextStyle(
//                         color:
//                             selectedPage == 0 ? Colors.white : Colors.white70,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => onPageSelected(1),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           selectedPage == 1 ? buttonColor : Color(0xFF001E00),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                     ),
//                     child: Text(
//                       'Contractual',
//                       style: TextStyle(
//                         color:
//                             selectedPage == 1 ? Colors.white : Colors.white70,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => onPageSelected(2),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           selectedPage == 2 ? buttonColor : Color(0xFF001E00),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                     ),
//                     child: Text(
//                       'Non-Contractual',
//                       style: TextStyle(
//                         color:
//                             selectedPage == 2 ? Colors.white : Colors.white70,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20.0),
//           Container(
//             //height: MediaQuery.of(context).size.height * .6,
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             child: PageView(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   selectedPage = index;
//                 });
//               },
//               children: [
//                 // All Waste Collection Cards
//                 // ListView(
//                 //   shrinkWrap: true,
//                 //   children: [
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Mon Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Municipal Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Wed Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Construction Waste',
//                 //       status: 'Complete',
//                 //     ),
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Fri Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Food Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Fri Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Construction Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //   ],
//                 // ),
//                 // // Contractual Waste Collection Cards
//                 // ListView(
//                 //   shrinkWrap: true,
//                 //   children: [
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Mon Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Municipal Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Wed Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Construction Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //   ],
//                 // ),
//                 // // Non-Contractual Waste Collection Cards
//                 // ListView(
//                 //   shrinkWrap: true,
//                 //   children: [
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Fri Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Food Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //     C_CurrentScheduleCard(
//                 //       dateCreated: 'Fri Jun 20',
//                 //       time: '8:30 AM',
//                 //       wasteType: 'Construction Waste',
//                 //       status: 'Pending',
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
