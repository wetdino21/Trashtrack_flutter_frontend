import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/appbar.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/waste_history_schedule.dart';
import 'package:trashtrack/Hauler/waste_pickup_schedule.dart';
import 'package:trashtrack/styles.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Home'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Container
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Taehyung!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Another waste collection day. Drive safe!',
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

            // Statistic Boxes
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: [
                StatisticBox(
                  icon: Icons.schedule,
                  title: 'Total Pickups',
                  value: '150',
                  iconColor: Colors.blueAccent,
                ),
                StatisticBox(
                  icon: Icons.delete,
                  title: 'Total Tons of \nGarbage Pickups',
                  value: '75',
                  iconColor: Colors.redAccent,
                ),
                StatisticBox(
                  icon: Icons.assignment,
                  title: 'Contractual Pickups',
                  value: '100',
                  iconColor: Colors.greenAccent,
                ),
                StatisticBox(
                  icon: Icons.assignment_late,
                  title: 'Non-Contractual \nPickups',
                  value: '50',
                  iconColor: Colors.orangeAccent,
                ),
              ],
            ),

            SizedBox(height: 20.0),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, 
        onTap: (int index) {
          if (index == 0) {
            return;
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'schedule');
          } else if (index == 3) {
            Navigator.pushNamed(context, 'vehicle');
          }
        },
      ),
    );
  }
}

class StatisticBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  StatisticBox({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30.0,
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.0,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
