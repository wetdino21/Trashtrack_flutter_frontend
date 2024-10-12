import 'package:flutter/material.dart';

// Validator All
labelValidator(String showValidator) {
  return showValidator != ''
      ? Text(
          showValidator,
          style: TextStyle(color: Colors.red),
        )
      : SizedBox();
}

String validateFullname(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your full name';
  }
  if (!RegExp(r'^[a-zA-Z]+(?:\s+[a-zA-Z]+)+$').hasMatch(value)) {
    return 'Letters only (Atleast two words)';
  }
  return '';
}

String validateContact(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your contact number';
  }
  final contactNumber = value.replaceFirst(RegExp(r'^0'), '');
  if (contactNumber.length != 10 || !contactNumber.startsWith('9')) {
    //print(contactNumber);
    return 'Invalid Phone Number';
  }
  return '';
}

String validateProvince(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your province';
  }
  return '';
}

String validateCity(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select your city/municipality';
  }
  return '';
}

String validateBrgy(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select your barangay';
  }
  return '';
}

String validateStreet(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your street name, building, house No';
  }
  if (value.length < 3) {
    return 'Atleat 3 letters long';
  }
  return '';
}

String validatePostalCode(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your postal code';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Postal code must contain only numbers';
  }
  if (value.length != 4) {
    // Adjust according to postal code length
    return 'Postal code must be 4 digits long';
  }
  if (value[0] != '6') {
    // Adjust according to postal code length
    return 'Invalid Postal Code';
  }
  return '';
}
