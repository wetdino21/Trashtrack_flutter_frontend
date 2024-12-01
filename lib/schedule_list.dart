import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/Customer/booking.dart';
import 'package:trashtrack/map.dart';
import 'package:trashtrack/API/api_address.dart';
import 'package:trashtrack/Hauler/booking_pickup_list.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/styles.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/API/api_user_data.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trashtrack/user_hive_data.dart';
import 'package:trashtrack/validator_data.dart';
import 'package:trashtrack/waste_pricing_info.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class C_ScheduleCardList extends StatefulWidget {
  final int bookId;
  final String date; //September 15, 2024 (Mon);
  final String dateCreated; // Sept. 10, 2024
  final String wasteType; // food waste, municipal waste ...
  final String status;
  final bool? today;
  final bool? priority;

  C_ScheduleCardList({
    required this.bookId,
    required this.date,
    required this.dateCreated,
    required this.wasteType,
    required this.status,
    this.today,
    this.priority,
  });

  @override
  State<C_ScheduleCardList> createState() => _C_ScheduleCardListState();
}

class _C_ScheduleCardListState extends State<C_ScheduleCardList> {
  String? user;

  @override
  void initState() {
    super.initState();
    _dbData();
  }

  // Fetch user data from the server
  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      if (!mounted) return null;
      setState(() {
        user = data['user'];
      });
    } catch (e) {
      console(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        if (user == 'customer') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetails(bookId: widget.bookId)))
              .then((onValue) {
            if (onValue == true) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
            }
          });
        } else if (user == 'hauler') {
          if (widget.today != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Booking_Pending_Details(bookId: widget.bookId, today: widget.today!)));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Booking_Pending_Details(bookId: widget.bookId)));
          }
        }
      },
      splashColor: deepPurple,
      highlightColor: deepPurple,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        //color: boxColor,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   color: boxColor,
        // ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), boxShadow: shadowMidColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'BOOKING# ${widget.bookId}',
                      style: TextStyle(color: blackSoft, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  if (widget.priority == true)
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Icon(Icons.loyalty, color: red),
                          Text(
                            'Priority',
                            style: TextStyle(color: red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(7), color: deepPurple, boxShadow: shadowColor),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            widget.status == 'Cancelled' || widget.status == 'Paid' || widget.status == 'Failed'
                                ? Icons.history
                                : Icons.calendar_month,
                            size: widget.status == 'Cancelled' || widget.status == 'Paid' || widget.status == 'Failed'
                                ? 35
                                : 25,
                            color: Colors.white),
                        Text(
                          widget.date,
                          style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.wasteType,
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
                        widget.dateCreated,
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ],
                  ),
                  Text(
                    widget.status,
                    style: TextStyle(
                        color: widget.status == 'Pending'
                            ? Colors.orange
                            : widget.status == 'Ongoing'
                                ? Colors.green
                                : widget.status == 'Cancelled'
                                    ? Colors.red
                                    : widget.status == 'Failed'
                                        ? Colors.pink
                                        : Colors.blue,
                        fontSize: 18.0,
                        //shadows: shadowTextColor,
                        fontWeight: FontWeight.bold
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

class BookingDetails extends StatefulWidget {
  final int bookId;

  const BookingDetails({
    required this.bookId,
  });

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> with SingleTickerProviderStateMixin {
  // Controllers for the input fields
  final _fullnameController = TextEditingController();
  final _contactController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalController = TextEditingController();

  DateTime? _selectedDate;
  Map<String, dynamic>? userData;

  bool _showProvinceDropdown = false;
  bool _showCityMunicipalityDropdown = false;
  bool _showBarangayDropdown = false;

  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvinceName;
  String? _selectedCityMunicipalityName;
  String? _selectedBarangayName;

  String fullnamevalidator = '';
  String contactvalidator = '';
  String provincevalidator = '';
  String cityvalidator = '';
  String brgyvalidator = '';
  String streetvalidator = '';
  String postalvalidator = '';

  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  late Animation<Color?> _colorTweenCar;

  bool isLoading = true;
  bool loadingAction = false;

  String fullname = '';
  String contact = '';
  String address = '';
  String street = '';
  String postal = '';

  bool _acceptTerms = true;

  //limit
  Map<String, dynamic> _bookLimit = {};
  List<Map<String, dynamic>> _dayLimit = [];
  List<Map<String, dynamic>> _wasteLimit = [];

  List<Map<String, dynamic>> _wasteTypes = [];
  List<Map<String, dynamic>> _selectedWasteTypes = [];
  //List<String> _selectedWasteTypes = [];

  final MapController _mapController = MapController();
  LatLng? selectedPoint;
  String? selectedPlaceName;
  bool failGetPlaceName = false;
  bool isLoadingLoc = false;
  bool onMap = false;
  bool onAddress = false;

  String pinLocValidator = '';
  String wasteCatValidator = '';
  String dateValidator = '';

  Map<String, dynamic>? bookingData;
  List<Map<String, dynamic>>? bookingWasteList;

  bool _isEditing = false;
  Color? boxColorTheme = Colors.teal;
  bool _showOptionsBox = false;
  List<dynamic> _locations = [];
  Uint8List? dbSlipImage;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _dbData();
    _loadWasteCategories();

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
    _fullnameController.dispose();
    _contactController.dispose();
    _streetController.dispose();
    _postalController.dispose();

    _controller.dispose();

    // _dbData();
    // _loadWasteCategories();
    super.dispose();
  }

// Fetch booking from the server
  Future<void> _fetchBookingData() async {
    try {
      //final data = await fetchBookingData(context);
      final data = await fetchBookingDetails(context, widget.bookId);
      //
      final bkLimitData = await fetchBookLimit();
      final bkDayLimitData = await fetchDayLimit();

      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          final bookingListdb = data['booking'];
          final bookingWasteListdb = data['wasteTypes'];

          if (bookingListdb != null) {
            bookingData = Map<String, dynamic>.from(bookingListdb[0]);
            // bookingData = bookingListdb
            //   .firstWhere((booking) => booking['bk_id'] == widget.bookId);
          }

          if (bookingWasteListdb != null) {
            bookingWasteList = List<Map<String, dynamic>>.from(bookingWasteListdb);
            // bookingWasteList = bookingWasteListdb
            //     .where((waste) => waste['bk_id'] == widget.bookId)
            //     .toList();
            // Initialize _selectedWasteTypes with the bookingWasteList
            _selectedWasteTypes = List<Map<String, dynamic>>.from(bookingWasteList!.map((waste) => {
                  'name': waste['bw_name'],
                  'price': waste['bw_price'],
                  'unit': waste['bw_unit'],
                  'total_unit': waste['bw_total_unit'],
                }));
          }

          if (bookingData != null) {
            if (bookingData!['bk_status'] == 'Ongoing') {
              boxColorTheme = Colors.deepPurple;
            }
            //store from booking
            _fullnameController.text = (bookingData!['bk_fullname'] ?? '');
            _contactController.text = bookingData!['bk_contact'].substring(1) ?? '';
            _selectedProvinceName = bookingData!['bk_province'] ?? '';
            _selectedCityMunicipalityName = bookingData!['bk_city'] ?? '';
            _selectedBarangayName = bookingData!['bk_brgy'] ?? '';
            _streetController.text = (bookingData!['bk_street'] ?? '');
            _postalController.text = (bookingData!['bk_postal'] ?? '');

            fullname = (bookingData!['bk_fullname'] ?? '');
            contact = bookingData!['bk_contact'].substring(1) ?? '';
            address = (bookingData!['bk_brgy'] ?? '') +
                ', ' +
                (bookingData!['bk_city'] ?? '') +
                ', ' +
                (bookingData!['bk_province'] ?? '');
            street = (bookingData!['bk_street'] ?? '');
            postal = (bookingData!['bk_postal'] ?? '');
            // selectedPoint = LatLng(bookingData!['bk_latitude'] as double,
            //     bookingData!['bk_longitude'] as double);
            double latitude = bookingData!['bk_latitude'];
            double longitude = bookingData!['bk_longitude'];
            _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
            selectedPoint = LatLng(latitude, longitude);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
              _mapController.move(selectedPoint!, 13);
              _mapController.rotate(0.0);
            });

            if (bookingData!['bk_waste_scale_slip'] != null) {
              dbSlipImage = base64Decode(bookingData!['bk_waste_scale_slip']);
            }
          }

          //load book limit
          if (bkLimitData != null) {
            _bookLimit = bkLimitData;
          } else {
            console('Failed to load booking limit');
          }

          //load day limit
          if (bkDayLimitData != null) {
            _dayLimit = bkDayLimitData;
          } else {
            console('Failed to load day limit');
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

  // day limit
  Future<void> loadDayLimit() async {
    final bkDayLimitData = await fetchDayLimit();
    //load day limit
    if (bkDayLimitData != null) {
      _dayLimit = bkDayLimitData;
    } else {
      console('Failed to load day limit');
    }
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      //final data = await userDataFromHive();
      final data = await fetchCusData();
      if (!mounted) return;
      setState(() {
        userData = data;

        // fullname = (userData!['cus_fname'] ?? '') +
        //     ' ' +
        //     (userData!['cus_mname'] ?? '') +
        //     ' ' +
        //     (userData!['cus_lname'] ?? '');
        // contact = userData!['cus_contact'].substring(1) ?? '';
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load waste categories')),
        // );
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

  // fetch latlong
  Future<String?> _searchLocation(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _locations = json.decode(response.body);
      });

      if (_locations.isEmpty) {
        return 'failed';
      } else {
        setState(() {
          var location = _locations[0];
          selectedPoint = LatLng(double.parse(location['lat']), double.parse(location['lon']));
          _mapController.move(selectedPoint!, 13.0); // Move to current location
          _mapController.rotate(0.0);
        });
        return 'success';
      }
    } else {
      if (!mounted) return null;
      showErrorSnackBar(context, 'Unable to load pin location.');
    }
    return 'failed';
  }

  // Future<void> _searchLocation(String query) async {
  //   final response = await http.get(
  //     Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json'),
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _locations = json.decode(response.body);
  //       if (_locations.isEmpty) {
  //         if (!mounted) return;
  //         showErrorSnackBar(context, 'No pin location found.');
  //       } else {
  //         var location = _locations[0];
  //         selectedPoint = LatLng(double.parse(location['lat']), double.parse(location['lon']));
  //         _mapController.move(selectedPoint!, 13.0);
  //         _mapController.rotate(0.0);
  //       }
  //     });
  //   } else {
  //     if (!mounted) return;
  //     showErrorSnackBar(context, 'Unable to load pin location.');
  //   }
  // }

  void handleOnePoint(LatLng point) {
    setState(() {
      selectedPoint = point;
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
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          return; // Location services are not enabled
        }
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
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
      setState(() {
        selectedPoint = LatLng(position.latitude, position.longitude);
        _mapController.move(selectedPoint!, 13);
        _mapController.rotate(0.0);
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
    if (selectedPoint == LatLng(bookingData!['bk_latitude'] as double, bookingData!['bk_longitude'] as double) &&
        _selectedDate == DateTime.parse(bookingData!['bk_date']).toLocal() &&
        isWasteEqual == true) {
      showSuccessSnackBar(context, 'No update changes');
      setState(() {
        _isEditing = false;
        onAddress = false;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Save Changes', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to update booking details?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  loadingAction = true;
                });

                if (bookingData != null) {
                  String? dbMessage = await bookingUpdate(
                      context,
                      bookingData!['bk_id'],
                      _fullnameController.text,
                      '0' + _contactController.text,
                      _selectedProvinceName!,
                      _selectedCityMunicipalityName!,
                      _selectedBarangayName!,
                      _streetController.text,
                      _postalController.text,
                      selectedPoint!.latitude,
                      selectedPoint!.longitude,
                      _selectedDate!,
                      _selectedWasteTypes);
                  if (dbMessage == 'success') {
                    setState(() {
                      Navigator.pop(context);
                      _isEditing = false;
                      onAddress = false;
                      onMap = false;
                    });
                  } else if (dbMessage == 'full date') {
                    if (!mounted) return;
                    Navigator.pop(context);
                    showFullyBookDayDialog(context, _selectedDate);
                    await loadDayLimit(); // reload day limit
                    setState(() {
                      _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
                    });
                  } else if (dbMessage == 'ongoing') {
                    if (!mounted) return;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
                  } else {
                    if (!mounted) return;
                    Navigator.pop(context);
                    showErrorSnackBar(context, 'Somthing\'s wrong. Please try again later.');
                  }
                }

                //
                setState(() {
                  loadingAction = false;
                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

////
  void _confirmDiscardUpdateBooking() {
    if (bookingWasteList == null) {
      Navigator.of(context).pop();
      return;
    }
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
      Navigator.of(context).pop(true);
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
    } else if (_fullnameController.text == (bookingData!['bk_fullname']) &&
        _contactController.text == bookingData!['bk_contact'].substring(1) &&
        _selectedProvinceName == bookingData!['bk_province'] &&
        _selectedCityMunicipalityName != bookingData!['cus_city'] &&
        _selectedBarangayName == bookingData!['bk_brgy'] &&
        _streetController.text == (bookingData!['bk_street']) &&
        _postalController.text == (bookingData!['bk_postal']) &&
        selectedPoint == LatLng(bookingData!['bk_latitude'] as double, bookingData!['bk_longitude'] as double) &&
        _selectedDate == DateTime.parse(bookingData!['bk_date']).toLocal() &&
        isWasteEqual == true) {
      setState(() {
        _isEditing = false;
        onAddress = false;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Discard Changes', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to discard any changes?', style: TextStyle(color: Colors.white)),
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
                  _selectedDate = DateTime.parse(bookingData!['bk_date']).toLocal();
                  _isEditing = false;
                  onAddress = false;
                  boxColorTheme = Colors.teal;
                });
                Navigator.of(context).pop();
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Cancel Booking', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to Cancel this booking? This cannot be undone.',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                if (bookingData != null) {
                  String? dbMessage = await bookingCancel(context, bookingData!['bk_id']);
                  if (dbMessage == 'success') {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
                  } else if (dbMessage == 'ongoing') {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
                  } else {
                    showErrorSnackBar(context, 'Somthing\'s wrong. Please try again later.');
                  }
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

  //address API
  Future<void> _loadProvinces() async {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinces = provinces;
        _showProvinceDropdown = true;
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
        _showCityMunicipalityDropdown = true;
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
        _showBarangayDropdown = true;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

  Widget _imagePreview(BuildContext context, Uint8List? dbScaleSlip) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: Text('Preview Scale Slip'),
      ),
      backgroundColor: deepPurple,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      child: dbScaleSlip != null
                          ? Image.memory(
                              dbScaleSlip,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(color: deepPurple, borderRadius: BorderRadius.circular(100)),
                              child: Icon(
                                Icons.wallpaper,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          if (loadingAction) showLoadingAction(),
        ],
      ),
    );
  }

//////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildFirstStep()),
            ],
          ),
          if (loadingAction) showLoadingAction(),
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
        //
        actions: [
          if (bookingData != null)
            (bookingData!['bk_status'] == 'Pending' || bookingData!['bk_status'] == 'Failed') && !_isEditing
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
            if (bookingData!['bk_status'] == 'Pending' || bookingData!['bk_status'] == 'Failed')
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
                          final data = await fetchAllLatLong(widget.bookId);
                          if (data != null) {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => C_MapScreen()));
                            bool onLocation = await checkLocationPermission();
                            if (onLocation) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainApp(
                                          selectedIndex: 1,
                                          bookID: widget.bookId,
                                          pickupPoint: LatLng(data['haul_lat'], data['haul_long']))));
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: _colorTweenCar.value,
                          ),
                          child: Container(
                              padding: EdgeInsets.only(left: 15, top: 5, right: 5, bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.bus_alert,
                                color: Colors.black,
                                size: 30,
                              )),
                        ),
                      );
                    })
                : SizedBox(
                    height: 30,
                  ),
          if (dbSlipImage != null)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _imagePreview(context, dbSlipImage)),
                );
              },
              icon: CircleAvatar(
                child: Icon(
                  Icons.sticky_note_2,
                  color: green,
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchBookingData();
            await _dbData();
            await _loadWasteCategories();

            if (bookingData != null && bookingWasteList != null && userData != null && _wasteTypes.isNotEmpty) {
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
                        ? loadingBookingAnimation(_controller, _colorTween, _colorTween2)

                        // onload dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
                        : Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    onAddress = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.only(left: 20),
                                      child: Text(
                                        'BOOKING# ${bookingData!['bk_id'].toString()}',
                                        style:
                                            TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
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
                                              color: bookingData!['bk_status'] == 'Pending'
                                                  ? Colors.orange
                                                  : bookingData!['bk_status'] == 'Ongoing'
                                                      ? Colors.green
                                                      : bookingData!['bk_status'] == 'Cancelled'
                                                          ? Colors.red
                                                          : bookingData!['bk_status'] == 'Failed'
                                                              ? Colors.pink
                                                              : Colors.blue,
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  bookingData == null
                                                      ? 'Loading ...'
                                                      : bookingData!['bk_status'] == 'Pending' ||
                                                              bookingData!['bk_status'] == 'Ongoing'
                                                          ? 'Your Request Pickup is ${bookingData!['bk_status']}'
                                                          : 'Your Request Pickup was ${bookingData!['bk_status']}',
                                                  style: const TextStyle(
                                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                if (bookingData!['bk_status'] == 'Ongoing')
                                                  const Text(
                                                    'Today is your waste collection day!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                if (bookingData!['bk_status'] == 'Failed')
                                                  const Text(
                                                    'Reschedule now to be our top priority!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              //color: Colors.grey[200],
                                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                            ),
                                            child: onAddress
                                                ? Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          SizedBox(),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                onAddress = false;
                                                              });
                                                            },
                                                            child: Container(
                                                              alignment: Alignment.centerRight,
                                                              padding:
                                                                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: deepPurple,
                                                                  boxShadow: shadowColor),
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Center(
                                                          child: Text(
                                                        'Information',
                                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                                      )),
                                                      const SizedBox(height: 20),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10),
                                                        child: Text(
                                                          'Contact',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: greytitleColor,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      _buildTextField(
                                                        controller: _fullnameController,
                                                        hintText: 'Full Name',
                                                        onChanged: (value) {
                                                          setState(() {
                                                            fullnamevalidator = validateFullname(value);
                                                            fullname = value!;
                                                          });
                                                        },
                                                      ),
                                                      _labelValidator(fullnamevalidator),
                                                      const SizedBox(height: 5),
                                                      _buildNumberField(
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.digitsOnly,
                                                          LengthLimitingTextInputFormatter(10),
                                                        ],
                                                      ),
                                                      _labelValidator(contactvalidator),
                                                      const SizedBox(height: 20),
                                                      Center(
                                                          child: Text(
                                                        'Complete Address',
                                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                                      )),
                                                      const SizedBox(height: 20),
                                                      Column(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '  Province/City or Municipality/Barangay',
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: greytitleColor),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical: 5.0, horizontal: 15),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                        boxShadow: shadowColor),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        // Show selected values
                                                                        Expanded(
                                                                          child: Text(
                                                                            _selectedProvinceName == null
                                                                                ? 'Select Province'
                                                                                : _selectedCityMunicipalityName == null
                                                                                    ? '${_selectedProvinceName} / '
                                                                                    : _selectedBarangayName == null
                                                                                        ? '${_selectedProvinceName} / ${_selectedCityMunicipalityName} / '
                                                                                        : '${_selectedProvinceName} / '
                                                                                            '${_selectedCityMunicipalityName} / '
                                                                                            '${_selectedBarangayName}',
                                                                            style: TextStyle(
                                                                                color: _selectedProvinceName == null
                                                                                    ? greySoft
                                                                                    : black,
                                                                                fontSize: 16.0),
                                                                            overflow:
                                                                                TextOverflow.visible, // Allow wrapping
                                                                            softWrap: true, // Enable soft wrapping
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                            icon: Icon(
                                                                              Icons.clear,
                                                                              color: Colors.deepPurple,
                                                                            ),
                                                                            onPressed: () {
                                                                              //close
                                                                              _loadProvinces();
                                                                              setState(() {
                                                                                _provinces = [];
                                                                                _citiesMunicipalities = [];
                                                                                _barangays = [];

                                                                                _showCityMunicipalityDropdown = false;
                                                                                _showBarangayDropdown = false;

                                                                                _selectedProvinceName = null;
                                                                                _selectedCityMunicipalityName = null;
                                                                                _selectedBarangayName = null;
                                                                                address = '';
                                                                              });
                                                                            })
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  if (_showProvinceDropdown)
                                                                    Container(
                                                                      height: 100,
                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.deepPurple.withOpacity(0.7),
                                                                          borderRadius: BorderRadius.vertical(
                                                                              bottom: Radius.circular(15)),
                                                                          boxShadow: shadowColor),
                                                                      child: ListView.builder(
                                                                        itemCount: _provinces.length,
                                                                        itemBuilder: (context, index) {
                                                                          final city = _provinces[index];

                                                                          return InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                _loadCitiesMunicipalities(city[
                                                                                    'code']); // Load barangays for the selected city

                                                                                _selectedProvinceName =
                                                                                    city['name']; // Set by name
                                                                                _showProvinceDropdown = false;
                                                                                _showCityMunicipalityDropdown = true;
                                                                              });
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 10, horizontal: 15),
                                                                              decoration: BoxDecoration(
                                                                                border: Border(
                                                                                    bottom: BorderSide(
                                                                                        color: Colors.grey.shade300)),
                                                                              ),
                                                                              child: Text(
                                                                                city['name'], // Display the name
                                                                                style: TextStyle(
                                                                                    fontSize: 16, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  if (_showCityMunicipalityDropdown)
                                                                    Container(
                                                                      height: 400,
                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.deepPurple.withOpacity(0.7),
                                                                          borderRadius: BorderRadius.vertical(
                                                                              bottom: Radius.circular(15)),
                                                                          boxShadow: shadowColor),
                                                                      child: ListView.builder(
                                                                        itemCount: _citiesMunicipalities.length,
                                                                        itemBuilder: (context, index) {
                                                                          final city = _citiesMunicipalities[index];

                                                                          return InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                _loadBarangays(city['code']);

                                                                                _selectedCityMunicipalityName =
                                                                                    city['name'];
                                                                                _showCityMunicipalityDropdown = false;
                                                                                _showBarangayDropdown = true;
                                                                              });
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 10, horizontal: 15),
                                                                              decoration: BoxDecoration(
                                                                                border: Border(
                                                                                    bottom: BorderSide(
                                                                                        color: Colors.grey.shade300)),
                                                                              ),
                                                                              child: Text(
                                                                                city['name'], // Display the name
                                                                                style: TextStyle(
                                                                                    fontSize: 16, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),

                                                                  //brgy ddl
                                                                  if (_showBarangayDropdown)
                                                                    Container(
                                                                      height: 400,
                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.deepPurple.withOpacity(0.7),
                                                                          borderRadius: BorderRadius.vertical(
                                                                              bottom: Radius.circular(15)),
                                                                          boxShadow: shadowColor),
                                                                      child: ListView.builder(
                                                                        itemCount: _barangays.length,
                                                                        itemBuilder: (context, index) {
                                                                          final city = _barangays[index];

                                                                          return InkWell(
                                                                            onTap: () async {
                                                                              setState(() {
                                                                                isLoadingLoc = true;

                                                                                _selectedBarangayName = city['name'];
                                                                                _showBarangayDropdown = false;

                                                                                address = _selectedBarangayName! +
                                                                                    ', ' +
                                                                                    _selectedCityMunicipalityName! +
                                                                                    ', ' +
                                                                                    _selectedProvinceName!;
                                                                              });

                                                                              //
                                                                              String loc =
                                                                                  '${_selectedProvinceName!} ${_selectedCityMunicipalityName!} ${_selectedBarangayName!}';
                                                                              String? result =
                                                                                  await _searchLocation(loc);
                                                                              if (result != 'success') {
                                                                                loc =
                                                                                    '${_selectedProvinceName!} ${_selectedCityMunicipalityName!}';
                                                                                String? result =
                                                                                    await _searchLocation(loc);
                                                                                if (result != 'success') {
                                                                                  loc = _selectedProvinceName!;
                                                                                  String? result =
                                                                                      await _searchLocation(loc);
                                                                                  if (result != 'success') {
                                                                                    if (!mounted) return;
                                                                                    showErrorSnackBar(context,
                                                                                        'No pin location found.');
                                                                                  }
                                                                                }
                                                                              }
                                                                              // String loc =
                                                                              //     '${_selectedProvinceName!} ${_selectedCityMunicipalityName!} ${_selectedBarangayName!}';
                                                                              // await _searchLocation(loc);
                                                                              setState(() {
                                                                                isLoadingLoc = false;
                                                                              });
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 10, horizontal: 15),
                                                                              decoration: BoxDecoration(
                                                                                border: Border(
                                                                                    bottom: BorderSide(
                                                                                        color: Colors.grey.shade300)),
                                                                              ),
                                                                              child: Text(
                                                                                city['name'], // Display the name
                                                                                style: TextStyle(
                                                                                    fontSize: 16, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          if (_selectedProvinceName == null ||
                                                              _selectedCityMunicipalityName == null ||
                                                              _selectedBarangayName == null)
                                                            Text(
                                                              'Please select your adrress.',
                                                              style: TextStyle(color: Colors.red),
                                                            ),
                                                          const SizedBox(height: 5),
                                                          _buildTextField(
                                                            controller: _streetController,
                                                            hintText: 'Street Name, Building, House No.',
                                                            onChanged: (value) {
                                                              setState(() {
                                                                streetvalidator = validateStreet(
                                                                    value); // Trigger validation on text change
                                                                street = value!;
                                                              });
                                                            },
                                                          ),
                                                          _labelValidator(streetvalidator),
                                                          const SizedBox(height: 5),
                                                          _buildTextField(
                                                            controller: _postalController,
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.digitsOnly,
                                                              LengthLimitingTextInputFormatter(4),
                                                            ],
                                                            hintText: 'Postal Code',
                                                            onChanged: (value) {
                                                              setState(() {
                                                                postalvalidator = validatePostalCode(
                                                                    value); // Trigger validation on text change
                                                                postal = value!;
                                                              });
                                                            },
                                                          ),
                                                          _labelValidator(postalvalidator),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                //if not on address
                                                : IntrinsicHeight(
                                                    child: Container(
                                                      padding: EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
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
                                                                  padding: EdgeInsets.only(left: 2),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(50),
                                                                  ),
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Icon(
                                                                    Icons.pin_drop,
                                                                    size: 30,
                                                                    color: Colors.green,
                                                                  ))),
                                                          Expanded(
                                                              flex: 10,
                                                              child: Container(
                                                                  padding: EdgeInsets.only(left: 10),
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              fullname,
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 15),
                                                                              softWrap: true,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child: Text('| +(63)${contact}',
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: Text(
                                                                            '${street} \n${address}, ${postal}',
                                                                          )),
                                                                      Expanded(
                                                                          flex: 1,
                                                                          child: Row(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Container(
                                                                                padding: EdgeInsets.all(2),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(3),
                                                                                  //color: Colors.white.withOpacity(.6),
                                                                                  border:
                                                                                      Border.all(color: Colors.green),
                                                                                ),
                                                                                child: Text(
                                                                                  'Pickup Address',
                                                                                  style: TextStyle(color: Colors.green),
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

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
                                        style:
                                            TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.grey[200],
                                              boxShadow: shadowColor),
                                          height: onMap ? 500 : 100,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: FlutterMap(
                                              mapController: _mapController,
                                              options: MapOptions(
                                                  center: LatLng(10.29411, 123.902453), // Example: Cebu City
                                                  zoom: 13.0,
                                                  //maxZoom: 19,
                                                  maxZoom: 19, // Maximum zoom in level
                                                  minZoom: 5, // Minimum zoom out level
                                                  onTap: (tapPosition, point) => handleOnePoint(point),
                                                  enableScrollWheel: true),
                                              children: [
                                                TileLayer(
                                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  subdomains: ['a', 'b', 'c'],
                                                  maxZoom: 19, // Maximum zoom in level
                                                  minZoom: 5, // Minimum zoom out level
                                                ),
                                                if (selectedPoint != null) ...[
                                                  MarkerLayer(
                                                    markers: [
                                                      Marker(
                                                          width: 80.0,
                                                          height: 80.0,
                                                          point: selectedPoint!,
                                                          builder: (ctx) => Icon(Icons.location_pin,
                                                              color: Colors.red, size: 40, shadows: shadowIconColor),
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
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    onMap = false;
                                                    setState(() {
                                                      if (selectedPoint != null) {
                                                        _mapController.move(selectedPoint!, 13);
                                                        _mapController.rotate(0.0);
                                                      }
                                                      onMap = false;
                                                      pinLocValidator = '';
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: deepPurple,
                                                        boxShadow: shadowColor),
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20),

                                                //current loc
                                                Container(
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
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
                                            color: const Color.fromARGB(0, 163, 145, 145),
                                            child: InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  isLoadingLoc = true;
                                                  onMap = true;
                                                });
                                                if (selectedPoint == null) {
                                                  if (_selectedProvinceName != null &&
                                                      _selectedCityMunicipalityName != null &&
                                                      _selectedBarangayName != null) {
                                                    //
                                                    String loc =
                                                        '${_selectedProvinceName!} ${_selectedCityMunicipalityName!} ${_selectedBarangayName!}';
                                                    String? result = await _searchLocation(loc);
                                                    if (result != 'success') {
                                                      loc =
                                                          '${_selectedProvinceName!} ${_selectedCityMunicipalityName!}';
                                                      String? result = await _searchLocation(loc);
                                                      if (result != 'success') {
                                                        loc = _selectedProvinceName!;
                                                        String? result = await _searchLocation(loc);
                                                        if (result != 'success') {
                                                          if (!mounted) return;
                                                          showErrorSnackBar(context, 'No pin location found.');
                                                        }
                                                      }
                                                    }
                                                  }
                                                }

                                                setState(() {
                                                  isLoadingLoc = false;
                                                });
                                              },
                                            ),
                                          )),

                                        isLoadingLoc
                                            ? Positioned.fill(
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.green,
                                                      strokeWidth: 10,
                                                      strokeAlign: 2,
                                                      backgroundColor: boxColorTheme,
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
                              _buildDatePicker('Date Schedule', 'Select Date'),
                              _labelValidator(dateValidator),
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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => WastePricingInfo())),
                                            child: SizedBox(
                                              width: 150,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(width: 5),
                                                  const Text(
                                                    'Waste Type',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(
                                                    Icons.info,
                                                    color: deepGreen,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: shadowColor,
                                                borderRadius: BorderRadius.circular(10)),
                                            child: _selectedDate != null
                                                ? _wasteCategoryList()
                                                : Container(
                                                    padding: EdgeInsets.all(10),
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.library_add, color: deepGreen),
                                                        SizedBox(width: 10.0),
                                                        Text(
                                                          'Choose date schedule first.',
                                                          style: TextStyle(color: grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                              _labelValidator(wasteCatValidator),
                              if (bookingData!['bk_status'] == 'Pending' || bookingData!['bk_status'] == 'Ongoing')
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
                                          'Payment later with Cash /with',
                                          style: TextStyle(color: grey),
                                        )),
                                        Image.asset('assets/paymongo.png'),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
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
                                                  borderRadius: BorderRadius.circular(10),
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
                                                  borderRadius: BorderRadius.circular(10),
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
                                                  borderRadius: BorderRadius.circular(10),
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
                                                  borderRadius: BorderRadius.circular(10),
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              side: BorderSide(color: Colors.white),
                                              value: _acceptTerms,
                                              activeColor: Colors.green,
                                              onChanged: (bool? newValue) {
                                                setState(() {
                                                  _acceptTerms = newValue ?? false;
                                                });
                                              },
                                            ),
                                            Text(
                                              'I accept the ',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context, 'terms');
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'terms and conditions.',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Colors.green,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            InkWell(
                                              onTap: () async {
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
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      boxShadow: shadowMidColor),
                                                  child: const Text(
                                                    'DISCARD',
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                if ((_fullnameController.text.isEmpty || fullnamevalidator != '') ||
                                                    (_contactController.text.isEmpty || contactvalidator != '') ||
                                                    (_selectedProvinceName == null ||
                                                        _selectedCityMunicipalityName == null ||
                                                        _selectedBarangayName == null) ||
                                                    (_streetController.text.isEmpty || streetvalidator != '') ||
                                                    (_postalController.text.isEmpty || postalvalidator != '')) {
                                                  setState(() {
                                                    fullnamevalidator = validateFullname(_fullnameController.text);
                                                    contactvalidator = validateContact(_contactController.text);
                                                    //no address needed
                                                    streetvalidator = validateStreet(_streetController.text);
                                                    postalvalidator = validatePostalCode(_postalController.text);

                                                    //open address tab
                                                    onAddress = true;
                                                  });
                                                } else if (selectedPoint == null ||
                                                    _selectedDate == null ||
                                                    _selectedWasteTypes.isEmpty) {
                                                  setState(() {
                                                    pinLocValidator = _validatePinLocl(selectedPoint);
                                                    dateValidator = _validateDate(_selectedDate);
                                                    wasteCatValidator = _validateWaste(_selectedWasteTypes);
                                                  });
                                                } else if (!_acceptTerms) {
                                                  showErrorSnackBar(context, 'Accept the terms and condition');
                                                } else {
                                                  _confirmUpdateBooking();
                                                }
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      boxShadow: shadowMidColor),
                                                  child: const Text(
                                                    'SAVE',
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                  )),
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
                  top: AppBar().preferredSize.height - 50,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      borderRadius: borderRadius10,
                      child: InkWell(
                        onTap: () {
                          _showConfirmCancelBookingDialog(context);
                          setState(() {
                            _showOptionsBox = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sentiment_very_dissatisfied,
                                size: 24,
                                color: Colors.red,
                              ),
                              SizedBox(width: 5),
                              Container(
                                  child:
                                      Text("Cancel Booking?", style: TextStyle(fontSize: 16, color: Colors.black54))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String?> onChanged,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: shadowColor),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              labelStyle: TextStyle(color: Colors.grey),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14, color: greySoft),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            inputFormatters: inputFormatters,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: shadowColor),
          child: TextFormField(
            controller: _contactController,
            decoration: InputDecoration(
              //prefixText: '+63 ',
              prefixIcon: Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Text('+63', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              //prefixIcon: Icon(Icons.abc),
              hintText: 'Contact Number',
              hintStyle: TextStyle(fontSize: 14, color: greySoft),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: inputFormatters,
            onChanged: (value) {
              if (value.length > 10) {
                _contactController.text = value.substring(0, 10);
                _contactController.selection =
                    TextSelection.fromPosition(TextPosition(offset: _contactController.text.length));
              }
              setState(() {
                contactvalidator = validateContact(value);
                contact = value;
              });
            },
          ),
        ),
      ],
    );
  }

//ddl
  Widget _buildDropdown({
    required String? selectedValue,
    required List<dynamic> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' ${hintText}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          Container(
            decoration: BoxDecoration(boxShadow: shadowColor),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.deepPurple,
                size: 30,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: items.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['code'],
                  child: Text(item['name']), // Use the appropriate field for display
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
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

  // waste cat ddl
  Widget _wasteCategoryList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(), // Stop scrolling
      shrinkWrap: true, // Use shrinkWrap to make the list fit its content.
      children: _isEditing
          ? _wasteTypes.map((Map<String, dynamic> category) {
              String type = category['name'];
              String desc = category['desc'];
              var price = category['price'];
              var unit = category['unit'];
              var wcId = category['wc_id'];

              // Check if the waste type is selected by comparing the name
              bool isSelected = _selectedWasteTypes.any((selectedCategory) => selectedCategory['name'] == type);
              //
              bool isDisabled = _wasteLimit.any((limit) => limit['wc_id'] == wcId);

              return Tooltip(
                message: desc,
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      isDisabled ? Icon(Icons.block, color: red) : Icon(Icons.library_add, color: deepGreen),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            Text(
                              '₱${price.toString()}\\${unit.toString()}',
                              style: TextStyle(color: Colors.deepOrange, fontSize: 14),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              desc,
                              style: TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: isDisabled
                      ? null // Disables the checkbox if `isDisabled` is true
                      : (bool? selected) {
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
                              _selectedWasteTypes.removeWhere((selectedCategory) => selectedCategory['name'] == type);
                            }

                            // Validator
                            if (_selectedWasteTypes.isEmpty) {
                              wasteCatValidator = _validateWaste(_selectedWasteTypes);
                            } else {
                              wasteCatValidator = '';
                            }
                          });
                        },
                  activeColor: Colors.blue, // Color of the checkbox when selected.
                  checkColor: Colors.white, // Color of the checkmark.
                ),
              );
            }).toList()
          : _selectedWasteTypes.map((Map<String, dynamic> category) {
              String type = category['name'];
              var price = category['price'];
              var unit = category['unit'];
              var total_unit = category['total_unit'];

              return Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 2, child: Text('${type}')),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '\₱${price.toString()}\\${unit.toString()}',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                    if (total_unit != null) Expanded(flex: 1, child: Text('${total_unit} ${unit.toString()}')),
                  ],
                ),
              );
            }).toList(),
    );
  }

  //// waste cat ddl
  // Widget _wasteCategoryList() {
  //   return ListView(
  //     physics: NeverScrollableScrollPhysics(), // Stop scrolling
  //     shrinkWrap: true, // Use shrinkWrap to make the list fit its content.
  //     children: _isEditing
  //         ? _wasteTypes.map((Map<String, dynamic> category) {
  //             String type = category['name'];
  //             var price = category['price'];
  //             var unit = category['unit'];

  //             // Check if the waste type is selected by comparing the name
  //             bool isSelected = _selectedWasteTypes.any((selectedCategory) => selectedCategory['name'] == type);

  //             return CheckboxListTile(
  //               title: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     '${type}',
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   Text(
  //                     '\₱${price.toString()}\\${unit.toString()}',
  //                     style: TextStyle(color: Colors.deepOrange, fontSize: 14),
  //                   ),
  //                 ],
  //               ),
  //               value: isSelected,
  //               onChanged: (bool? selected) {
  //                 setState(() {
  //                   if (selected == true) {
  //                     // Add the entire waste type object
  //                     _selectedWasteTypes.add({
  //                       'name': type,
  //                       'price': price,
  //                       'unit': unit,
  //                     });
  //                   } else {
  //                     // Remove the waste type object
  //                     _selectedWasteTypes.removeWhere((selectedCategory) => selectedCategory['name'] == type);
  //                   }

  //                   // Validator
  //                   if (_selectedWasteTypes.isEmpty) {
  //                     wasteCatValidator = _validateWaste(_selectedWasteTypes);
  //                   } else {
  //                     wasteCatValidator = '';
  //                   }
  //                 });
  //               },
  //               activeColor: Colors.blue, // Color of the checkbox when selected.
  //               checkColor: Colors.white, // Color of the checkmark.
  //             );
  //           }).toList()
  //         : _selectedWasteTypes.map((Map<String, dynamic> category) {
  //             String type = category['name'];
  //             var price = category['price'];
  //             var unit = category['unit'];

  //             return Container(
  //               padding: EdgeInsets.all(10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text('${type}'),
  //                   Text(
  //                     '\₱${price.toString()}\\${unit.toString()}',
  //                     style: TextStyle(color: Colors.deepOrange),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }).toList(),
  //   );
  // }

//date picker
  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200], boxShadow: shadowBigColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: shadowColor),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.green),
                  SizedBox(width: 10.0),
                  Text(
                    _selectedDate == null
                        ? hint
                        // : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        : DateFormat('MMM d, yyyy (EEEE)').format(_selectedDate!), // Format: Mon 1, 2024
                    style: TextStyle(
                        color: _selectedDate == null ? Colors.grey : null,
                        //fontWeight: FontWeight.bold,
                        fontSize: 14),
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
    final List<DateTime> disabledDates = _dayLimit.map((dayLimit) {
      final DateTime dbDay = DateTime.parse(dayLimit['day']).toLocal();
      final DateTime strippedDay = DateTime(dbDay.year, dbDay.month, dbDay.day);
      return strippedDay;
    }).toList();

    final DateTime now = DateTime.now();

    final int closeTimeInMinutes = _bookLimit['bl_close_time'];
    final DateTime closeTime =
        DateTime(now.year, now.month, now.day, closeTimeInMinutes ~/ 60, closeTimeInMinutes % 60);

    //final DateTime dbDateStart = DateTime.parse(_bookLimit['bl_date_start']).toUtc();
    final DateTime dbDateLast = DateTime.parse(_bookLimit['bl_date_last']).toUtc();
    final DateTime firstDate = now.isBefore(closeTime) ? now : now.add(Duration(days: 1));
    final DateTime localLastDate = dbDateLast.toLocal();
    final DateTime lastDate = DateTime(localLastDate.year, localLastDate.month, localLastDate.day);

    // Check if initialDate is disabled
    DateTime initialDate = firstDate;

    // Find the next available date if the initialDate is disabled
    while (disabledDates.contains(initialDate)) {
      initialDate = initialDate.add(Duration(days: 1));
    }
    //
    if (_selectedDate == null || _selectedDate!.isBefore(firstDate) || _selectedDate!.isAfter(lastDate)) {
      _selectedDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime date) {
        if (date == DateTime.parse(bookingData!['bk_date']).toLocal()) {
          return true;
        }
        return !disabledDates.contains(date);
      },
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
        loadingAction = true;
      });
      //
      final bkWasteLimitData = await fetchWasteLimit(picked);
      if (bkWasteLimitData != null) {
        _wasteLimit = bkWasteLimitData;
      } else {
        showErrorSnackBar(context, 'Booking waste limit not found');
        return;
      }
      console(picked);
      setState(() {
        _selectedDate = picked;

        if (_selectedDate != null) {
          dateValidator = '';
        }

        //
        loadingAction = false;
      });
    }
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime now = DateTime.now();
  //   final DateTime firstDate = DateTime(now.year);
  //   final DateTime lastDate = DateTime(now.year + 1, 12, 31);

  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate,
  //     //initialDate: DateTime.now(),
  //     firstDate: firstDate,
  //     lastDate: lastDate, // Use the current year + 1
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: ColorScheme.light(
  //             primary: Colors.green, // Circle color for the selected date
  //             onPrimary: Colors.white, // Text color inside the circle
  //             onSurface: Colors.green[900]!, // Text color for dates
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;

  //       if (_selectedDate != null) {
  //         dateValidator = '';
  //       }
  //     });
  //   }
  // }
}
