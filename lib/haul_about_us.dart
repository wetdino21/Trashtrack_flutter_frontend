import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Container(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => asdsadad()));
          },
          child: Text('data'),
        ),
      ),
    );
  }
}

class asdsadad extends StatelessWidget {
  const asdsadad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Container(
        child: InkWell(
          onTap: () {},
          child: Text('data'),
        ),
      ),
    );
  }
}
