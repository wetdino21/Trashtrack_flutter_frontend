import 'package:flutter/material.dart';
import 'dart:typed_data';

class UserModel extends ChangeNotifier {
  // User fields
  String? id;
  String? fname;
  String? lname;
  String? email;
  String? auth;
  Uint8List? profile;

// Fetch or update user data and notify listeners
  void setUserData({
    String? newId,
    String? newFname,
    String? newLname,
    String? newEmail,
    String? newAuth,
    Uint8List? newProfile,
  }) {
    // Call clearModelData if the id is changing
    if (newId != null && newId != id) {
      clearModelData(); 
    }
    // Only update the fields that have non-null values
    if (newId != null) id = newId;
    if (newFname != null) fname = newFname;
    if (newLname != null) lname = newLname;
    if (newEmail != null) email = newEmail;
    if (newAuth != null) auth = newAuth;
    if (newProfile != null) profile = newProfile;

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
  void clearModelData() {
    id = null;
    fname = null;
    lname = null;
    email = null;
    auth = null;
    profile = null;
    notifyListeners();
  }
}
