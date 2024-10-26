import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:audioplayers/audioplayers.dart';

class UserModel extends ChangeNotifier {
  // User fields
  String? id;
  String? fname;
  String? lname;
  String? email;
  String? auth;
  Uint8List? profile;
  int? notifCount;
  bool isToHome = false;

// Fetch or update user data and notify listeners
  void setUserData({
    String? newId,
    String? newFname,
    String? newLname,
    String? newEmail,
    String? newAuth,
    Uint8List? newProfile,
    int? newNotifCount,
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
    if (newNotifCount != null) notifCount = newNotifCount;
    // Notify listeners when the data is updated
    notifyListeners();
  }

  // update profile
  void setIsHome(bool newIsToHome) {
    isToHome = newIsToHome;
    notifyListeners();
  }

  // update profile
  void setUserProfile(Uint8List? userProfile) {
    profile = userProfile;
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

//for sounds
class AudioService {
  //final AudioPlayer _audioPlayer = AudioPlayer();
  List<AudioPlayer> _audioPlayers = [];

  Future<void> playNotifSound() async {
    AudioPlayer newPlayer = AudioPlayer();
    _audioPlayers.add(newPlayer);

    await newPlayer.setVolume(1);
    await newPlayer.setSource(AssetSource('sound/trashtrack_notif.mp3'));
    await newPlayer.resume(); // Play the sound

    // Dispose of the player once the sound has finished
    newPlayer.onPlayerComplete.listen((event) {
      _audioPlayers.remove(newPlayer);
      newPlayer.dispose();
    });
  }

  Future<void> playPressSound() async {
    AudioPlayer newPlayer = AudioPlayer();
    _audioPlayers.add(newPlayer);

    //await newPlayer.setSource(AssetSource('sound/press.mp3'));
    await newPlayer.setVolume(1);
    await newPlayer.setSource(AssetSource('sound/water.mp3'));
    await newPlayer.resume(); // Play the sound

    // Dispose of the player once the sound has finished
    newPlayer.onPlayerComplete.listen((event) {
      _audioPlayers.remove(newPlayer);
      newPlayer.dispose();
    });
  }
  // Future<void> playNotifSound() async {
  //   await _audioPlayer.setSource(AssetSource('sound/trashtrack_notif.mp3'));
  //   await _audioPlayer.resume();
  // }
  //  Future<void> playPressSound() async {
  //   await _audioPlayer.setSource(AssetSource('sound/press.mp3'));
  //   await _audioPlayer.resume();
  // }

  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose(); // Dispose of all players
    }
    _audioPlayers.clear();
  }
  // void dispose() {
  //   _audioPlayer.dispose(); // Dispose of the AudioPlayer when no longer needed
  // }
}

// //object 3D
// class ObjectCache {
//   static final ObjectCache _instance = ObjectCache._internal();
//   late Object obj;

//   factory ObjectCache() {
//     return _instance;
//   }

//   ObjectCache._internal() {
//     // Initialize the 3D object only once
//     obj = Object(
//       scale: Vector3(11.0, 11.0, 11.0),
//       rotation: Vector3(0, -90, 0),
//       fileName: 'assets/objects/base.obj',
//     );
//   }

//   Object get getObject => obj;
// }
