import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class ServiceGuidelines extends StatefulWidget {
  const ServiceGuidelines({super.key});

  @override
  State<ServiceGuidelines> createState() => _ServiceGuidelinesState();
}

class _ServiceGuidelinesState extends State<ServiceGuidelines> {
  final ScrollController _scrollController = ScrollController();
  double _position = 0;
  bool _isTruckAnimating = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isTruckAnimating && _isScrolledToEnd()) {
      _startTruckAnimation();
    }
  }

  bool _isScrolledToEnd() {
    return _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50;
  }

  void _startTruckAnimation() async {
    setState(() {
      _isTruckAnimating = true;
      _position = MediaQuery.of(context).size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: Text('Service and Guidelines'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Service Overview'),
                      _buildSectionContent(
                          'Our waste collection services are designed to meet the needs of both residential and commercial clients. '
                          'We strive to provide a reliable and eco-friendly service that contributes to a cleaner community.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('General Guidelines'),
                      _buildSectionContent(
                          '• Ensure waste is securely packed and placed in designated areas for pickup.\n'
                          '• Separate recyclable materials from non-recyclable waste.\n'
                          '• Hazardous waste should be handled according to local regulations and may require special disposal arrangements.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Service Hours'),
                      _buildSectionContent(
                          'Our standard service hours are from 8:00 AM to 5:00 PM on weekdays. Weekend services are available on request with prior scheduling.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Pickup Scheduling'),
                      _buildSectionContent(
                          '• Schedule your pickup at least 24 hours in advance.\n'
                          '• Same-day pickups are available for an additional fee.\n'
                          '• Ensure access to the pickup location is clear and unobstructed during the scheduled time.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Payment Terms'),
                      _buildSectionContent(
                          'We offer multiple payment options for your convenience. Payments are required before the scheduled pickup, '
                          'and a receipt will be provided upon completion of service.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Cancellation Policy'),
                      _buildSectionContent(
                          '• Cancellations made at least 12 hours before the scheduled time are eligible for a full refund.\n'
                          '• Cancellations made within 12 hours are subject to a partial refund.\n'
                          '• No refunds are available for missed pickups due to customer unavailability.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Safety and Compliance'),
                      _buildSectionContent(
                          'Our team is trained to follow all safety protocols to ensure a safe and compliant waste collection process. '
                          'We adhere to local and federal regulations regarding waste management and environmental protection.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Contact and Support'),
                      _buildSectionContent(
                          'If you have questions or need assistance, our support team is here to help. Contact us through the app or '
                          'visit our website for more information.'),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 2),
              left: _position,
              bottom: 0,
              child: Image.asset(
                'assets/icon/trashtrack_car.png',
                scale: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: greenSoft,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: white,
          height: 1.6,
        ),
      ),
    );
  }
}
