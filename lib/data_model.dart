import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  // User fields
  String? fname;
  String? lname;
  String? email;

  // Fetch or update user data and notify listeners
  void setUserData(String newFname, String newLname, String newEmail) {
    fname = newFname;
    lname = newLname;
    email = newEmail;

    // Notify listeners when the data is updated
    notifyListeners();
  }

  // Optionally, create a method to clear the user data
  void clearUserData() {
    fname = null;
    lname = null;
    email = null;
    notifyListeners();
  }
}
