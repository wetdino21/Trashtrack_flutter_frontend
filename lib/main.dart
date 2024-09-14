import 'package:flutter/material.dart';

//Customer library
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_about_us.dart';
import 'package:trashtrack/Customer/c_change_pass.dart';
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



void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
 // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //token
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //initialRoute: initialRoute,
      home: TokenCheck(),
      routes: {
        
        'splash': (context) => SplashScreen(),
        'terms': (context) => const TermsAndConditions(),
        'forgot_pass': (context) => const ForgotPassword(),
       // 'email_verify': (context) => EmailVerification(),
        'create_acc': (context) =>  CreateAcc(),
        'login': (context) => const LoginPage(),
        'deactivated': (context) => const DeactivatedScreen(),
        'suspended': (context) => const SuspendedScreen(),

        //Hauler Routes
        'home': (context) => HomeScreen(),
        'map': (context) => MapScreen(),
        'schedule': (context) => ScheduleScreen(),
        'vehicle': (context) => VehicleScreen(),
        'change_pass': (context) => ChangePass(),
        'about_us': (context) => AboutUs(),
        'privacy_policy': (context) => PrivacyPolicy(),
        'notification': (context) => NotificationScreen(),
        'profile': (context) => ProfileScreen(),

        //Customer
        'c_home': (context) => C_HomeScreen(),
        'c_map': (context) => C_MapScreen(),
        'c_schedule': (context) => C_ScheduleScreen(),
        'c_payment': (context) => C_PaymentScreen(),
        'c_change_pass': (context) => C_ChangePass(),
        'c_about_us': (context) => C_AboutUs(),
        'c_notification': (context) => C_NotificationScreen(),
        'c_profile': (context) => C_ProfileScreen(),
      },
      
    );
  }
}

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
             ElevatedButton(onPressed: (){
                deleteTokens(context);
              }, child: Text('delete token')),
          ],
        ), // Show a loading screen while checking the token
      ),
    );
  }
}

