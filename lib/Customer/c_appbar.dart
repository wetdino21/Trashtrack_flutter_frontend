import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';
import 'dart:convert'; // for base64 decoding
import 'dart:typed_data'; // for Uint8List

class C_CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Map<String, dynamic>? userData;

  C_CustomAppBar({required this.title, this.userData});
  
  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (userData != null && userData!['profileImage'] != null) {
      imageBytes = base64Decode(userData!['profileImage']);
    }

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
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
        userData != null
            ? InkWell(
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
                    border: Border.all(width: 2,color: Colors.green),
                  ),
                  child: imageBytes != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(imageBytes),
                        )
                      :Icon(Icons.person, size:30,),
                ),
              )
            : Container(
                margin: EdgeInsets.all(5),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person)),
        SizedBox(
          width: 15,
        )
      ],
      leading: SizedBox.shrink(),
      leadingWidth: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
