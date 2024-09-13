import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_api_userdata.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/styles.dart';

import 'dart:convert';
import 'dart:typed_data';

class C_ProfileScreen extends StatefulWidget {
  @override
  State<C_ProfileScreen> createState() => _C_ProfileScreenState();
}

class _C_ProfileScreenState extends State<C_ProfileScreen> {
  //user data
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  Uint8List? imageBytes; // To store the image bytes

  @override
  void initState() {
    super.initState();
    _dbData();
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      final data = await fetchCusData(context);
      setState(() {
        userData = data;
        isLoading = false;

        // Decode base64 image only if it exists
        if (userData?['profileImage'] != null) {
          imageBytes = base64Decode(userData!['profileImage']);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (userData != null && userData!['profileImage'] != null) {
      imageBytes = base64Decode(userData!['profileImage']);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: accentColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, 'c_home');
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _dbData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : userData != null
                ? ListView(
                   // padding: const EdgeInsets.all(16.0),
                    children: [
                      Column(
                        children: [
                          imageBytes != null
                              ? Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  color: accentColor
                                ),
                                child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: MemoryImage(imageBytes),
                                  ),
                              )
                              : Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                          SizedBox(height: 10),
                          // Text(
                          //   '${userData?['cus_fname'] ?? ''} ${userData?['cus_mname'] ?? ''} ${userData?['cus_lname'] ?? ''}'
                          //           .trim()
                          //           .isEmpty
                          //       ? 'Active'
                          //       : '${userData?['cus_fname'] ?? ''} ${userData?['cus_mname'] ?? ''} ${userData?['cus_lname'] ?? ''}',
                          //   style: TextStyle(fontSize: 24, color: accentColor),
                          // ),
                          // Text(
                          //   userData?['cus_email'] ?? 'Active',
                          //   style: TextStyle(color: Colors.white),
                          // ),
                          SizedBox(height: 10),
                          Container(
                            color: backgroundColor,
                            child: Column(
                              children: [
                               SizedBox(height: 30),
                                ProfileDetailRow(
                                    label: 'Full Name',
                                    value: '${userData?['cus_fname'] ?? ''} ${userData?['cus_mname'] ?? ''} ${userData?['cus_lname'] ?? ''}'),
                                ProfileDetailRow(
                                    label: 'Email',
                                    value: userData?['cus_email'] ?? ''),
                                ProfileDetailRow(
                                    label: 'Phone Number',
                                    value: userData?['cus_phone'] ?? ''),
                                ProfileDetailRow(
                                    label: 'Address',
                                    value: userData?['cus_address'] ?? ''),
                                ProfileDetailRow(
                                    label: 'Status',
                                    value: userData?['cus_status'] ?? 'Active'),
                                ProfileDetailRow(
                                    label: 'Type',
                                    value: userData?['cus_type'] ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(child: Text('Error: $errorMessage')),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
           Divider(),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        //iconTheme: IconThemeData(color: accentColor),
        title: Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 10),
            Text('Settings'),
          ],
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'c_profile');
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/anime.jpg'), // Replace with your image asset path
                      radius: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'customer Kim',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                title:
                    Text('Edit details', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  // Handle Edit Profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()),
                  );
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Change password',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.pushNamed(context, 'change_pass');
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Deactivate Account',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  _dectivateAccount(context);
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('About us', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.pushNamed(context, 'about_us');
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Privacy policy',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.pushNamed(context, 'privacy_policy');
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Terms and conditions',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.pushNamed(context, 'terms');
                },
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Logout Account',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  // Handle Logout
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Logout', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to log out?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                deleteTokens(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => LoginPage()),
                // );
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //deactivation confirm
  void _dectivateAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Deactivate', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to deactivate your account?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, 'login');
                _showSuccessDeactivate(context);
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //success deactivation
  void _showSuccessDeactivate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                'Account Deactivated!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'Your Account has now successfully deactivated.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, 'login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/anime.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  'customer Kim',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Divider(color: Colors.white),
                EditProfileField(
                  label: 'First Name',
                  initialValue: 'customer',
                ),
                EditProfileField(
                  label: 'Middle Name',
                  initialValue: '',
                ),
                EditProfileField(
                  label: 'Last Name',
                  initialValue: 'Kim',
                ),
                EditProfileField(
                  label: 'Email',
                  initialValue: 'customer@gmail.com',
                ),
                EditProfileField(
                  label: 'Phone Number',
                  initialValue: '+639878899999',
                ),
                EditProfileField(
                  label: 'Address',
                  initialValue: '123 customer Street',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmChangeDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Confirm Changes', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to save changes to your profile details?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showConfirmationDialog(context);
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                'Profile Saved!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'Your information details has been successfully changed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Continue updating details or other actions here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditProfileField extends StatelessWidget {
  final String label;
  final String initialValue;

  EditProfileField({required this.label, required this.initialValue});

  @override
  Widget build(BuildContext context) {
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
            initialValue: initialValue,
            //style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              filled: true,
              //fillColor: Colors.grey[800],
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
}
