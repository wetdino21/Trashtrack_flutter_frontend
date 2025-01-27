import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'package:trashtrack/API/api_token.dart';
import 'package:trashtrack/Customer/account_verification.dart';
import 'package:trashtrack/bind_account.dart';
import 'package:trashtrack/change_pass.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class C_SettingsScreen extends StatefulWidget {
  @override
  State<C_SettingsScreen> createState() => _C_SettingsScreenState();
}

class _C_SettingsScreenState extends State<C_SettingsScreen> {
  UserModel? userModel;
  bool loadingAction = false;
  String? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _dbData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  Future<void> _dbData() async {
    if (!mounted) return;
    setState(() {
      loadingAction = true;
    });

    try {
      final data = await userDataFromHive();
      if (!mounted) return;
      setState(() {
        userData = data;
        user = data['user'];
      });

      if (!mounted) return;
      setState(() {
        loadingAction = false;
      });
    } catch (e) {
      console(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                margin: EdgeInsets.all(16.0),
                //padding: EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: boxDecorationBig,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      ListTile(
                        leading: _buildIcon(Icons.dark_mode),
                        title: Text(
                          deepPurple == Colors.deepPurple ? 'Dark Mode' : 'Default Theme',
                        ),
                        onTap: () {
                          if (deepPurple == Colors.deepPurple) {
                            setState(() {
                              deepGreen = Colors.black;
                              deepPurple = Colors.black;
                              darkPurple = Colors.black;
                            });
                          } else {
                            setState(() {
                              deepGreen = Color(0xFF388E3C);
                              deepPurple = Colors.deepPurple;
                              darkPurple = Color(0xFF3A0F63);
                            });
                          }
                        },
                      ),
                      if (user == 'customer')
                        ListTile(
                          leading: _buildIcon(Icons.account_box),
                          title: Text('Account Verification'),
                          onTap: () async {
                            setState(() {
                              loadingAction = true;
                            });

                            String? verify = await checkVerifiedCus(context);
                            if (verify == 'verified') {
                              if (!mounted) return;
                              showSuccessSnackBar(context, 'Your account is already verified!');
                            } else if (verify == 'pending') {
                              if (!mounted) return;
                              showSuccessSnackBar(context,
                                  'Your account verification is in progress. We will notify you once it' 's complete!');
                            } else if (verify == 'unverified') {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyCustomer(),
                                ),
                              );
                            } else if (verify == 'rejected') {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateVerifyCus(),
                                ),
                              );
                            }

                            setState(() {
                              loadingAction = false;
                            });
                          },
                        ),
                      if (userModel != null)
                        ListTile(
                          leading: _buildIcon(Icons.link),
                          title: Text('Bind Account'),
                          onTap: () {
                            if (userModel!.auth == 'TRASHTRACK') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BindWithGoogleScreen(email: userModel!.email!),
                                ),
                              );
                            } else if (userModel!.auth == 'GOOGLE') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BindWithTrashTrackScreen(email: userModel!.email!),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BindWithNothing(),
                                ),
                              );
                            }
                          },
                        ),
                      ListTile(
                        leading: _buildIcon(Icons.lock),
                        title: Text('Change password'),
                        onTap: () {
                          _showChangePassConfirmDialog(context);
                        },
                      ),
                      ListTile(
                        leading: _buildIcon(Icons.person_off),
                        title: Text('Deactivate Account'),
                        onTap: () {
                          _dectivateAccount(context);
                        },
                      ),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            boxShadow: shadowIconColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: white,
                          ),
                        ),
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
          if (loadingAction) showLoadingAction(),
        ],
      ),
    );
  }

  //show no pass
  void _showNoPassConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('No Password', style: TextStyle(color: Colors.white)),
          content: Text(
              'Looks like your account is a Google Account. Do you want to bind and create a password instead?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BindWithTrashTrackScreen(email: userModel!.email!),
                  ),
                );
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //show no pass
  void _showChangePassConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Change Password?', style: TextStyle(color: Colors.white)),
          content: Text('This will send email verification for security.', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                if (userModel!.auth == 'GOOGLE') {
                  _showNoPassConfirmDialog(context);
                } else {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePassword(email: userModel!.email!),
                    ),
                  );
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //for icon tile
  Widget _buildIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: deepPurple,
        boxShadow: shadowIconColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(
        icon,
        color: white,
      ),
    );
  }

  //deactivation confirm
  void _dectivateAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Deactivate', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure to deactivate your account?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  loadingAction = true;
                });

                String? deactMsg = await deactivateUser(context, userModel!.email!);
                if (deactMsg == 'success') {
                  deleteTokens();

                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, 'login');
                  _showSuccessDeactivate(context);
                } else {
                  Navigator.of(context).pop();
                  showErrorSnackBar(context, 'Something went wrong please try again later!');
                }

                setState(() {
                  loadingAction = false;
                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                //showErrorSnackBar(context, userData.email!);
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
