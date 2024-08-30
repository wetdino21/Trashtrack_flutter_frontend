import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/login.dart';
import 'package:trashtrack/Hauler/styles.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
                  'Profile',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        leading: SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/anime.jpg'),
            ),
            SizedBox(height: 10),
            Text(
              'Hauler Kim',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              'hauler@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),
          
            SizedBox(height: 50),
            TextFormField(
              initialValue: 'Hauler',
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: 'hauler@gmail.com',
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: '+63987889999',
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Set the current index to 3 for ProfileScreen
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, 'home');
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'notification');
          } else if (index == 3) {
            //Navigator.pushNamed(context, 'profile');
            return;
          }
        },
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
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, 'profile');
        }, icon: Icon(Icons.arrow_back)),
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10)),
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
                      'Hauler Kim',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Edit details',
                    style: TextStyle(color: Colors.white)),
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
                title:
                    Text('About us', style: TextStyle(color: Colors.white)),
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
       bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Set the current index to 3 for ProfileScreen
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, 'home');
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'notification');
          } else if (index == 3) {
            //Navigator.pushNamed(context, 'profile');
            return;
          }
        },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Yes', style: TextStyle(color: Colors.green)),
            ),
          ],
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
                    'Hauler Kim',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Divider(color: Colors.white),
                  EditProfileField(
                    label: 'Firstname',
                    initialValue: 'Hauler',
                  ),
                  EditProfileField(
                    label: 'Lastname',
                    initialValue: 'Kim',
                  ),
                  EditProfileField(
                    label: 'Email',
                    initialValue: 'hauler@gmail.com',
                  ),
                  EditProfileField(
                    label: 'Phone Number',
                    initialValue: '+639878899999',
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmChangeDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
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
          content: Text('Are you sure you want to change your profile details?',
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
