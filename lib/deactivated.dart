import 'package:flutter/material.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/styles.dart';

class DeactivatedScreen extends StatelessWidget {
  const DeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
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
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: boxDecorationBig,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Your Account is Deactivated!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: grey),
                      ),
                      Container(
                        child: Icon(Icons.sentiment_dissatisfied, size: 100, color: darkRed),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Oops! Looks like this account is temporary deactivated. You cannot access your account at this time.',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            onTap: () => _showReactivateDialog(context),
                            child: Text(
                              'Reactivate Account?',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: deepGreen,
                                  decoration: TextDecoration.underline,
                                  decorationColor: deepGreen),
                            )),
                      ),
                      SizedBox(height: 200),
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

  void _showReactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Reactivate', style: TextStyle(color: Colors.white)),
          content: Text('This will reactivate your account. And will back to be accessible again.',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                String? dbMsg = await reactivate();
                if (dbMsg == '200') {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, 'login');
                  showSuccessSnackBar(context, 'Account is now Reactivated!');
                } else {
                  showErrorSnackBar(context, 'Something went wrong. Please try again later!');
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
