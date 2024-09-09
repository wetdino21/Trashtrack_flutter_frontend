import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/styles.dart';

class C_NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text(
                  'Notification',
                  style: TextStyle(
                    
                  ),
                ),
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
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(builder: (context) => C_MapScreen()),
                    // );
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
          color: boxColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: accentColor, size: 16),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$date  $time', style: TextStyle(color: Colors.grey[300])),
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
