import 'package:flutter/material.dart';

class DeactivatedScreen extends StatelessWidget {
  const DeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deactivated'),
      ),
      body: Container(),
    );
  }
}