import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class C_ViewAllCollectionHistory extends StatelessWidget {
  const C_ViewAllCollectionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Collection History'),
      ),
      body: Container(),
    );
  }
}

class C_WasteColHistoryDetails extends StatelessWidget {
  const C_WasteColHistoryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Details'),
      ),
      body: Container(),
    );
  }
}

class C_WasteCollectionHistoryCard extends StatelessWidget {
  final String date;
  final String time;
  final String wasteType;

  C_WasteCollectionHistoryCard({
    required this.date,
    required this.time,
    required this.wasteType,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => C_WasteColHistoryDetails()));
      },
      splashColor: Colors.green,
      highlightColor: Colors.green.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        color: boxColor,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   color: boxColor,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF6AA920)),
                SizedBox(width: 10.0),
                Text(
                  date,
                  style: TextStyle(color: Colors.white70, fontSize: 16.0),
                ),
                SizedBox(width: 10.0),
                Text(
                  time,
                  style: TextStyle(color: Colors.white38, fontSize: 14.0),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              wasteType,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
