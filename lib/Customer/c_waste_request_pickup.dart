import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class RequestPickupScreen extends StatefulWidget {
  @override
  _RequestPickupScreenState createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen> {
  int _currentStep = 0;

  // Controllers for the input fields
  String? _selectedWasteType;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    // implement dispose
    super.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
  }

  // List of waste types
  final List<String> _wasteTypes = [
    'Municipal Waste',
    'Construction Waste',
    'Food Waste'
  ];

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
                    } else if(_currentStep == 1){
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
            _buildDropDownList('Type of Waste'),

            //textbox
            SizedBox(height: 5.0),
            _buildTextboxField(
                _addressController, 'Address', 'Type your address'),
            SizedBox(height: 5.0),
            _buildTextboxField(_cityController, 'City', 'Type your City'),
            SizedBox(height: 5.0),
            _buildTextboxField(_stateController, 'State', 'Type your State'),
            SizedBox(height: 5.0),
            _buildTextboxField(
                _postalCodeController, 'Postal Code', 'Type your Postal Code'),
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
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title:
                    Text('Credit Card',),
                value: 'Credit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title:
                    Text('Debit Card'),
                value: 'Debit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text('GCash'),
                value: 'GCash',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ],
          ),
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
                  //style: TextStyle(backgroundColor: Colors.white),
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
