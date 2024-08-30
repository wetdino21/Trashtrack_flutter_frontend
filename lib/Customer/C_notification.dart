import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/map.dart';
import 'package:trashtrack/Hauler/styles.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        //iconTheme: IconThemeData(color: Colors.green),
        foregroundColor: Colors.white,
        title: Text(
                  'Notification',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/anime.jpg'),
            ),
          )
        ],
        leading: SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NotificationCard(
              date: 'Thurs April 25',
              time: '8:30 AM',
              status: 'Ongoing',
              title: 'Food Waste',
              statusColor: Colors.red,
            ),
            SizedBox(height: 16),
            NotificationCard(
              date: 'Wed Jun 20',
              time: '8:30 AM',
              status: '',
              title: 'Municipal Waste',
              statusColor: Colors.transparent,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Set the current index to 2 for NotificationScreen
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, 'home');
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            //Navigator.pushNamed(context, 'notification');
            return;
          } else if (index == 3) {
            Navigator.pushNamed(context, 'profile');
          }
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String date;
  final String time;
  final String title;
  final String status;
  final Color statusColor;

  NotificationCard({
    required this.date,
    required this.time,
    required this.title,
    this.status = '',
    this.statusColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Notification"),
              content: Text("Would you like to proceed to the map?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  },
                  child: Text("Proceed"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: Colors.grey, size: 16),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$date  $time', style: TextStyle(color: Colors.grey)),
                if (status.isNotEmpty)
                  Text('Status: $status', style: TextStyle(color: statusColor)),
                Text(title,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
