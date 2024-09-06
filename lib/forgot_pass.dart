import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/login.dart';
import 'package:trashtrack/styles.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Forgot Password'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: PasswordRecoveryScreen(),
    );
  }
}

// Password Recovery Screen
class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    ////validator
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Password Recovery',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Please enter the email you registered with to recover your password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    errorStyle: TextStyle(
                        color: const Color.fromARGB(
                            255, 255, 181, 176)), // Change error text color
                  ),
                ),
                child: TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.lightGreenAccent),
                    filled: true,
                    fillColor: Color(0xFF0A2A18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        Icon(Icons.email, color: Colors.lightGreenAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightGreenAccent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    String? errorMessage =
                        await emailCheckforgotpass(_emailController.text);
                    if (errorMessage != null) {
                      showErrorSnackBar(context, errorMessage);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckEmailScreenVerify(
                              email: _emailController.text),
                        ),
                      );
                    }
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
            ],
          ),
        ),
      ),
    );
  }
}

// Check Email Screen
class CheckEmailScreenVerify extends StatefulWidget {
  final String email;

  CheckEmailScreenVerify({
    required this.email,
  });

  //CheckEmailScreenVerify({required this.generatedCode, required this.onResendCode});

  @override
  _CheckEmailScreenVerifyState createState() => _CheckEmailScreenVerifyState();
}

class _CheckEmailScreenVerifyState extends State<CheckEmailScreenVerify> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  bool _isCodeExpired = false;
  late int _generatedCode;
  late int onResendCode;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _generatedCode = randomCode(); // Generate the code on start
    sendEmailForgotPass(widget.email, 'Verification Code', '$_generatedCode');
    print('Generated Code: $_generatedCode');
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
          setState(() {
            _isCodeExpired = true;
          });
          timer.cancel();
        }
      }
    });
  }

  // Code that generates a number between 100000 and 999999
  int randomCode() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }

  // Function to resend the code
  void _resendCode() {
    setState(() {
      _generatedCode = randomCode();
      print('New Code: $_generatedCode');
    });
    sendEmailForgotPass(widget.email, 'Verification Code', '$_generatedCode');
  }

  // Function to restart the timer and code
  void _restartTimerAndCode() {
    setState(() {
      _isCodeExpired = false;
      _timerSeconds = 300;
      _codeControllers.forEach((controller) => controller.clear());
      _resendCode(); // Resend the new code
      _startTimer();
    });
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String? _validateCode() {
    String enteredCode =
        _codeControllers.map((controller) => controller.text).join();
    if (enteredCode.length < 6) {
      return 'Please enter the full code';
    }
    if (int.tryParse(enteredCode) == null) {
      return 'Code must be numeric';
    }
    if (int.parse(enteredCode) != _generatedCode) {
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
                        //createCustomer(widget.fname, widget.lname, widget.email, widget.password);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResetPasswordScreen(email: widget.email),
                          ),
                        );
                        _isCodeExpired = true; // code expired
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

// Reset Password Screen
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({
    required this.email,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isObscured = true;
  bool _isObscured2 = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasNumber) {
      return 'Password must contain both letters and numbers';
    }
    // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    //   return 'Password must contain a special character';
    // }
    return null;
  }

  String? _validateReenterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Forgot Password'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset your password',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Please enter your new password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    errorStyle: TextStyle(
                        color: const Color.fromARGB(
                            255, 255, 181, 176)), // Change error text color
                  ),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  style: TextStyle(color: Colors.white),
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.lightGreenAccent),
                    filled: true,
                    fillColor: Color(0xFF0A2A18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        Icon(Icons.lock, color: Colors.lightGreenAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.lightGreenAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
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
              ),
              SizedBox(height: 20),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    errorStyle: TextStyle(
                        color: const Color.fromARGB(
                            255, 255, 181, 176)), // Change error text color
                  ),
                ),
                child: TextFormField(
                  controller: _reenterPasswordController,
                  obscureText: _isObscured2,
                  style: TextStyle(color: Colors.white),
                  validator: _validateReenterPassword,
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    labelStyle: TextStyle(color: Colors.lightGreenAccent),
                    filled: true,
                    fillColor: Color(0xFF0A2A18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        Icon(Icons.lock, color: Colors.lightGreenAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.lightGreenAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured2 = !_isObscured2;
                        });
                      },
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
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    String? errorMessage = await updatepassword(
                        widget.email, _passwordController.text);

                    // If there's an error, show it in a SnackBar
                    if (errorMessage != null) {
                      showErrorSnackBar(context, errorMessage);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(),
                        ),
                      );
                    }
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
                  'Done',
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

// Success Screen
class SuccessScreen extends StatelessWidget {
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
                'Reset Password Successful!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Your password has been successfully changed.',
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
