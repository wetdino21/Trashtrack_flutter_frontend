import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/appbar.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';

class VehicleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Vehicle'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Your Current vehicle'),
            SizedBox(height: 20),
            // Truck image
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/truck.png'), // Replace with your truck image asset path
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            SizedBox(height: 20),
            // Vehicle Details
            VehicleDetailRow(
              label: 'Plate Number',
              value: 'ABC-1234',
            ),
            VehicleDetailRow(
              label: 'Type',
              value: 'Garbage Truck',
            ),
            VehicleDetailRow(
              label: 'Status',
              value: 'Active',
            ),
            VehicleDetailRow(
              label: 'Capacity',
              value: '10 tons',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, 'home');
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'schedule');
          } else if (index == 3) {
            return;
          }
        },
      ),
    );
  }
}

class VehicleDetailRow extends StatelessWidget {
  final String label;
  final String value;

  VehicleDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
