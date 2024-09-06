import 'dart:async';
import 'dart:math';  // Add for random number generation

import 'package:flutter/material.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/styles.dart';

class EmailVerification extends StatefulWidget {
   final String fname;
  final String lname;
  final String email;
  final String password;

  EmailVerification({
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
  });

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  late int _generatedCode; // Store the generated 6-digit code

  @override
  void initState() {
    super.initState();
    _generatedCode = randomCode(); // Generate the code on start
    sendEmail(widget.email, 'Verification Code', '$_generatedCode');
    print('Generated Code: $_generatedCode');
  }

  // Code that generates a number between 100000 and 999999
  int randomCode() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: CheckEmailScreenVerify(fname: widget.fname, lname: widget.lname, email: widget.email, password: widget.password, generatedCode: _generatedCode, onResendCode: _resendCode)
    );
  }

  // Function to resend the code
  void _resendCode() {
    setState(() {
      _generatedCode = randomCode();
      print('New Code: $_generatedCode');
    });
  }
}

// Check Email Screen
class CheckEmailScreenVerify extends StatefulWidget {
     final String fname;
  final String lname;
  final String email;
  final String password;

  CheckEmailScreenVerify({
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
    required this.generatedCode, required this.onResendCode
  });

  final int generatedCode; // Accept the generated code
  final Function onResendCode; // Accept callback to resend code

  //CheckEmailScreenVerify({required this.generatedCode, required this.onResendCode});

  @override
  _CheckEmailScreenVerifyState createState() => _CheckEmailScreenVerifyState();
}

class _CheckEmailScreenVerifyState extends State<CheckEmailScreenVerify> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  bool _isCodeExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _isCodeExpired = true; // Mark code as expired
        });
        timer.cancel();
      }
    });
  }

  // Function to restart the timer and code
  void _restartTimerAndCode() {
    setState(() {
      _isCodeExpired = false;
      _timerSeconds = 300;
      _codeControllers.forEach((controller) => controller.clear());
      widget.onResendCode(); // Resend the new code
      _startTimer();
    });
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String? _validateCode() {
    String enteredCode = _codeControllers.map((controller) => controller.text).join();
    if (enteredCode.length < 6) {
      return 'Please enter the full code';
    }
    if (int.tryParse(enteredCode) == null) {
      return 'Code must be numeric';
    }
    if (int.parse(enteredCode) != widget.generatedCode) {
      return 'The code is incorrect';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Check your email',
              style: TextStyle(
                fontSize: 28,
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'We\'ve sent the code to your email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextFormField(
                    controller: _codeControllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Color(0xFF0A2A18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.lightGreenAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Text(
              'Code expires in: ${_formatTimer(_timerSeconds)}',
              style: TextStyle(
                fontSize: 16,
                color: _timerSeconds > 0 ? Colors.orange : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCodeExpired
                  ? null
                  : () {
                      String? error = _validateCode();
                      if (error == null) {
                        createCustomer(widget.fname, widget.lname, widget.email, widget.password);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessVerifyEmail(),
                          ),
                        );
                         _isCodeExpired = true;// code expired
                      } else {
                        showErrorSnackBar(context, error);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            _isCodeExpired
                ? ElevatedButton(
                    onPressed: _restartTimerAndCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Resend Code',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}


// Success Screen
class SuccessVerifyEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF04130B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle,
                  color: Colors.lightGreenAccent, size: 100),
              SizedBox(height: 20),
              Text(
                'Account Registration Successful!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Your email has been successfully verified.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Text Field with Active Border Color Change
class CustomTextField extends StatefulWidget {
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;

  CustomTextField({
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextField(
        obscureText: widget.obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(color: Colors.lightGreenAccent),
          filled: true,
          fillColor: Color(0xFF0A2A18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(widget.prefixIcon, color: Colors.lightGreenAccent),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _isFocused
                  ? Colors.lightGreenAccent
                  : Colors.transparent,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}