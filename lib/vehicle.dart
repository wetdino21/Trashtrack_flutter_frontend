import 'package:flutter/material.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class VehicleScreen extends StatefulWidget {
  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String? user;

  @override
  void initState() {
    super.initState();
    _dbData();
  }

  void _dbData() async {
    final data = await userDataFromHive();
    setState(() {
      user = data['user'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: ListView(
        children: [
          SizedBox(height: 20.0),

            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: boxDecorationBig,
              child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
               SizedBox(height: 20),
              Text('Your Assigned Vehicle', style: TextStyle(fontSize: 20),),
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
        ],
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
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}