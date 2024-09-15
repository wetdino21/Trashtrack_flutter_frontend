import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';

class VerifyEmailCreateAccScreen extends StatefulWidget {
  final String fname;
  final String lname;
  final String email;
  final String password;

  VerifyEmailCreateAccScreen({
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
  });

  @override
  _VerifyEmailCreateAccScreenState createState() =>
      _VerifyEmailCreateAccScreenState();
}

class _VerifyEmailCreateAccScreenState
    extends State<VerifyEmailCreateAccScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  late int onResendCode;

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
      if (mounted) {
        // Check if the widget is still mounted
        if (_timerSeconds > 0) {
          setState(() {
            _timerSeconds--;
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  // Function to resend the code
  void _resendCode() async {
    // Call your function to resend the code
    String? errorMessage = await sendEmailCodeCreateAcc(widget.email);
    if (errorMessage != null) {
      showErrorSnackBar(context, errorMessage);
    } else {
      showSuccessSnackBar(context, 'Successfully resent new code');
      // Reset timer seconds and start a new timer
      setState(() {
        _codeControllers.forEach((controller) => controller.clear());
        _startTimer();
        _timerSeconds = 300; // Reset to initial countdown value
        _timer.cancel();
      });
    }
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String enteredCode = '';
  // Function to combine the text of all controllers
  void updateEnteredCode() {
    setState(() {
      enteredCode =
          _codeControllers.map((controller) => controller.text).join();
    });
  }

  //verify code validator
  String? _validateCode() {
    String enteredCode =
        _codeControllers.map((controller) => controller.text).join();
    if (enteredCode.length < 6) {
      return 'Please enter the full code';
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
            Icon(Icons.email, color: Colors.lightGreenAccent, size: 100),
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
                    keyboardType: TextInputType
                        .text, // Accept characters instead of numbers
                    textInputAction:
                        TextInputAction.next, // Moves focus to next field
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
                    onChanged: (value) {
                      // Convert input to uppercase
                      final upperCaseValue = value.toUpperCase();
                      if (upperCaseValue.length == 1) {
                        _codeControllers[index].text = upperCaseValue;
                        _codeControllers[index].selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: upperCaseValue.length),
                        );

                        // Automatically move focus to the next field
                        if (index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else {
                          // Close the keyboard when the last textbox is filled
                          FocusScope.of(context).unfocus();
                        }
                      }
                      //print(enteredCode);
                    },
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
            TextButton(
              onPressed: () {
                _resendCode();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Resend Code?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? error = _validateCode();
                if (error == null) {
                  updateEnteredCode(); //to update stored enteredCode
                  String? errorMessage =
                      await verifyEmailCode(widget.email, enteredCode);
                  if (errorMessage != null) {
                    showErrorSnackBar(context, errorMessage);
                  } else {
                    showSuccessSnackBar(
                        context, 'Successful Email Verification');
                    // String? createMessage = await createCustomer(widget.fname,
                    //     widget.lname, widget.email, widget.password);
                    // if (createMessage != null) {
                    //   showErrorSnackBar(context, createMessage);
                    // } else {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => SuccessVerifyEmail(),
                    //     ),
                    //   );
                    // }
                  }
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
                'Verify',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
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
                      builder: (context) => C_HomeScreen(),
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
                  'Okay',
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
              color: _isFocused ? Colors.lightGreenAccent : Colors.transparent,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
