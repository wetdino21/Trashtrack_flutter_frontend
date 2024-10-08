import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/data_model.dart';

//Customer library
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_about_us.dart';
import 'package:trashtrack/change_pass.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/Customer/c_notification.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/Customer/c_profile.dart';

//hauler library
import 'package:trashtrack/Hauler/Schedule.dart';
import 'package:trashtrack/Hauler/Vehicle.dart';
import 'package:trashtrack/Hauler/about_us.dart';
import 'package:trashtrack/Hauler/change_pass.dart';
import 'package:trashtrack/Hauler/home.dart';
import 'package:trashtrack/Hauler/map.dart';
import 'package:trashtrack/Hauler/notification.dart';
import 'package:trashtrack/Hauler/profile.dart';

import 'package:trashtrack/api_token.dart';

//global
import 'package:trashtrack/create_acc.dart';

import 'package:trashtrack/deactivated.dart';
import 'package:trashtrack/forgot_pass.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/privacy_policy.dart';
import 'package:trashtrack/splash_screen.dart';
import 'package:trashtrack/suspended.dart';
import 'package:trashtrack/terms_conditions.dart';
////asds
import 'package:hive_flutter/hive_flutter.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
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

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   runApp(MyApp());
//   // runApp(const MyApp());
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      //initialRoute: initialRoute,
       home: TokenCheck(), // final firt route
      //home: StoreNetwork(), // for testing with network

      //home: WebSocketExample(), //for testing
      //initialRoute: 'c_home', //for testing
      //initialRoute: 'splash', //for testing
      routes: {
        '/logout': (context) => LoginPage(),

        'splash': (context) => SplashScreen(),
        'terms': (context) => TermsAndConditions(),
        'forgot_pass': (context) => const ForgotPassword(),
        // 'email_verify': (context) => EmailVerification(),
        'create_acc': (context) => CreateAcc(),
        'login': (context) => const LoginPage(),
        'deactivated': (context) => const DeactivatedScreen(),
        'suspended': (context) => const SuspendedScreen(),
        //'change_pass': (context) => ChangePassword(),

        //Hauler Routes
        'home': (context) => HomeScreen(),
        'map': (context) => MapScreen(),
        'schedule': (context) => ScheduleScreen(),
        'vehicle': (context) => VehicleScreen(),
        //'change_pass': (context) => ChangePass(),
        'about_us': (context) => AboutUs(),
        'privacy_policy': (context) => PrivacyPolicy(),
        'notification': (context) => NotificationScreen(),
        'profile': (context) => ProfileScreen(),

        //Customer
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

class WebSocketExample extends StatefulWidget {
  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  //late WebSocketChannel channel;
  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.254.187:8080'),
  );

  // @override
  // void initState() {
  //   super.initState();
  //   // Connect to the WebSocket server
  //   channel = WebSocketChannel.connect(
  //     Uri.parse('ws://192.168.254.187:8080'),
  //   );
  // }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //return Text('Received: ${snapshot.data}');
              try {
                // Decode the incoming data from JSON string to Dart object
                List<String> notifications = []; // To store notifications
                final notification = json.decode(snapshot.data as String);
                notifications.add(notification['notif_message']);
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    //final notification = notifications[index];
                    return ListTile(
                      title: Text(notifications[index]),
                    );
                  },
                );
              } catch (e) {
                return Center(child: Text('Error decoding notifications: $e'));
              }
            } else {
              return Text('Waiting for messagessss...');
            }
          },
        ),
      ),
    );
  }
}

////////
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
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Center(
              child: Image.asset('assets/truck.png'),
            ),
            ElevatedButton(
                onPressed: () {
                  deleteTokens();
                },
                child: Text('delete token')),
          ],
        ), // Show a loading screen while checking the token
      ),
    );
  }
}
