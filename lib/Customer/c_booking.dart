import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/api_address.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/styles.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trashtrack/validator_data.dart';

class RequestPickupScreen extends StatefulWidget {
  @override
  _RequestPickupScreenState createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen> with SingleTickerProviderStateMixin {
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

  bool isLoading = true;
  bool loadingAction = false;

  String fullname = '';
  String contact = '';
  String address = '';
  String street = '';
  String postal = '';

  bool _acceptTerms = false;

  Map<String, dynamic> _bookLimit = {};
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

  @override
  void initState() {
    super.initState();
    _dbData();
    //_loadWasteCategories();

    // Initialize the animation controller
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

  // Fetch user data from the server
  Future<void> _dbData() async {
    setState(() {
      isLoading = true;
    });
    try {
      //final data = await userDataFromHive();
      final data = await fetchCusData(context);
      final bkLimitData = await fetchBookLimit();
      List<Map<String, dynamic>>? categories = await fetchWasteCategory();

      if (!mounted) return;
      if (data != null) {
        setState(() {
          userData = data;

          _fullnameController.text = (userData!['cus_fname'] ?? '') +
              ' ' +
              (userData!['cus_mname'] ?? '') +
              ' ' +
              (userData!['cus_lname'] ?? '');
          _contactController.text = userData!['cus_contact'].substring(1) ?? '';
          _selectedProvinceName = userData!['cus_province'] ?? '';
          _selectedCityMunicipalityName = userData!['cus_city'] ?? '';
          _selectedBarangayName = userData!['cus_brgy'] ?? '';
          _streetController.text = (userData!['cus_street'] ?? '');
          _postalController.text = (userData!['cus_postal'] ?? '');

          fullname = (userData!['cus_fname'] ?? '') +
              ' ' +
              (userData!['cus_mname'] ?? '') +
              ' ' +
              (userData!['cus_lname'] ?? '');
          contact = userData!['cus_contact'].substring(1) ?? '';
          address = (userData!['cus_brgy'] ?? '') +
              ', ' +
              (userData!['cus_city'] ?? '') +
              ', ' +
              (userData!['cus_province'] ?? '');
          street = (userData!['cus_street'] ?? '');
          postal = (userData!['cus_postal'] ?? '');

          //load book limit
          if (bkLimitData != null) {
            _bookLimit = bkLimitData;
          } else {
            console('Failed to load booking limit');
          }

          //load waste cat
          if (categories != null) {
            _wasteTypes = categories;
            isLoading = false;
          } else {
            print('Failed to load waste categories');
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

// // Fetch user data from the server
//   Future<void> _dbData() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       //final data = await userDataFromHive();
//       final data = await fetchCusData(context);
//       if (!mounted) return;
//       if (data != null) {
//         setState(() {
//           userData = data;

//           _fullnameController.text = (userData!['cus_fname'] ?? '') +
//               ' ' +
//               (userData!['cus_mname'] ?? '') +
//               ' ' +
//               (userData!['cus_lname'] ?? '');
//           _contactController.text = userData!['cus_contact'].substring(1) ?? '';
//           _selectedProvinceName = userData!['cus_province'] ?? '';
//           _selectedCityMunicipalityName = userData!['cus_city'] ?? '';
//           _selectedBarangayName = userData!['cus_brgy'] ?? '';
//           _streetController.text = (userData!['cus_street'] ?? '');
//           _postalController.text = (userData!['cus_postal'] ?? '');

//           fullname = (userData!['cus_fname'] ?? '') +
//               ' ' +
//               (userData!['cus_mname'] ?? '') +
//               ' ' +
//               (userData!['cus_lname'] ?? '');
//           contact = userData!['cus_contact'].substring(1) ?? '';
//           address = (userData!['cus_brgy'] ?? '') +
//               ', ' +
//               (userData!['cus_city'] ?? '') +
//               ', ' +
//               (userData!['cus_province'] ?? '');
//           street = (userData!['cus_street'] ?? '');
//           postal = (userData!['cus_postal'] ?? '');

//           //isLoading = false;
//         });
//         //load waste cat
//         final bkLimitData = await fetchBookLimit();

//         console(bkLimitData);
//         //load waste cat
//         List<Map<String, dynamic>>? categories = await fetchWasteCategory();
//         if (!mounted) return;
//         if (categories != null) {
//           setState(() {
//             _wasteTypes = categories;
//             isLoading = false;
//           });
//         } else {
//           print('Failed to load waste categories');
//         }
//         setState(() {
//           isLoading = false;
//         });
//       } // MAKE IT INSIDE ONE SETSTATEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
//       //await data.close();
//     } catch (e) {
//       if (!mounted) return;
//       //isLoading = true;
//       print(e.toString());
//       // setState(() {
//       //   //errorMessage = e.toString();
//       //   isLoading = true;
//       // });
//     }
//   }

  // // Function to load waste categories and update the state
  // Future<void> _loadWasteCategories() async {
  //   try {
  //     List<Map<String, dynamic>>? categories = await fetchWasteCategory();
  //     if (!mounted) return;
  //     if (categories != null) {
  //       setState(() {
  //         _wasteTypes = categories;
  //         isLoading = false;
  //       });
  //     } else {
  //       print('Failed to load waste categories');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     print(e);
  //     setState(() {
  //       //errorMessage = e.toString();
  //       //isLoading = true;
  //     });
  //   }
  // }

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
      setState(() {
        isLoadingLoc = true;
      });
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

      print('getting current location');

      ///current pstion
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      // String? getCurrentName =
      //     await getPlaceName(position.latitude, position.longitude);
      print('location success');
      setState(() {
        selectedPoint = LatLng(position.latitude, position.longitude);
        _mapController.move(selectedPoint!, 13.0); // Move to current location

        // selectedPlaceName = getCurrentName;
      });
    } catch (e) {
      print('fail to get current location!');
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoadingLoc = false;
      });
    }
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
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
        //title: Text('Request Pickup'),
        leading: IconButton(
            padding: EdgeInsets.all(15),
            onPressed: () {
              _backFromBooking();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: RefreshIndicator(
              onRefresh: () async {
                await _dbData();
                //await _loadWasteCategories();

                if (userData != null && _wasteTypes.isNotEmpty) {
                  isLoading = false;
                }
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                //padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PopScope(
                        canPop: false,
                        onPopInvokedWithResult: (didPop, result) async {
                          if (didPop) {
                            return;
                          }
                          _backFromBooking();
                        },
                        child: Container()),
                    Center(
                        child: Text(
                      'Booking',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    )),
                    SizedBox(height: 16.0),
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
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: shadowBigColor),
                                  child: onAddress
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      onAddress = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.centerRight,
                                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: deepPurple,
                                                        boxShadow: shadowColor),
                                                    child: Icon(
                                                      Icons.copy_all_sharp,
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
                                                    fontWeight: FontWeight.bold, color: greytitleColor, fontSize: 16),
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
                                                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
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
                                                                  overflow: TextOverflow.visible, // Allow wrapping
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
                                                                borderRadius:
                                                                    BorderRadius.vertical(bottom: Radius.circular(15)),
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
                                                                          bottom:
                                                                              BorderSide(color: Colors.grey.shade300)),
                                                                    ),
                                                                    child: Text(
                                                                      city['name'], // Display the name
                                                                      style:
                                                                          TextStyle(fontSize: 16, color: Colors.white),
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
                                                                borderRadius:
                                                                    BorderRadius.vertical(bottom: Radius.circular(15)),
                                                                boxShadow: shadowColor),
                                                            child: ListView.builder(
                                                              itemCount: _citiesMunicipalities.length,
                                                              itemBuilder: (context, index) {
                                                                final city = _citiesMunicipalities[index];

                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(() {
                                                                      _loadBarangays(city['code']);

                                                                      _selectedCityMunicipalityName = city['name'];
                                                                      _showCityMunicipalityDropdown = false;
                                                                      _showBarangayDropdown = true;
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical: 10, horizontal: 15),
                                                                    decoration: BoxDecoration(
                                                                      border: Border(
                                                                          bottom:
                                                                              BorderSide(color: Colors.grey.shade300)),
                                                                    ),
                                                                    child: Text(
                                                                      city['name'], // Display the name
                                                                      style:
                                                                          TextStyle(fontSize: 16, color: Colors.white),
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
                                                                borderRadius:
                                                                    BorderRadius.vertical(bottom: Radius.circular(15)),
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
                                                                          bottom:
                                                                              BorderSide(color: Colors.grey.shade300)),
                                                                    ),
                                                                    child: Text(
                                                                      city['name'], // Display the name
                                                                      style:
                                                                          TextStyle(fontSize: 16, color: Colors.white),
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
                                                      streetvalidator =
                                                          validateStreet(value); // Trigger validation on text change
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
                                                          //color: Colors.white,
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
                                                                  flex: 1,
                                                                  child: Text(
                                                                    fullname,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold, fontSize: 15),

                                                                    //softWrap: true,
                                                                    // overflow:
                                                                    //     TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    '| +(63)${contact}',
                                                                    style: TextStyle(
                                                                      color: Colors.grey,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
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
                                                                        borderRadius: BorderRadius.circular(3),
                                                                        //color: Colors.white.withOpacity(.6),
                                                                        border: Border.all(color: Colors.grey),
                                                                      ),
                                                                      child: Text(
                                                                        'Pickup Address',
                                                                        style: TextStyle(color: Colors.black54),
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
                              ),

                              //MAPPPPPPPPPPPPPP
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: shadowBigColor),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Pin Location',
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: onMap ? 500 : 100,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: shadowColor),
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
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedPoint != null)
                                                        _mapController.move(selectedPoint!, 13);
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
                                                      Icons.copy_all_sharp,
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
                                                    onTap: () async {
                                                      // setState(() {

                                                      // });
                                                      await _getCurrentLocation();
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
                                                  onMap = true;
                                                });
                                                if (selectedPoint == null) {
                                                  await _getCurrentLocation();
                                                }
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
                                                      backgroundColor: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    _labelValidator(pinLocValidator),
                                  ],
                                ),
                              ),

                              _buildDatePicker('Date Schedule', 'Select Date'),
                              //_labelValidator(dateValidator),
                              isLoading
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: shadowBigColor),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Waste Type',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: shadowColor),
                                            child: _wasteCategoryList(),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          _labelValidator(wasteCatValidator),
                                        ],
                                      ),
                                    ),

                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
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
                                        style: TextStyle(color: Colors.grey),
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
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      loadingAction = true;
                                    });
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
                                        _selectedWasteTypes.isEmpty ||
                                        _selectedDate == null) {
                                      setState(() {
                                        pinLocValidator = _validatePinLocl(selectedPoint);
                                        wasteCatValidator = _validateWaste(_selectedWasteTypes);
                                        dateValidator = _validateDate(_selectedDate);
                                      });
                                    } else if (!_acceptTerms) {
                                      showErrorSnackBar(context, 'Accept the terms and condition');
                                    } else {
                                      print(_selectedWasteTypes);
                                      //good
                                      String? dbMessage = await booking(
                                          context,
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
                                      if (dbMessage == 'success')
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MainApp(
                                                      selectedIndex: 2,
                                                    )));
                                      else
                                        showErrorSnackBar(context, 'Somthing\'s wrong. Please try again later.');
                                    }
                                    setState(() {
                                      loadingAction = false;
                                    });
                                  },
                                  child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10.0),
                                          boxShadow: shadowMidColor),
                                      child: const Text(
                                        'SUBMIT',
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          )
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

  void _backFromBooking() {
    if (userData == null) {
      Navigator.of(context).pop();
      return;
    }
    if (_fullnameController.text !=
            ((userData!['cus_fname']) + ' ' + (userData!['cus_mname']) + ' ' + (userData!['cus_lname'])) ||
        _contactController.text != userData!['cus_contact'].substring(1) ||
        _selectedProvinceName != userData!['cus_province'] ||
        _selectedCityMunicipalityName != userData!['cus_city'] ||
        _selectedBarangayName != userData!['cus_brgy'] ||
        _streetController.text != (userData!['cus_street']) ||
        _postalController.text != (userData!['cus_postal']) ||
        selectedPoint != null ||
        _selectedWasteTypes.isNotEmpty ||
        _selectedDate != null) {
      _showBackConfirmationDialog(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showBackConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Unsave Changes?', style: TextStyle(color: Colors.white)),
          content: Text('Any data from this form will be removed!', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the page
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Validator All
  _labelValidator(String showValidator) {
    return showValidator != ''
        ? Text(
            showValidator,
            style: TextStyle(color: Colors.red),
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

  // Widget _wasteCategoryList() {
  //   return ListView(
  //     physics: NeverScrollableScrollPhysics(), //stop scrollong
  //     shrinkWrap: true, // Use shrinkWrap to make the list fit its content.
  //     children: _wasteTypes.map((Map<String, dynamic> category) {
  //       String type = category['name'];
  //       var price = category['price'];
  //       var unit = category['unit'];

  //       return CheckboxListTile(
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text('${type}'),
  //             Text(
  //               '\₱${price.toString()}\\${unit.toString()}',
  //               style: TextStyle(color: Colors.deepOrange),
  //             ),
  //           ],
  //         ),
  //         value: _selectedWasteTypes.contains(type),
  //         onChanged: (bool? selected) {
  //           setState(() {
  //             if (selected == true) {
  //               _selectedWasteTypes.add(type);
  //             } else {
  //               _selectedWasteTypes.remove(type);
  //             }

  //             //validator
  //             if (_selectedWasteTypes.isEmpty) {
  //               wasteCatValidator = _validateWaste(_selectedWasteTypes);
  //             } else {
  //               wasteCatValidator = '';
  //             }
  //           });
  //         },
  //         activeColor: Colors.blue, // Color of the checkbox when selected.
  //         checkColor: Colors.white, // Color of the checkmark.
  //       );
  //     }).toList(),
  //   );
  // }
  Widget _wasteCategoryList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(), // Stop scrolling
      shrinkWrap: true, // Use shrinkWrap to make the list fit its content.
      children: _wasteTypes.map((Map<String, dynamic> category) {
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
      }).toList(),
    );
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

  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration:
            BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), boxShadow: shadowBigColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: shadowColor),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green),
                  SizedBox(width: 10.0),
                  Text(
                    _selectedDate == null
                        ? hint
                        : DateFormat('MMM d, yyyy (EEEE)').format(_selectedDate!), 
                    style: TextStyle(color: _selectedDate == null ? Colors.grey : null, fontSize: 14),
                  ),
                  SizedBox(width: 10.0),
                ],
              ),
            ),
            SizedBox(height: 5.0),
            _labelValidator(dateValidator),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final int closeTimeInMinutes = _bookLimit['bl_close_time'];
    final DateTime closeTime =
        DateTime(now.year, now.month, now.day, closeTimeInMinutes ~/ 60, closeTimeInMinutes % 60);

    final DateTime dbDateStart = DateTime.parse(_bookLimit['bl_date_start']).toUtc();
    final DateTime dbDateLast = DateTime.parse(_bookLimit['bl_date_last']).toUtc();
    //first date
    final DateTime localStartDate = dbDateStart.toLocal(); // Convert to local time
    final DateTime subFirstDate = DateTime(localStartDate.year, localStartDate.month, localStartDate.day);
    final DateTime firstDate = now.isBefore(closeTime)
        ? subFirstDate 
        : subFirstDate.add(Duration(days: 1)); 

    //Last date
    final DateTime localLastDate = dbDateLast.toLocal(); // Convert to local time
    final DateTime lastDate = DateTime(localLastDate.year, localLastDate.month, localLastDate.day);

    //initial date
    final DateTime initialDate = firstDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, // Circle color for the selected date
              onPrimary: Colors.white, // Text color inside the circle
              onSurface: deepPurple, // Text color for dates
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

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime now = DateTime.now();
  //   //final DateTime firstDate = DateTime(now.year, now.month, now.day);
  //   final dbDateStart = _bookLimit['bl_date_start'];
  //   final dbDateLast = _bookLimit['bl_date_last'];

  //   final DateTime firstDate = now.hour < 15
  //       ? DateTime(now.year, now.month, now.day)
  //       : DateTime(now.year, now.month, now.day + 1);
  //   final DateTime initialDate = now.hour < 15 ? DateTime.now() : firstDate;
  //   final DateTime lastDate = DateTime(now.year + 1, 12, 31);

  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: initialDate,
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
