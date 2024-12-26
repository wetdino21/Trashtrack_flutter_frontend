import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/API/api_user_data.dart';
import 'dart:convert';
import 'dart:io';

import 'package:trashtrack/main.dart';
import 'package:trashtrack/styles.dart';

String extractIpAddress(String url) {
  // Remove the protocol
  String withoutProtocol = url.replaceFirst(RegExp(r'http://'), '');
  // Remove the port if present
  String ipAddress = withoutProtocol.split(':')[0];
  return ipAddress;
}
////////////////////////////////////////////////////////////////////////
//final String baseUrl = 'http://localhost:3000';

//http://192.168.119.156
globalAddressUrl() {
  return 'https://psgc.gitlab.io/api';
}

//my pc
globalUrl() {
  return 'http://192.168.254.187:3000';
}

////my phone data
// globalUrl() {
//   return 'http://192.168.119.156:3000';
// }

// //emulator
// globalUrl() {
//   return 'http://10.0.2.2:3000';
// }

//// CTU network
// globalUrl() {
//   return 'http://172.16.14.83:3000';
// }

// // ngrok network
// globalUrl() {
//   return 'https://a0b9-216-247-23-119.ngrok-free.app';
// }

////// COMMENT THIS IF IP STATIC ///////////////////////////////////////////////////////////////////
String? networkURL;

class NetworkglobalUrl {
  NetworkglobalUrl._privateConstructor();

  static final NetworkglobalUrl _instance = NetworkglobalUrl._privateConstructor();

  String? _baseUrl;

  factory NetworkglobalUrl() {
    return _instance;
  }

  void setBaseUrl(String ipAddress) {
    _baseUrl = 'http://$ipAddress:3000';
    networkURL = _baseUrl!;
  }

  String? getBaseUrl() {
    return _baseUrl ?? networkURL;
  }
}

// //dynamic url
// globalUrl() {
//   return networkURL;
// }

//for storing network on open
class DynamicNetwork extends StatefulWidget {
  @override
  _DynamicNetworkState createState() => _DynamicNetworkState();
}

class _DynamicNetworkState extends State<DynamicNetwork> {
  TextEditingController _networkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNetworkExist();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _networkController.dispose();
  }

  Future<void> _checkNetworkExist() async {
    String? BaseUrl = NetworkglobalUrl().getBaseUrl();

    if (BaseUrl != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TokenCheck()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      body: Center(
        child: Column(
          children: [
            Center(
              child: Image.asset('assets/truck.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Type the PC SERVER NETWORK IP ADDRESS',
              style: TextStyle(fontSize: 15, color: white),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              decoration: boxDecorationBig,
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
                    controller: _networkController,
                  ),
                ],
              ),
            ),
            InkWell(
                onTap: () {
                  if (_networkController.text.isNotEmpty) {
                    // Set the IP address in the singleton
                    NetworkglobalUrl().setBaseUrl(_networkController.text);
                    // String? baseUrl = NetworkglobalUrl().getBaseUrl();
                    // showErrorSnackBar(context, baseUrl!);
                    // Navigate to the next screen
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TokenCheck()));
                  }
                },
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius15,
                      color: deepGreen,
                    ),
                    child: Text('Set Network', style: TextStyle(fontSize: 20, color: white)))),
          ],
        ), // Show a loading screen while checking the token
      ),
    );
  }
}
