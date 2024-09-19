import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'dart:async';

class RequestPickupScreen extends StatefulWidget {
  @override
  _RequestPickupScreenState createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  // Controllers for the input fields
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;

  Map<String, dynamic>? userData;

  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  bool isLoading = true;

  String fullname = '';
  String contact = '';
  String address = '';
  String street = '';

  List<String> _wasteTypes = [];
  String? _selectedWasteType;

  @override
  void initState() {
    super.initState();
    _dbData();
    _loadWasteCategories();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.white30,
      end: Colors.grey,
    ).animate(_controller);
  }

  @override
  void dispose() {
    // implement dispose

    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    TickerCanceled;
    _controller.dispose();
    super.dispose();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      //final data = await userDataFromHive();
      final data = await fetchCusData(context);

      setState(() {
        userData = data;

        fullname = (userData!['cus_fname'] ?? '') +
            ' ' +
            (userData!['cus_mname'] ?? '') +
            ' ' +
            (userData!['cus_lname'] ?? '');
        contact = userData!['cus_contact'] ?? '';
        street = (userData!['cus_street'] ?? '');
        address = (userData!['cus_brgy'] ?? '') +
            ', ' +
            (userData!['cus_city'] ?? '') +
            ', ' +
            (userData!['cus_province'] ?? '') +
            ', ' +
            (userData!['cus_postal'] ?? '');
        isLoading = false;
      });
      //await data.close();
    } catch (e) {
      isLoading = false;
      print(e);
      setState(() {
        //errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Function to load waste categories and update the state
  Future<void> _loadWasteCategories() async {
    List<String>? categories = await fetchWasteCategory();
    if (categories != null) {
      setState(() {
        _wasteTypes = categories;
        isLoading = false;
      });
    } else {
      // Handle the case where fetching categories failed
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load waste categories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _currentStep == 0 ? _buildFirstStep() : _buildSecondStep(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  )
                else
                  Container(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else if (_currentStep == 1) {
                      Navigator.pushNamed(context, 'c_schedule');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: Text(
                    _currentStep < 1 ? 'Next' : 'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Request Pickup'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.0),
            Center(
                child: Text(
              'Fill all the fields',
              style: TextStyle(color: Colors.white),
            )),
            Divider(
              color: accentColor,
            ),
            Text('Step 1/3',
                style: TextStyle(
                    color: accentColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            //ddl
            SizedBox(height: 16.0),
            isLoading
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
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
                                      borderRadius: BorderRadius.circular(50),
                                      //color: Colors.white.withOpacity(.6),
                                      color: Colors.white,
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
                                                margin: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  //color: Colors.white.withOpacity(.6),
                                                  color: Colors.white,
                                                ),
                                                child: Text(''))),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                width: 250,
                                                margin: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  //color: Colors.white.withOpacity(.6),
                                                  color: Colors.white,
                                                ),
                                                child: Text(''))),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                width: 150,
                                                margin: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  //color: Colors.white.withOpacity(.6),
                                                  color: Colors.white,
                                                ),
                                                child: Text(''))),
                                      ],
                                    ))),
                          ],
                        ),
                      );
                    })
                : Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      //color: Colors.white.withOpacity(.6),
                      color: Colors.white,
                    ),
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
                                  //color: Colors.white.withOpacity(.6),
                                  color: Colors.grey[300],
                                ),
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.pin_drop,
                                  size: 30,
                                  color: Colors.redAccent,
                                ))),
                        Expanded(
                            flex: 10,
                            child: Container(
                                padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Text(
                                              fullname,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17),
                                            ),
                                            Text('   | +(63)${contact}',
                                                style: TextStyle(
                                                  color: Colors.grey,
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
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                //color: Colors.white.withOpacity(.6),
                                                border: Border.all(
                                                    color: Colors.red),
                                              ),
                                              child: Text(
                                                'Default',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[300]),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                //color: Colors.white.withOpacity(.6),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Text(
                                                'Pickup Address',
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ))),
                      ],
                    ),
                  ),
            SizedBox(height: 16.0),
            isLoading ? Container() : _buildDropDownList('Type of Waste'),
            SizedBox(height: 5.0),
            _buildDatePicker('Date', 'Select Date'),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Step 2/3',
            style: TextStyle(
                color: accentColor, fontSize: 25, fontWeight: FontWeight.bold)),
        leading: SizedBox(width: 0),
        leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Select Payment Method',
                  //   style: TextStyle(color: Colors.grey, fontSize: 16.0),
                  // ),
                  // SizedBox(height: 16.0),
                  // RadioListTile<String>(
                  //   activeColor: Color(0xFF86BF3E),
                  //   title: Text(
                  //     'Credit Card',
                  //   ),
                  //   value: 'Credit Card',
                  //   groupValue: _selectedPaymentMethod,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedPaymentMethod = value;
                  //     });
                  //   },
                  // ),
                  // RadioListTile<String>(
                  //   activeColor: Color(0xFF86BF3E),
                  //   title: Text('Debit Card'),
                  //   value: 'Debit Card',
                  //   groupValue: _selectedPaymentMethod,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedPaymentMethod = value;
                  //     });
                  //   },
                  // ),
                  // RadioListTile<String>(
                  //   activeColor: Color(0xFF86BF3E),
                  //   title: Text('GCash'),
                  //   value: 'GCash',
                  //   groupValue: _selectedPaymentMethod,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedPaymentMethod = value;
                  //     });
                  //   },
                  // ),
            
                  // ElevatedButton(onPressed: (){
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));
                  // }, child: Text('select')),
            
                  Center(
                    child: Text(
                      'Pay with',
                      style: TextStyle(color: Colors.grey, fontSize: 16.0),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      launchPaymentLink(context);
                    },
                    child: Container(
                      child: Image.asset('assets/paymongo.png'),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  Center(
                    child: Text(
                      'Pay with',
                      style: TextStyle(color: Colors.grey, fontSize: 16.0),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      launchPaymentLink2(context);
                    },
                    child: Container(
                      child: Image.asset('assets/truck.png'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownList(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedWasteType,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              //labelText: 'Select Waste Type',
              labelStyle: TextStyle(color: accentColor),
              hintText: 'Select Waste Type',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            items: _wasteTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedWasteType = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextboxField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            //style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              filled: true,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF86BF3E)),
                SizedBox(width: 10.0),
                Text(
                  _selectedDate == null
                      ? hint
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
      });
    }
  }
}
