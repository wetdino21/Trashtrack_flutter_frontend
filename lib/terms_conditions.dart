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
                          'By using our services, you agree to be bound by these terms and conditions. If you do not agree, please do not use our services.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('User Responsibilities'),
                      _buildSectionContent('• Provide accurate and complete information during registration.\n'
                          '• Comply with all local and federal laws regarding waste management and disposal.\n'
                          '• Do not use our services for any unlawful or prohibited activities.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Account Security'),
                      _buildSectionContent(
                          'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately if you suspect any unauthorized access.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Service Limitations'),
                      _buildSectionContent(
                          'We reserve the right to modify or discontinue our services at any time without prior notice. We are not liable for any inconvenience or loss caused by such actions.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Fees and Payments'),
                      _buildSectionContent(
                          'All payments must be made in accordance with the rates provided. Failure to make timely payments may result in the suspension of your account or services.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Intellectual Property'),
                      _buildSectionContent(
                          'All content, logos, and trademarks on this platform are the property of Trashtrack. Unauthorized use of these assets is strictly prohibited.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Termination of Services'),
                      _buildSectionContent(
                          'We reserve the right to terminate or suspend your account if you violate these terms. You may also choose to terminate your account at any time by contacting support.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Changes to Terms'),
                      _buildSectionContent(
                          'We may update these terms from time to time. Continued use of our services following such changes signifies your acceptance of the new terms.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Contact Information'),
                      _buildSectionContent(
                          'For any questions regarding these terms, please contact our support team through the app or our website.'),
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
