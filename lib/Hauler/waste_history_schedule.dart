import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class ViewAllCollectionHistory extends StatelessWidget {
  const ViewAllCollectionHistory({super.key});

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

class WasteColHistoryDetails extends StatelessWidget {
  const WasteColHistoryDetails({super.key});

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

class WasteCollectionHistoryCard extends StatelessWidget {
  final String date;
  final String time;
  final String wasteType;
  final String status;

  WasteCollectionHistoryCard({
    required this.date,
    required this.time,
    required this.wasteType,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => WasteColHistoryDetails()));
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
                Icon(Icons.history, color: Color(0xFF6AA920)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  wasteType,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                Text(
                  status,
                  style: TextStyle(color: accentColor, fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
