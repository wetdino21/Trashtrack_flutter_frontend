import 'package:flutter/material.dart';
import 'dart:typed_data';

class UserModel extends ChangeNotifier {
  // User fields
  String? fname;
  String? lname;
  String? email;
  String? auth;
  Uint8List? profile;

  // Fetch or update user data and notify listeners
  void setUserData(String? newFname, String? newLname, String? newEmail,
      String? newAuth, Uint8List? newProfile) {
    fname = newFname;
    lname = newLname;
    email = newEmail;
    auth = newAuth;
    profile = newProfile;
    // Notify listeners when the data is updated
    notifyListeners();
  }

  // update profile
  void setUserProfile(Uint8List? userProfile) {
    profile = profile;
    notifyListeners();
  }

   // update auth
  void setBindTrashtrack(String? userAuth) {
    auth = userAuth;
    notifyListeners();
  }

     // update auth
  void setBindGoogle(String? userAuth, String? newEmail) {
    auth = userAuth;
    email = newEmail;
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
