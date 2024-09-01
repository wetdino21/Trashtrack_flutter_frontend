import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/appbar.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/map.dart';
import 'package:trashtrack/Hauler/waste_col_history_details.dart';
import 'package:trashtrack/Hauler/waste_pickup_schedule.dart';
import 'package:trashtrack/styles.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Schedule'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Text(
                    'Ready for another waste pickup schedule?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PickUpSchedule(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 30.0),
                      ),
                      child: Text(
                        'Pickup Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),

            //Current Pickup Schedule
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                //color: boxColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: accentColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Your Ongoing Pickup Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  WasteCollectionCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Municipal Waste',
                  ),
                  WasteCollectionCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Construction Waste',
                  ),
                  WasteCollectionCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Construction Waste',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.0),

            //History collection
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                //color: boxColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Waste Collection History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewAllCollectionHistory()));
                        },
                         style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          ' View all',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  WasteCollectionHistoryCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Municipal Waste',
                  ),
                  WasteCollectionHistoryCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Construction Waste',
                  ),
                  WasteCollectionHistoryCard(
                    date: 'Wed Jun 20',
                    time: '8:30 AM',
                    wasteType: 'Construction Waste',
                  ),
                ],
              ),
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
            //Navigator.pushNamed(context, 'schedule');
            return;
          } else if (index == 3) {
            Navigator.pushNamed(context, 'vehicle');
          }
        },
      ),
    );
  }
}

class WasteCollectionHistoryCard extends StatelessWidget {
  final String date;
  final String time;
  final String wasteType;

  WasteCollectionHistoryCard({
    required this.date,
    required this.time,
    required this.wasteType,
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: boxColor,
        ),
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
