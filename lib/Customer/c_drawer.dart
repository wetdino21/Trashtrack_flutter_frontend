import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_profile.dart';
import 'package:trashtrack/styles.dart';
import 'dart:typed_data'; // for Uint8List
import 'package:trashtrack/user_date.dart';

class C_Drawer extends StatefulWidget {
  const C_Drawer({super.key});

  @override
  State<C_Drawer> createState() => _C_DrawerState();
}

class _C_DrawerState extends State<C_Drawer> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

    Future<void> _loadProfileImage() async {
    final data = await userDataFromHive();
    setState(() {
       imageBytes = data['profile'];
    });
   
    //  String? base64Image = await fetchProfile(context);
    //   if (base64Image != null) {
    //     setState(() {
    //       imageBytes = base64Decode(base64Image);
    //     });
    //   }

   // await box.close();
  }

  @override
  Widget build(BuildContext context) {
   return SafeArea(
      child: Drawer(
        width:  MediaQuery.of(context).size.width * 0.85,
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
                  : Icon(
                      Icons.person,
                      size: 30,
                    ),
              title: Row(
                children: [
                  Text('first name', style: TextStyle(fontWeight: FontWeight.bold),),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
              trailing: IconButton(
                //padding: EdgeInsets.all(20),
                icon: Icon(Icons.settings, size: 35,),
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => C_ProfileScreen()));
              },
            ),
            // Expanded List Section
            Expanded(
              child: ListView(
                children: [

                  //home
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home)),
                    title: Text('Home'),
                    selectedColor: Colors.green,
                    tileColor: Colors.black12,
                    onTap: () {
                      // Home action
                      Navigator.pop(context);
                    },
                  ),

                  //2
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home)),
                    title: Text('Home2'),
                    selectedColor: Colors.green,
                    //tileColor: Colors.black12,
                    onTap: () {
                      // Home action
                      Navigator.pop(context);
                    },
                  ),

                  //
                   ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home)),
                    title: Text('Home3'),
                    selectedColor: Colors.green,
                    //tileColor: Colors.black12,
                    onTap: () {
                      // Home action
                      Navigator.pop(context);
                    },
                  ),

                  //
                   ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home)),
                    title: Text('Home4'),
                    selectedColor: Colors.green,
                    //tileColor: Colors.black12,
                    onTap: () {
                      // Home action
                      Navigator.pop(context);
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
}
