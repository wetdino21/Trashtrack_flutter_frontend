import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/appbar.dart';
import 'package:trashtrack/API/api_network.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/schedule.dart';
import 'package:trashtrack/about_us.dart';
import 'package:trashtrack/change_pass.dart';
import 'package:trashtrack/home.dart';
import 'package:trashtrack/map.dart';
import 'package:trashtrack/Customer/notification.dart';
import 'package:trashtrack/Customer/payment.dart';
import 'package:trashtrack/profile.dart';
import 'package:trashtrack/API/api_token.dart';
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
      
      routes: {
        '/mainApp': (context) => MainApp(),
        '/logout': (context) => LoginPage(),
        'splash': (context) => SplashScreen(),
        'terms': (context) => TermsAndConditions(),
        'forgot_pass': (context) => const ForgotPassword(),
        'create_acc': (context) => CreateAcc(),
        'login': (context) => LoginPage(),
        '/deactivated': (context) => const DeactivatedScreen(),
        '/suspended': (context) => const SuspendedScreen(),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    String? initialRoute = await onOpenApp(context);

    if (initialRoute.isNotEmpty) {
      Navigator.pushReplacementNamed(context, initialRoute);
    } else {
      // Fallback to login if something goes wrong
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(action: 'login')),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      body: showLoadingIconAnimate(),
    );
  }
}
