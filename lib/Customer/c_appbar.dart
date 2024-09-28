import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';
import 'dart:typed_data'; // for Uint8List
import 'package:trashtrack/user_date.dart';

class C_CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  C_CustomAppBar({required this.title});

  @override
  _C_CustomAppBarState createState() => _C_CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _C_CustomAppBarState extends State<C_CustomAppBar> {
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
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.title,
        style: TextStyle(
          color: accentColor,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'c_notification');
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[900],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'c_profile');
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[900],
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Colors.green),
            ),
            child: imageBytes != null
                ? CircleAvatar(
                    backgroundImage: MemoryImage(imageBytes!),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                  ),
          ),
        ),
        SizedBox(
          width: 15,
        )
      ],
      // leading: SizedBox.shrink(),
      // leadingWidth: 0,
    );
  }
}
