import 'package:flutter/material.dart';
import 'package:trashtrack/contact_us.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:trashtrack/terms_conditions.dart';

class SuspendedScreen extends StatelessWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkRed,
      appBar: AppBar(
        backgroundColor: darkRed,
        foregroundColor: white,
      ),
      body: ListView(
        children: [
          PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) {
                  return;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Container()),
          SizedBox(height: 20),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  //width: double.infinity,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: boxDecorationBig,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Your Account is Suspended!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: grey),
                      ),
                      Container(
                        child: Icon(Icons.sentiment_very_dissatisfied, size: 100, color: redSoft),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'We\'re sorry, but your account has been suspended. You cannot access your account at this time.',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Steps:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // Aligns the icon and text properly
                            children: [
                              Icon(Icons.circle, size: 8),
                              SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                    children: [
                                      TextSpan(text: 'Review our '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: deepGreen,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => TermsAndConditions()));
                                          },
                                      ),
                                      TextSpan(text: ' for more details.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // Aligns the icon and text properly
                            children: [
                              Icon(Icons.circle, size: 8),
                              SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                    children: [
                                      TextSpan(text: 'Contact our support team '),
                                      TextSpan(
                                        text: 'TrashTrack',
                                        style: TextStyle(
                                          color: deepGreen,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => ContactUsScreen()));
                                          },
                                      ),
                                      TextSpan(text: ' if you believe this is an error.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
