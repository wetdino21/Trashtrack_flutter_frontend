import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';

class C_MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: C_CustomAppBar(title: 'Map'),
      body: Stack(
        children: [
          // Placeholder for the map
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                'Map goes here',
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ),
          SlidingUpPanel(
            minHeight: 40,
            maxHeight: MediaQuery.of(context).size.height / 2.9,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            panel: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nearest Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  RouteCard(
                    title: 'Bacayan De Oro',
                    arrivalTime: '10:30',
                    isHighlighted: true,
                  ),
                  RouteCard(
                    title: 'Bacayan Del Norte',
                    arrivalTime: '10:35',
                  ),
                  RouteCard(
                    title: 'Norman ATM',
                    arrivalTime: '11:00',
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Okay button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      ),
                      child: Text(
                        'Okay',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: C_BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String title;
  final String arrivalTime;
  final bool isHighlighted;

  RouteCard({
    required this.title,
    required this.arrivalTime,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green[900] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? null : Border.all(color: Colors.green[900]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_pin,
                color: isHighlighted ? Colors.white : Colors.green[900],
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.green[900],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Arrival $arrivalTime',
            style: TextStyle(
              color: isHighlighted ? Colors.white : Colors.green[900],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
