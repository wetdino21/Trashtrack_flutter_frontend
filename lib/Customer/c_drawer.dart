import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_contact.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/Customer/c_profile.dart';
import 'package:trashtrack/Customer/c_settings.dart';
import 'package:trashtrack/Customer/c_about_us.dart';
import 'package:trashtrack/privacy_policy.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/terms_conditions.dart';
import 'dart:typed_data'; // for Uint8List
import 'package:trashtrack/user_hive_data.dart';

class C_Drawer extends StatefulWidget {
  final int? currentIndex; // Optional index parameter

  const C_Drawer({super.key, this.currentIndex}); // Accept currentIndex

  @override
  State<C_Drawer> createState() => _C_DrawerState();
}

class _C_DrawerState extends State<C_Drawer> {
  Uint8List? imageBytes;
  Map<String, dynamic>? userData;
  int? selectedIndexs;

  @override
  void initState() {
    super.initState();
    _dbData();

    selectedIndexs = widget.currentIndex ?? 0;
  }

  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      if (!mounted) return;
      setState(() {
        imageBytes = data['profile'];
        userData = data;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Header Section
            ListTile(
              minTileHeight: 70,
              leading: imageBytes != null
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(imageBytes!),
                    )
                  : Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: shadowColor,
                          color: deepGreen),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: white,
                      ),
                    ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      userData != null
                          ? '${userData!['fname']} ${userData!['lname']}'
                          : 'Loading . . .',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 35,
                  color: deepPurple,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => C_SettingsScreen()));
                },
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => C_ProfileScreen()));
              },
            ),
            // Expanded List Section
            Expanded(
              child: ListView(
                children: [
                  // Home
                  ListTile(
                    leading: _buildIcon(Icons.home),
                    title: Text('Home'),
                    selectedColor: Colors.green,
                    tileColor: selectedIndexs == 0 ? Colors.black12 : null,
                    onTap: () {
                      // Navigate to home
                      if (selectedIndexs != 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => C_HomeScreen()));
                      }

                      // selectedIndexs == 0
                      //     ? Navigator.pop(context)
                      //     : Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => C_HomeScreen()));
                    },
                  ),
                  // // Contract
                  // ListTile(
                  //   leading: _buildIcon(Icons.content_paste_search_sharp),
                  //   title: Text('Contract'),
                  //   selectedColor: Colors.green,
                  //   tileColor: selectedIndexs == 1 ? Colors.black12 : null,
                  //   onTap: () {
                  //     if (selectedIndexs != 1) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => C_ContractScreen()),
                  //       );
                  //     }
                  //   },
                  // ),
                  // About Us
                  ListTile(
                    leading: _buildIcon(Icons.account_circle),
                    title: Text('About Us'),
                    selectedColor: Colors.green,
                    tileColor: selectedIndexs == 2 ? Colors.black12 : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => C_AboutUs()),
                      );
                    },
                  ),
                  // Terms and Conditions
                  ListTile(
                    leading: _buildIcon(Icons.description),
                    title: Text('Terms and Conditions'),
                    selectedColor: Colors.green,
                    tileColor: selectedIndexs == 3 ? Colors.black12 : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditions()),
                      );
                    },
                  ),
                  // Privacy Policy
                  ListTile(
                    leading: _buildIcon(Icons.error),
                    title: Text('Privacy Policy'),
                    selectedColor: Colors.green,
                    tileColor: selectedIndexs == 4 ? Colors.black12 : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicy()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build icon container
  Widget _buildIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: deepPurple,
        boxShadow: shadowColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(
        icon,
        color: white,
      ),
    );
  }
}
