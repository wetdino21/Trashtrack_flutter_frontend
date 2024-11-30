import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
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
        title: Text('Terms and Conditions'),
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
                      _buildSectionTitle('Acceptance of Terms'),
                      _buildSectionContent(
                          'By using our booking services, you agree to comply with these terms and conditions. If you do not agree, please refrain from using the service.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('User Responsibilities'),
                      _buildSectionContent('• Ensure all booking details provided are accurate.\n'
                          '• Comply with local regulations regarding waste management.\n'
                          '• Do not use the service for unlawful activities.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Booking Policies'),
                      _buildSectionContent(
                          '• Once a booking is submitted, it will be marked as pending. You may edit or cancel the booking at this stage.\n'
                          '• Once the hauler accepts the booking and is on the way to your location, the booking can no longer be edited or canceled.\n'
                          '• If the hauler has already accepted the booking and is on the way, cancellation will only be considered under special circumstances (such as emergencies), and a fee may apply.\n'
                          '• A cancellation request can be made through customer support, subject to review.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Fees and Payments'),
                      _buildSectionContent(
                          '• Payments are due after the waste has been weighed and the final bill has been generated. You can pay via PayMongo or cash on the spot.\n'
                          '• Failure to make payment after the weight has been confirmed may result in the suspension of future bookings.\n'
                          '• If you choose to pay via PayMongo, you will be redirected to the payment gateway.\n'
                          '• Cash payments should be made directly to the hauler once the waste is weighed and the bill is issued.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Termination of Services'),
                      _buildSectionContent(
                          'We reserve the right to suspend or terminate services if these terms are violated. In cases of non-payment after waste weighing, access to further bookings may be restricted.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Changes to Terms'),
                      _buildSectionContent(
                          'We may update these terms from time to time. Continued use of our booking services following such changes signifies your acceptance of the revised terms.'),
                      SizedBox(height: 20),
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
