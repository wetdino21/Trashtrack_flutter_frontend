import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
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
            Navigator.pushNamed(context, 'notification');
          },
          
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 40, 
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[900], // Background color
              shape: BoxShape.circle, // Make the container circular
            ),
            child: Icon(
              Icons.notifications, // Use the correct icon name
              color: Colors.white,
              size: 30, // Size of the icon
            ),
          ),
        ),
         InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'profile');
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
            child: CircleAvatar(backgroundImage: AssetImage('assets/anime.jpg'),),
          ),
        ),
        SizedBox(width: 15,)
      ],
      leading: SizedBox.shrink(),
      leadingWidth: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
