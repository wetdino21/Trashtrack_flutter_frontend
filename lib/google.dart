
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GoogleLoginAs(),
//     );
//   }
// }

// class GoogleLoginAs extends StatefulWidget {
//   const GoogleLoginAs({super.key});

//   @override
//   State<GoogleLoginAs> createState() => _GoogleLoginAsState();
// }

// class _GoogleLoginAsState extends State<GoogleLoginAs> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign-In'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             await signInWithGoogle();
//           },
//           child: Text('Login with Google'),
//         ),
//       ),
//     );
//   }
// }

// Future<void> signInWithGoogle() async {
//   try {
//     GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     if (googleUser == null) {
//       print('User canceled the sign-in');
//       return;
//     }

//     GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

//     if (userCredential.user != null) {
//       print('User signed in: ${userCredential.user!.displayName}');
//     } else {
//       print('User credential is null');
//     }
//   } catch (e) {
//     print('Error signing in with Google: $e');
//   }
// }


// import 'dart:async';
// import 'dart:convert' show json;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;

// //import 'src/sign_in_button.dart';

// /// The scopes required by this application.
// // #docregion Initialize
// const List<String> scopes = <String>[
//   'email',
//   'https://www.googleapis.com/auth/contacts.readonly',
// ];

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: 'your-client_id.apps.googleusercontent.com',
//   scopes: scopes,
// );
// // #enddocregion Initialize

// void main() {
//   runApp(
//     const MaterialApp(
//       title: 'Google Sign In',
//       home: MyApp(),
//     ),
//   );
// }

// /// The SignInDemo app.
// class MyApp extends StatefulWidget {
//   ///
//   const MyApp({super.key});

//   @override
//   State createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   GoogleSignInAccount? _currentUser;
//   bool _isAuthorized = false; // has granted permissions?
//   String _contactText = '';

//   @override
//   void initState() {
//     super.initState();

//     _googleSignIn.onCurrentUserChanged
//         .listen((GoogleSignInAccount? account) async {
// // #docregion CanAccessScopes
//       // In mobile, being authenticated means being authorized...
//       bool isAuthorized = account != null;
//       // However, on web...
//       if (kIsWeb && account != null) {
//         isAuthorized = await _googleSignIn.canAccessScopes(scopes);
//       }
// // #enddocregion CanAccessScopes

//       setState(() {
//         _currentUser = account;
//         _isAuthorized = isAuthorized;
//       });

//       // Now that we know that the user can access the required scopes, the app
//       // can call the REST API.
//       if (isAuthorized) {
//         unawaited(_handleGetContact(account!));
//       }
//     });

//     // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
//     //
//     // It is recommended by Google Identity Services to render both the One Tap UX
//     // and the Google Sign In button together to "reduce friction and improve
//     // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
//     _googleSignIn.signInSilently();
//   }

//   // Calls the People API REST endpoint for the signed-in user to retrieve information.
//   Future<void> _handleGetContact(GoogleSignInAccount user) async {
//     setState(() {
//       _contactText = 'Loading contact info...';
//     });
//     final http.Response response = await http.get(
//       Uri.parse('https://people.googleapis.com/v1/people/me/connections'
//           '?requestMask.includeField=person.names'),
//       headers: await user.authHeaders,
//     );
//     if (response.statusCode != 200) {
//       setState(() {
//         _contactText = 'People API gave a ${response.statusCode} '
//             'response. Check logs for details.';
//       });
//       print('People API ${response.statusCode} response: ${response.body}');
//       return;
//     }
//     final Map<String, dynamic> data =
//         json.decode(response.body) as Map<String, dynamic>;
//     final String? namedContact = _pickFirstNamedContact(data);
//     setState(() {
//       if (namedContact != null) {
//         _contactText = 'I see you know $namedContact!';
//       } else {
//         _contactText = 'No contacts to display.';
//       }
//     });
//   }

//   String? _pickFirstNamedContact(Map<String, dynamic> data) {
//     final List<dynamic>? connections = data['connections'] as List<dynamic>?;
//     final Map<String, dynamic>? contact = connections?.firstWhere(
//       (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
//       orElse: () => null,
//     ) as Map<String, dynamic>?;
//     if (contact != null) {
//       final List<dynamic> names = contact['names'] as List<dynamic>;
//       final Map<String, dynamic>? name = names.firstWhere(
//         (dynamic name) =>
//             (name as Map<Object?, dynamic>)['displayName'] != null,
//         orElse: () => null,
//       ) as Map<String, dynamic>?;
//       if (name != null) {
//         return name['displayName'] as String?;
//       }
//     }
//     return null;
//   }

//   // This is the on-click handler for the Sign In button that is rendered by Flutter.
//   //
//   // On the web, the on-click handler of the Sign In button is owned by the JS
//   // SDK, so this method can be considered mobile only.
//   // #docregion SignIn
//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }
//   // #enddocregion SignIn

//   // Prompts the user to authorize `scopes`.
//   //
//   // This action is **required** in platforms that don't perform Authentication
//   // and Authorization at the same time (like the web).
//   //
//   // On the web, this must be called from an user interaction (button click).
//   // #docregion RequestScopes
//   Future<void> _handleAuthorizeScopes() async {
//     final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
//     // #enddocregion RequestScopes
//     setState(() {
//       _isAuthorized = isAuthorized;
//     });
//     // #docregion RequestScopes
//     if (isAuthorized) {
//       unawaited(_handleGetContact(_currentUser!));
//     }
//     // #enddocregion RequestScopes
//   }

//   Future<void> _handleSignOut() => _googleSignIn.disconnect();

//   Widget _buildBody() {
//     final GoogleSignInAccount? user = _currentUser;
//     if (user != null) {
//       // The user is Authenticated
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: user,
//             ),
//             title: Text(user.displayName ?? ''),
//             subtitle: Text(user.email),
//           ),
//           const Text('Signed in successfully.'),
//           if (_isAuthorized) ...<Widget>[
//             // The user has Authorized all required scopes
//             Text(_contactText),
//             ElevatedButton(
//               child: const Text('REFRESH'),
//               onPressed: () => _handleGetContact(user),
//             ),
//           ],
//           if (!_isAuthorized) ...<Widget>[
//             // The user has NOT Authorized all required scopes.
//             // (Mobile users may never see this button!)
//             const Text('Additional permissions needed to read your contacts.'),
//             ElevatedButton(
//               onPressed: _handleAuthorizeScopes,
//               child: const Text('REQUEST PERMISSIONS'),
//             ),
//           ],
//           ElevatedButton(
//             onPressed: _handleSignOut,
//             child: const Text('SIGN OUT'),
//           ),
//         ],
//       );
//     } else {
//       // The user is NOT Authenticated
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           const Text('You are not currently signed in.'),
//           // This method is used to separate mobile from web code with conditional exports.
//           // See: src/sign_in_button.dart
//           // buildSignInButton(
//           //   onPressed: _handleSignIn,
//           // ),
//           ElevatedButton(onPressed: (){
//             _handleSignIn();
//           }, child: Text('data'))
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Google Sign In'),
//         ),
//         body: ConstrainedBox(
//           constraints: const BoxConstraints.expand(),
//           child: _buildBody(),
//         ));
//   }
// }

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// Scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
  'https://www.googleapis.com/auth/userinfo.profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

      final String? displayName = _pickDisplayName(data);
      final String? email = _pickEmail(data);
      final String? address = _pickAddress(data);
      final String? photoUrl = _pickPhotoUrl(data);

      setState(() {
        _profileText = 'Name: $displayName\nEmail: $email\nAddress: $address\nPhoto: $photoUrl';
      });

    } catch (e) {
      setState(() {
        _profileText = 'Error fetching user profile: $e';
      });
      print('Error fetching user profile: $e');
    }
  }

  String? _pickAddress(Map<String, dynamic> data) {
    final List<dynamic>? addresses = data['addresses'] as List<dynamic>?;
    if (addresses != null && addresses.isNotEmpty) {
      final Map<String, dynamic>? address = addresses.first as Map<String, dynamic>?;
      return address?['formattedValue'] as String?;
    }
    return 'No address found';
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

  String? _pickPhotoUrl(Map<String, dynamic> data) {
    final List<dynamic>? photos = data['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final Map<String, dynamic>? photo = photos.first as Map<String, dynamic>?;
      return photo?['url'] as String?;
    }
    return 'No photo found';
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
      return Column(
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
