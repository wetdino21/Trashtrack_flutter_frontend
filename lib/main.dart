import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/appbar.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/about_us.dart';
import 'package:trashtrack/change_pass.dart';
import 'package:trashtrack/home.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/Customer/c_notification.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/profile.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/create_acc.dart';
import 'package:trashtrack/deactivated.dart';
import 'package:trashtrack/forgot_pass.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/privacy_policy.dart';
import 'package:trashtrack/splash_screen.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/suspended.dart';
import 'package:trashtrack/terms_conditions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserModel(), // Initialize UserModel without default values
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // for logout complex

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      //initialRoute: initialRoute,
      home: TokenCheck(), // final firt route
      //home: DynamicNetwork(), // for testing with network
      //home: PdfDownloader(), //for testing

      //home: WebsocketMultiple(), //for testing
      routes: {
        '/mainApp': (context) => MainApp(),
        '/logout': (context) => LoginPage(),
        'splash': (context) => SplashScreen(),
        'terms': (context) => TermsAndConditions(),
        'forgot_pass': (context) => const ForgotPassword(),
        'create_acc': (context) => CreateAcc(),
        'login': (context) => LoginPage(),
        'deactivated': (context) => const DeactivatedScreen(),
        'suspended': (context) => const SuspendedScreen(),
        'c_home': (context) => C_HomeScreen(),
        'c_map': (context) => C_MapScreen(),
        'c_schedule': (context) => C_ScheduleScreen(),
        'c_payment': (context) => C_PaymentScreen(),
        'c_about_us': (context) => C_AboutUs(),
        'c_notification': (context) => C_NotificationScreen(),
        'c_profile': (context) => C_ProfileScreen(),
      },
    );
  }
}

//check token when open app
class TokenCheck extends StatefulWidget {
  @override
  _TokenCheckState createState() => _TokenCheckState();
}

class _TokenCheckState extends State<TokenCheck> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    String initialRoute = await onOpenApp(context);

    if (initialRoute.isNotEmpty) {
      Navigator.pushReplacementNamed(context, initialRoute);
    } else {
      // Fallback to login if something goes wrong
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(action: 'login')),
        (Route<dynamic> route) => false,
      );

      //Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      body: MainApp(),

      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Text(
      //       'NO INTERNET CONNECTION',
      //       style: TextStyle(color: white, fontSize: 20),
      //     ),
      //     Center(
      //       child: Image.asset('assets/icon/trashtrack_icon_trans.png', scale: 3),
      //     ),
      //     ElevatedButton(
      //         onPressed: () {
      //           deleteTokens();
      //         },
      //         child: Text('Delete token')),
      //   ],
      // ),
    );
  }
}




// class WebsocketMultiple extends StatefulWidget {
//   @override
//   _WebsocketMultipleState createState() => _WebsocketMultipleState();
// }

// class _WebsocketMultipleState extends State<WebsocketMultiple> {
//   late IOWebSocketChannel channel;
//   List<String> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     channel = IOWebSocketChannel.connect('ws://192.168.254.187:8080'); // Connect to server

//     // Listen for incoming messages
//     channel.stream.listen((message) {
//       final decodedMessage = jsonDecode(message);
//       setState(() {
//         messages.add('Received ${decodedMessage['type']} message: ${decodedMessage['content']}');
//       });
//     });
//   }

//   // Send a message to the server
//   void sendMessage(String type, String content) {
//     final message = jsonEncode({
//       'type': type,
//       'content': content,
//     });
//     channel.sink.add(message);
//   }

//   @override
//   void dispose() {
//     channel.sink.close(); // Close WebSocket connection when the widget is disposed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('WebSocket Example')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(messages[index]),
//               ),
//             ),
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: 'Send chat message'),
//             onSubmitted: (text) => sendMessage('chat', text),
//           ),
//           ElevatedButton(
//             onPressed: () => sendMessage('notification', 'New notification from client!'),
//             child: Text('Send Notification'),
//           ),
//           ElevatedButton(
//             onPressed: () => sendMessage('update', 'Client update!'),
//             child: Text('Send Update'),
//           ),
//         ],
//       ),
//     );
//   }
// }

