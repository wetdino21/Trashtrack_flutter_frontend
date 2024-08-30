import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/about_us.dart';
import 'package:trashtrack/Hauler/change_pass.dart';
import 'package:trashtrack/Hauler/create_acc.dart';
import 'package:trashtrack/Hauler/email_verification.dart';
import 'package:trashtrack/Hauler/forgot_pass.dart';
import 'package:trashtrack/Hauler/home.dart';
import 'package:trashtrack/Hauler/login.dart';
import 'package:trashtrack/Hauler/map.dart';
import 'package:trashtrack/Hauler/notification.dart';
import 'package:trashtrack/Hauler/privacy_policy.dart';
import 'package:trashtrack/Hauler/profile.dart';
import 'package:trashtrack/Hauler/splash_screen.dart';
import 'package:trashtrack/Hauler/terms_conditions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash',
      routes: {

        //Hauler Routes
        'splash': (context) => SplashScreen(),
        'terms': (context) => const TermsAndConditions(),
        'forgot_pass': (context) => const ForgotPassword(),
        'email_verify': (context) => EmailVerification(),
        'create_acc': (context) => const CreateAcc(),
        'login': (context) => const LoginPage(),
        'change_pass': (context) => ChangePass(),
        'about_us': (context) => AboutUs(),
        'privacy_policy': (context) => PrivacyPolicy(),
        'home': (context) => HomeScreen(),
        'map': (context) => MapScreen(),
        'notification': (context) => NotificationScreen(),
        'profile': (context) => ProfileScreen(),

      },
    );
  }
}
