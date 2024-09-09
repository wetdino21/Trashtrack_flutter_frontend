import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// Scopes required by this application.
const List<String> scopes = <String>[
  'email',
  //'https://www.googleapis.com/auth/contacts.readonly',
  //'https://www.googleapis.com/auth/userinfo.profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _profileText = '';

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      if (isAuthorized) {
        unawaited(_handleGetUserProfile(account!));
      }
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetUserProfile(GoogleSignInAccount user) async {
    setState(() {
      _profileText = 'Loading profile info...';
    });

    try {
      final http.Response response = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses,addresses,photos'),
        headers: await user.authHeaders,
      );

      if (response.statusCode != 200) {
        setState(() {
          _profileText = 'People API gave a ${response.statusCode} response. Check logs for details.';
        });
        print('People API ${response.statusCode} response: ${response.body}');
        //return;
      }

      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

      final String? fullName = _pickDisplayName(data);
      final String? email = _pickEmail(data);
      final String? address = _pickAddress(data);
      final String? photoUrl = _pickPhotoUrl(data);

      final List<String> nameParts = splitName(fullName);
      setState(() {
        _profileText = 'First Name: ${nameParts[0]}\nLast Name: ${nameParts[1]}\nEmail: $email\nAddress: $address\nPhoto: $photoUrl';
      });

    } catch (e) {
      setState(() {
        _profileText = 'Error fetching user profile: $e';
      });
      print('Error fetching user profile: $e');
    }
  }

  String? _pickDisplayName(Map<String, dynamic> data) {
    final List<dynamic>? names = data['names'] as List<dynamic>?;
    if (names != null && names.isNotEmpty) {
      final Map<String, dynamic>? name = names.first as Map<String, dynamic>?;
      return name?['displayName'] as String?;
    }
    return 'No name found';
  }

  String? _pickEmail(Map<String, dynamic> data) {
    final List<dynamic>? emails = data['emailAddresses'] as List<dynamic>?;
    if (emails != null && emails.isNotEmpty) {
      final Map<String, dynamic>? email = emails.first as Map<String, dynamic>?;
      return email?['value'] as String?;
    }
    return 'No email found';
  }

  String? _pickAddress(Map<String, dynamic> data) {
    final List<dynamic>? addresses = data['addresses'] as List<dynamic>?;
    if (addresses != null && addresses.isNotEmpty) {
      final Map<String, dynamic>? address = addresses.first as Map<String, dynamic>?;
      return address?['formattedValue'] as String?;
    }
    return 'No address found';
  }

  String? _pickPhotoUrl(Map<String, dynamic> data) {
    final List<dynamic>? photos = data['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final Map<String, dynamic>? photo = photos.first as Map<String, dynamic>?;
      return photo?['url'] as String?;
    }
    return 'No photo found';
  }

List<String> splitName(String? fullName) {
  if (fullName == null || fullName.isEmpty) {
    return ['No first name', 'No last name'];
  }

  final List<String> parts = fullName.split(' ');
  if (parts.length == 1) {
    return [parts[0], '']; // Single word name, treat it as first name
  } else {
    // All words except the last one are the first name
    // The last word is the last name
    final String firstName = parts.sublist(0, parts.length - 1).join(' ');
    final String lastName = parts.last;
    return ['asds', lastName];
  }
}


  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    setState(() {
      print('successful google login');
      _isAuthorized = isAuthorized;
    });

    if (isAuthorized) {
      unawaited(_handleGetUserProfile(_currentUser!));
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ListTile(
              leading: GoogleUserCircleAvatar(
                identity: user,
              ),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
            ),
            const Text('Signed in successfully.'),
            if (_isAuthorized) ...<Widget>[
              Text(_profileText),
              ElevatedButton(
                child: const Text('REFRESH'),
                onPressed: () => _handleGetUserProfile(user),
              ),
            ],
            if (!_isAuthorized) ...<Widget>[
              const Text('Additional permissions needed to read your profile information.'),
              ElevatedButton(
                onPressed: _handleAuthorizeScopes,
                child: const Text('REQUEST PERMISSIONS'),
              ),
            ],
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('SIGN OUT'),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: () {
              _handleSignIn();
            },
            child: const Text('Sign In with Google'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}




// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleSignInScreen extends StatefulWidget {
//   @override
//   _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
// }

// class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<void> handleSignIn() async {
//     try {
//       GoogleSignInAccount? user = await _googleSignIn.signIn();
//       if (user != null) {
//         print('Signed in: ${user.displayName}');
//         print('Signed in: ${user.email}');
//          print('Signed in: ${user.photoUrl}');
         
//       } else {
//         print('Sign-in canceled');
//       }
//     } catch (error) {
//       print('Sign-in failed: $error');
//     }
//   }

//   Future<void> _handleSignOut() async {
//     await _googleSignIn.signOut();
//     print('Signed out');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign-In'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: handleSignIn,
//               child: Text('Sign in with Google'),
//             ),
//             ElevatedButton(
//               onPressed: _handleSignOut,
//               child: Text('Sign out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
