import 'package:flutter/material.dart';
//import 'package:flutter_cube/flutter_cube.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/schedule_list.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/map.dart';
import 'package:trashtrack/API/api_address.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/Customer/api_cus_data.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trashtrack/validator_data.dart';

class Booking_List extends StatefulWidget {
  @override
  State<Booking_List> createState() => _Booking_ListState();
}

class _Booking_ListState extends State<Booking_List> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  late Animation<Color?> _colorPriority;

  List<Map<String, dynamic>>? bookingTodayList;
  List<Map<String, dynamic>>? wasteTodayList;
  List<Map<String, dynamic>>? bookingUpcomingList;
  List<Map<String, dynamic>>? wasteUpcomingList;
  bool isLoading = false;

  String? user;
  int selectedPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();

    _pageController = PageController(initialPage: selectedPage);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
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

    _colorPriority = ColorTween(
      begin: Colors.pinkAccent,
      end: deepPurple,
    ).animate(_controller);
  }

  @override
  void dispose() {
    TickerCanceled;
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Fetch booking from the server
  Future<void> _fetchBookingData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userdata = await userDataFromHive();
      setState(() {
        user = userdata['user'];
      });

      final data = await fetchTodayBooking();
      final data2 = await fetchUpcomingBooking();
      if (!mounted) {
        return;
      }
      if (data != null && data2 != null) {
        setState(() {
          bookingTodayList = data['booking'];
          wasteTodayList = data['wasteTypes'];
          //
          bookingUpcomingList = data2['booking'];
          wasteUpcomingList = data2['wasteTypes'];

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
      setState(() {
        isLoading = true;
      });
    }
  }

  void onPageSelected(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        foregroundColor: white,
        backgroundColor: deepGreen,
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Center(
            child: Text(
              'List of booking waiting for pickup.',
              style: TextStyle(color: white, fontSize: 16),
            ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: boxDecorationBig,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onPageSelected(0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: selectedPage == 0 ? deepPurple : white,
                          boxShadow: shadowColor,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(10))),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Today',
                              style: TextStyle(
                                  color: selectedPage == 0 ? white : deepPurple,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onPageSelected(1),
                    child: Container(
                      decoration: BoxDecoration(
                          color: selectedPage == 1 ? deepPurple : white,
                          boxShadow: shadowColor,
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(10))),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Upcoming',
                              style: TextStyle(
                                  color: selectedPage == 1 ? white : deepPurple,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            child: Row(
              children: [
                Expanded(flex: 5, child: Container()),
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(color: white, boxShadow: shadowMidColor),
                    )),
                Expanded(flex: 5, child: Container()),
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(color: white, boxShadow: shadowMidColor),
                    )),
                Expanded(flex: 5, child: Container()),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .8,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedPage = index;
                    });
                  },
                  children: [
                    // TODAY
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchBookingData();
                      },
                      child: isLoading
                          ? loadingAnimation(_controller, _colorTween, _colorTween2)
                          : bookingTodayList == null
                              ? ListView(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.calendar_month, color: whiteSoft, size: 70),
                                                Text(
                                                  'No List for Pickup\n\n\n\n',
                                                  style: TextStyle(color: whiteSoft, fontSize: 20),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 100,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: bookingTodayList?.length == null ? 0 : bookingTodayList!.length,
                                  itemBuilder: (context, index) {
                                    // if (index == 0) {
                                    //   return SizedBox(height: 20.0);
                                    // }

                                    // Safely retrieve the booking details from bookingList
                                    final booking = bookingTodayList?[index];

                                    if (booking == null) {
                                      return SizedBox.shrink();
                                    }
                                    int book_Id = booking['bk_id'];
                                    DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                    final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                    DateTime dbdateCreated = DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                    final String dateCreated = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

                                    // Filter waste types for the current booking's bk_id
                                    String wasteTypes = '';
                                    if (wasteTodayList != null) {
                                      List<Map<String, dynamic>> filteredWasteList = wasteTodayList!.where((waste) {
                                        return waste['bk_id'] == booking['bk_id'];
                                      }).toList();

                                      // Build the waste types string
                                      int count = 0;
                                      for (var waste in filteredWasteList) {
                                        count++;
                                        wasteTypes += waste['bw_name'] + ', ';
                                        if (count == 2) break;
                                      }

                                      // Remove the trailing comma and space
                                      if (wasteTypes.isNotEmpty) {
                                        if (filteredWasteList.length > 2) {
                                          wasteTypes = wasteTypes + '. . .';
                                        } else {
                                          wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                        }
                                      }
                                    }

                                    final String status = booking['bk_status'] ?? 'No status';
                                    final bool priority = booking['bk_priority'] ?? false;

                                    // Pass the extracted data to the C_CurrentScheduleCard widget
                                    return Column(
                                      children: [
                                        AnimatedBuilder(
                                            animation: _controller,
                                            builder: (context, child) {
                                              return Container(
                                                color: priority == true ? _colorPriority.value : Colors.transparent,
                                                padding: priority == true && index == 0
                                                    ? EdgeInsets.only(top: 20)
                                                    : EdgeInsets.zero,
                                                //padding: priority == true ? EdgeInsets.all(5) : EdgeInsets.zero,
                                                //margin: priority == true ? EdgeInsets.all(5) : EdgeInsets.zero,
                                                // decoration: BoxDecoration(
                                                //     color: priority == true ? _colorPriority.value : Colors.transparent,
                                                //     borderRadius: borderRadius10),
                                                child: C_ScheduleCardList(
                                                  priority: priority,
                                                  bookId: book_Id,
                                                  date: date,
                                                  dateCreated: dateCreated,
                                                  wasteType: wasteTypes,
                                                  status: status,
                                                  today: true,
                                                ),
                                              );
                                            }),
                                        if (priority == false) SizedBox(height: 10),
                                        if (bookingTodayList!.length - 1 == index) SizedBox(height: 200),
                                      ],
                                    );
                                  },
                                ),
                    ),

                    //UPCOMING
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchBookingData();
                      },
                      child: isLoading
                          ? loadingAnimation(_controller, _colorTween, _colorTween2)
                          : bookingUpcomingList == null
                              ? ListView(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.calendar_month, color: whiteSoft, size: 70),
                                                Text(
                                                  'No List for Pickup\n\n\n\n',
                                                  style: TextStyle(color: whiteSoft, fontSize: 20),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 100,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: bookingUpcomingList?.length == null ? 0 : bookingUpcomingList!.length,
                                  itemBuilder: (context, index) {
                                    // if (index == 0) {
                                    //   return SizedBox(height: 20.0);
                                    // }

                                    // Safely retrieve the booking details from bookingList
                                    final booking = bookingUpcomingList?[index];

                                    if (booking == null) {
                                      return SizedBox.shrink();
                                    }
                                    int book_Id = booking['bk_id'];
                                    DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                    final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                    DateTime dbdateCreated = DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                    final String dateCreated = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

                                    // Filter waste types for the current booking's bk_id
                                    String wasteTypes = '';
                                    if (wasteUpcomingList != null) {
                                      List<Map<String, dynamic>> filteredWasteList = wasteUpcomingList!.where((waste) {
                                        return waste['bk_id'] == booking['bk_id'];
                                      }).toList();

                                      // Build the waste types string
                                      int count = 0;
                                      for (var waste in filteredWasteList) {
                                        count++;
                                        wasteTypes += waste['bw_name'] + ', ';
                                        if (count == 2) break;
                                      }

                                      // Remove the trailing comma and space
                                      if (wasteTypes.isNotEmpty) {
                                        if (filteredWasteList.length > 2) {
                                          wasteTypes = wasteTypes + '. . .';
                                        } else {
                                          wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                        }
                                      }
                                    }

                                    final String status = booking['bk_status'] ?? 'No status';
                                    final bool priority = booking['bk_priority'] ?? false;
                                    // Pass the extracted data to the C_CurrentScheduleCard widget
                                    return Column(
                                      children: [
                                        C_ScheduleCardList(
                                          priority: priority,
                                          bookId: book_Id,
                                          date: date,
                                          dateCreated: dateCreated,
                                          wasteType: wasteTypes,
                                          status: status,
                                          today: false,
                                        ),
                                        if (bookingUpcomingList!.length - 1 == index) SizedBox(height: 200),
                                      ],
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Booking_Pending_Details extends StatefulWidget {
  final int bookId;
  final bool? today;

  const Booking_Pending_Details({
    required this.bookId,
    this.today,
  });

  @override
  _Booking_Pending_DetailsState createState() => _Booking_Pending_DetailsState();
}

class _Booking_Pending_DetailsState extends State<Booking_Pending_Details> with SingleTickerProviderStateMixin {
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

  String fullname = '';
  String contact = '';
  String address = '';
  String street = '';
  String postal = '';

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
  bool onAddress = false;

  String pinLocValidator = '';
  String wasteCatValidator = '';
  String dateValidator = '';

  Map<String, dynamic>? bookingData;
  List<Map<String, dynamic>>? bookingWasteList;

  bool _isEditing = false;
  Color? boxColorTheme = Colors.teal;
  bool _showOptionsBox = false;
  bool loadingAction = false;
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
      final data = await fetchBookingDetails(context, widget.bookId);
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          final bookingListdb = data['booking'];
          final bookingWasteListdb = data['wasteTypes'];

          if (bookingListdb != null) {
            bookingData = Map<String, dynamic>.from(bookingListdb[0]);
          }
          if (bookingWasteListdb != null) {
            bookingWasteList = List<Map<String, dynamic>>.from(bookingWasteListdb);

            _selectedWasteTypes = List<Map<String, dynamic>>.from(bookingWasteList!.map((waste) => {
                  'name': waste['bw_name'],
                  'price': waste['bw_price'],
                  'unit': waste['bw_unit'],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No internet connection')),
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
          ],
        );
      },
    );
  }

////
  void _confirmDiscardUpdateBooking() {
    // check if nothing change
    if (isLoading) {
      Navigator.of(context).pop();
      return;
    }

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
          title: Text('Return Booking', style: TextStyle(color: Colors.white)),
          content: Text(
              'This will change the status of the booking to ' 'Pending' ' and it will appear on the pickup list.',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                if (bookingData != null) {
                  String? dbMessage = await bookingReturn(context, bookingData!['bk_id']);
                  if (dbMessage == 'success') {
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
          // if (bookingData != null)
          //   bookingData!['bk_status'] == 'Pending' && !_isEditing
          //       ? Container(
          //           decoration: BoxDecoration(
          //             color: Colors.deepPurpleAccent,
          //             borderRadius: BorderRadius.circular(30),
          //           ),
          //           child: IconButton(
          //             onPressed: () {
          //               setState(() {
          //                 _isEditing = true;
          //                 boxColorTheme = Colors.deepPurple;
          //               });
          //             },
          //             icon: Icon(Icons.edit_outlined),
          //           ),
          //         )
          //       : SizedBox(),
          // SizedBox(width: 5),
          // if (bookingData != null)
          //   if (bookingData!['bk_status'] == 'Pending')
          //     Container(
          //       decoration: BoxDecoration(
          //         color: Colors.deepPurpleAccent,
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //       child: IconButton(
          //         onPressed: () {
          //           setState(() {
          //             // Toggle the visibility of the options box
          //             _showOptionsBox = !_showOptionsBox;
          //           });
          //         },
          //         icon: Icon(Icons.more_vert),
          //       ),
          //     ),

          //go to map
          if (!isLoading)
            AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return TextButton(
                    onPressed: () async {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => C_MapScreen()));
                      bool onLocation = await checkLocationPermission();
                      if (onLocation) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainApp(
                                      selectedIndex: 1,
                                      bookID: widget.bookId,
                                      bookStatus: bookingData!['bk_status'],
                                      pickupPoint: LatLng(selectedPoint!.latitude, selectedPoint!.longitude),
                                    )));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: _colorTweenCar.value,
                      ),
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30,
                          )),
                    ),
                  );
                }),
          if (bookingData != null)
            if (bookingData!['bk_status'] == 'Ongoing')
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showOptionsBox = !_showOptionsBox;
                    });
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ),

          SizedBox(width: 5),
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
                                                          ? 'Request Pickup is ${bookingData!['bk_status']}'
                                                          //? 'Your Request Pickup is ${bookingData!['bk_status']}'
                                                          : 'Request Pickup was ${bookingData!['bk_status']}',
                                                  style: TextStyle(
                                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                if (bookingData!['bk_status'] == 'Ongoing')
                                                  const Text(
                                                    'Ride and safety first!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                                                          Container(
                                                            alignment: Alignment.centerRight,
                                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5),
                                                                color: Colors.blue,
                                                                boxShadow: shadowColor),
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  onAddress = false;
                                                                });
                                                              },
                                                              child: Text(
                                                                'Minimize',
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold),
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
                                                                            onTap: () {
                                                                              setState(() {
                                                                                _selectedBarangayName = city['name'];
                                                                                _showBarangayDropdown = false;

                                                                                address = _selectedBarangayName! +
                                                                                    ', ' +
                                                                                    _selectedCityMunicipalityName! +
                                                                                    ', ' +
                                                                                    _selectedProvinceName!;
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
                                                          builder: (ctx) =>
                                                              Icon(Icons.location_pin, color: Colors.red, size: 40),
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
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: Colors.blue,
                                                      boxShadow: shadowColor),
                                                  child: InkWell(
                                                    onTap: () {
                                                      onMap = false;
                                                      setState(() {
                                                        if (selectedPoint != null)
                                                          _mapController.move(selectedPoint!, 13);
                                                        onMap = false;
                                                        pinLocValidator = '';
                                                      });
                                                    },
                                                    child: Text(
                                                      'Minimize',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold),
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
                                              onTap: () {
                                                setState(() {
                                                  onMap = true;
                                                });
                                                if (selectedPoint == null) _getCurrentLocation();
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
                                          Text(
                                            'Waste Type',
                                            style: TextStyle(
                                                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: shadowColor,
                                                borderRadius: BorderRadius.circular(10)),
                                            child: _wasteCategoryList(),
                                          ),
                                        ],
                                      ),
                                    ),
                              _labelValidator(wasteCatValidator),

                              // Container(
                              //   padding: EdgeInsets.all(10),
                              //   margin: EdgeInsets.all(10),
                              //   decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(10),
                              //       color: Colors.grey[200],
                              //       boxShadow: shadowBigColor),
                              //   child: Container(
                              //     padding: EdgeInsets.all(10),
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(10),
                              //         boxShadow: shadowColor),
                              //     child: Column(
                              //       children: [
                              //         Center(
                              //             child: Text(
                              //           'Payment later with',
                              //           style: TextStyle(color: grey),
                              //         )),
                              //         Image.asset('assets/paymongo.png'),
                              //         Row(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.center,
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.center,
                              //           children: [
                              //             Padding(
                              //               padding: const EdgeInsets.all(5),
                              //               child: ClipRRect(
                              //                   borderRadius:
                              //                       BorderRadius.circular(10),
                              //                   child: Container(
                              //                       height: 50,
                              //                       width: 50,
                              //                       child: Image.asset(
                              //                         'assets/visa.png',
                              //                         scale: 2,
                              //                       ))),
                              //             ),
                              //             Padding(
                              //               padding: const EdgeInsets.all(5),
                              //               child: ClipRRect(
                              //                   borderRadius:
                              //                       BorderRadius.circular(10),
                              //                   child: Container(
                              //                       height: 50,
                              //                       width: 50,
                              //                       child: Image.asset(
                              //                         'assets/gcash.png',
                              //                         scale: 2,
                              //                       ))),
                              //             ),
                              //             Padding(
                              //               padding: const EdgeInsets.all(5),
                              //               child: ClipRRect(
                              //                   borderRadius:
                              //                       BorderRadius.circular(10),
                              //                   child: Container(
                              //                       height: 50,
                              //                       width: 50,
                              //                       child: Image.asset(
                              //                         'assets/paymaya.png',
                              //                         scale: 2,
                              //                       ))),
                              //             ),
                              //             Padding(
                              //               padding: const EdgeInsets.all(5),
                              //               child: ClipRRect(
                              //                   borderRadius:
                              //                       BorderRadius.circular(10),
                              //                   child: Container(
                              //                       height: 50,
                              //                       width: 50,
                              //                       child: Image.asset(
                              //                         'assets/grabpay.png',
                              //                         scale: 2,
                              //                       ))),
                              //             ),
                              //             Padding(
                              //               padding: const EdgeInsets.all(5),
                              //               child: ClipRRect(
                              //                   borderRadius:
                              //                       BorderRadius.circular(10),
                              //                   child: Container(
                              //                       height: 50,
                              //                       width: 50,
                              //                       child: Image.asset(
                              //                         'assets/methods.png',
                              //                         scale: 2,
                              //                       ))),
                              //             ),
                              //           ],
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // ),
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
                          ),
                    Container(
                      height: MediaQuery.of(context).size.height * .1,
                    ),
                  ],
                ),
              ),
              //
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
                      color: white,
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
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showConfirmCancelBookingDialog(context);
                          setState(() {
                            _showOptionsBox = false;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.keyboard_return,
                                color: Colors.red,
                              ),
                              SizedBox(width: 5),
                              Container(
                                  child: Text("Return to pending?",
                                      style: TextStyle(fontSize: 16, color: Colors.black54))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              //accept
              if (widget.today != null)
                if (!isLoading && bookingData!['bk_status'] == 'Pending' && widget.today!)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * 1,
                      color: deepPurple,
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            loadingAction = true;
                          });
                          bool onLocation = await checkLocationPermission();
                          if (onLocation) {
                            ///current pstion
                            LocationSettings locationSettings = const LocationSettings(accuracy: LocationAccuracy.high);
                            Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

                            ////
                            String? resultDb =
                                await bookingAccept(context, widget.bookId, position.latitude, position.longitude);

                            if (resultDb == 'success') {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
                            } else if (resultDb == 'ongoing') {
                              // Navigator.push(
                              //     context, MaterialPageRoute(builder: (context) => MainApp(selectedIndex: 2)));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Booking_List(),
                                ),
                              );
                            } else {
                              showErrorSnackBar(context, 'Something wrong, Please try again later.');
                            }
                          }
                          setState(() {
                            loadingAction = false;
                          });
                        },
                        child: Center(
                          child: Container(
                              // margin: EdgeInsets.symmetric(
                              //     horizontal: MediaQuery.of(context).size.width * .3),
                              width: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: shadowMidColor),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.drive_eta,
                                      color: white,
                                      size: 30,
                                    ),
                                    const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
              if (loadingAction) showLoadingAction(),
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
              bool isSelected = _selectedWasteTypes.any((selectedCategory) => selectedCategory['name'] == type);

              return CheckboxListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${type}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '\₱${price.toString()}\\${unit.toString()}',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 14),
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
