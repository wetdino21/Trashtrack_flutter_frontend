import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';

class C_SettingsScreen extends StatefulWidget {
  @override
  State<C_SettingsScreen> createState() => _C_SettingsScreenState();
}

class _C_SettingsScreenState extends State<C_SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // final userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(10.0),
            decoration: boxDecorationBig,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //SizedBox(height: 50),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.dark_mode,
                          color: white,
                        )),
                    title: Text(
                      'Dark Mode',
                    ),
                    onTap: () {
                      setState(() {
                        deepGreen = Colors.black;
                        deepPurple = Colors.black;
                        darkPurple = Colors.black;
                      });
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.lock,
                          color: white,
                        )),
                    title: Text('Change password'),
                    onTap: () {
                      Navigator.pushNamed(context, 'change_pass');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.person_off,
                          color: white,
                        )),
                    title: Text('Deactivate Account'),
                    onTap: () {
                      // _dectivateAccount(context, userData);
                        _dectivateAccount(context);
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.account_circle,
                          color: white,
                        )),
                    title: Text('About us'),
                    onTap: () {
                      Navigator.pushNamed(context, 'about_us');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.error,
                          color: white,
                        )),
                    title: Text('Privacy policy'),
                    onTap: () {
                      Navigator.pushNamed(context, 'privacy_policy');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: deepPurple,
                        child: Icon(
                          Icons.description,
                          color: white,
                        )),
                    title: Text('Terms and conditions'),
                    onTap: () {
                      Navigator.pushNamed(context, 'terms');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.logout,
                          color: white,
                        )),
                    title: Text('Logout Account'),
                    onTap: () {
                      // Handle Logout
                      showLogoutConfirmationDialog(context);
                    },
                  ),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //deactivation confirm
  void _dectivateAccount(BuildContext context) {
    // Access the user data via Provider
    //BuildContext context, UserData userData

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: deepPurple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Deactivate', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to deactivate your account?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                //showErrorSnackBar(context, userData.email!);
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                // String? deactMsg =
                //     await deactivateUser(context, userData.email!);
                // if (deactMsg == 'success') {
                //   deleteTokens(context);

                //   Navigator.of(context).pop();
                //   Navigator.pushNamed(context, 'login');
                //   _showSuccessDeactivate(context);
                // } else {
                //   showErrorSnackBar(
                //       context, 'Something went wrong please try again later!');
                // }
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
