import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
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
        title: Text('Privacy and Policy'),
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
                      _buildSectionTitle('Introduction'),
                      _buildSectionContent(
                          'This Privacy Policy explains how Trashtrack collects, uses, and shares your information when you use our services. We are committed to safeguarding your privacy and ensuring that your data is protected.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Data Collection'),
                      _buildSectionContent(
                          'We collect information that you provide directly to us, such as your name, email address, and contact information when you register for our services. We also collect data related to your interactions with our app to improve our services.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Use of Data'),
                      _buildSectionContent(
                          '• To provide and maintain our services.\n'
                          '• To communicate with you about your account or transactions.\n'
                          '• To improve our app and user experience.\n'
                          '• To comply with legal obligations and protect against potential security threats.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Data Sharing'),
                      _buildSectionContent(
                          'We may share your information with third-party providers who assist us in providing our services. We ensure that these providers comply with strict data protection policies to safeguard your data.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Data Security'),
                      _buildSectionContent(
                          'We implement appropriate security measures to protect your information from unauthorized access, alteration, or disclosure. However, no method of transmission over the internet is completely secure, and we cannot guarantee absolute security.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Your Rights'),
                      _buildSectionContent(
                          'You have the right to access, correct, or delete your personal data at any time. If you wish to exercise these rights or have any questions about our data practices, please contact us.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Changes to Privacy Policy'),
                      _buildSectionContent(
                          'We may update this Privacy Policy from time to time. Any changes will be posted on this page, and we encourage you to review it regularly to stay informed about our data practices.'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Contact Us'),
                      _buildSectionContent(
                          'If you have any questions or concerns regarding this Privacy Policy, feel free to contact us.'),
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
