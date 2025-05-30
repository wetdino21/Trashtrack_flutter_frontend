import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/API/api_email_service.dart';
import 'package:trashtrack/API/api_postgre_service.dart';

// Reset Password Screen
class ChangePassword extends StatefulWidget {
  final String email;

  ChangePassword({
    required this.email,
  });

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _isObscured = true;
  bool _isObscured2 = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String passvalidator = '';
  String confirmpassvalidator = '';
  bool isLoading = false;
  UserModel? userModel;
  int _currentStep = 1;
  bool _isLoading = false;

  bool isloading = false;

  @override
  void initState() {
    super.initState();

    _startTimer();
    _timer.cancel();
    _resendCode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _timer.cancel();
    _codeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  _validator(String showValidator) {
    return showValidator != ''
        ? Center(
            child: Text(
              showValidator,
              style: TextStyle(color: Colors.red),
            ),
          )
        : SizedBox();
  }

  String _validatePassword(String? value) {
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
    return '';
  }

  String _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return '';
  }

  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  late int onResendCode;

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
    setState(() {
      isloading = true;
    });
    // Call your function to resend the code
    String? errorMessage = await sendEmailCodeForgotPass(widget.email);
    if (errorMessage != null) {
      showErrorSnackBar(context, errorMessage);
      setState(() {
        isloading = false;
      });
    } else {
      // Reset timer seconds and start a new timer
      setState(() {
        _codeControllers.forEach((controller) => controller.clear());
        _timer.cancel();
        _timerSeconds = 300; // Reset to initial countdown value
        _startTimer();

        isloading = false;
      });
      showSuccessSnackBar(context, 'Successfully sent new code');
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
    //final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      backgroundColor: deepGreen,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _currentStep == 1 ? _emailScreen() : _passwordScreen(),
                // : _secondGoogleBind(),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
                child: InkWell(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 10,
                  strokeAlign: 2,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            )),
        ],
      ),
    );
  }

  //1st page
  Widget _emailScreen() {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: white,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: shadowBigColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.email, color: deepPurple, size: 100),
                      Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'We\'ve sent the code to',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            userModel!.email!,
                            style: TextStyle(
                              fontSize: 16,
                              color: deepPurple,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            child: Container(
                              decoration: BoxDecoration(boxShadow: shadowColor),
                              child: TextFormField(
                                cursorColor: deepGreen,
                                controller: _codeControllers[index],
                                keyboardType: TextInputType
                                    .number, // Accept characters instead of numbers
                                textInputAction: TextInputAction
                                    .next, // Moves focus to next field
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: deepPurple,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: deepGreen,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  // Convert input to uppercase
                                  final upperCaseValue = value.toUpperCase();
                                  if (upperCaseValue.length == 1) {
                                    _codeControllers[index].text =
                                        upperCaseValue;
                                    _codeControllers[index].selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: upperCaseValue.length),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _resendCode();
                            },
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
                        ],
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          String? error = _validateCode();
                          if (error == null) {
                            updateEnteredCode(); //to update stored enteredCode
                            print(enteredCode);
                            String? errorMessage = await verifyEmailCode(
                                userModel!.email!, enteredCode);
                            if (errorMessage != null) {
                              showErrorSnackBar(context, errorMessage);
                            } else {
                              setState(() {
                                _currentStep++;
                              });
                            }
                          } else {
                            showErrorSnackBar(context, error);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: shadowColor),
                          child: Text(
                            'Verify',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isloading)
            Positioned.fill(
                child: InkWell(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 10,
                  strokeAlign: 2,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            )),
        ],
      ),
    );
  }

  //2nd page
  Widget _passwordScreen() {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: Container()),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 100),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: shadowBigColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Change Your Password',
                          style: TextStyle(
                            fontSize: 28,
                            color: deepGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Please enter your new password',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(boxShadow: shadowColor),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscured,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              filled: true,
                              fillColor: white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock, color: deepPurple),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: deepPurple,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                passvalidator = _validatePassword(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 5),
                        _validator(passvalidator),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(boxShadow: shadowColor),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _isObscured2,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              filled: true,
                              fillColor: white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock, color: deepPurple),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscured2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: deepPurple,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured2 = !_isObscured2;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                confirmpassvalidator =
                                    _validateConfirmPassword(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 5),
                        _validator(confirmpassvalidator),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            if ((_passwordController.text.isEmpty ||
                                    passvalidator != '') ||
                                (_confirmPasswordController.text.isEmpty ||
                                    confirmpassvalidator != '') ||
                                (_passwordController.text !=
                                    _confirmPasswordController.text)) {
                              setState(() {
                                passvalidator =
                                    _validatePassword(_passwordController.text);
                                confirmpassvalidator = _validateConfirmPassword(
                                    _confirmPasswordController.text);
                              });
                            } else {
                              //update pass
                              String? errorMessage = await change_password(
                                  context, _passwordController.text);

                              if (errorMessage == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SuccessScreen(),
                                  ),
                                );
                              } else {
                                showErrorSnackBar(context, errorMessage!);
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 70.0, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: shadowColor),
                            child: Center(
                              child: Text(
                                'Done',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Positioned.fill(
                child: InkWell(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 10,
                  strokeAlign: 2,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            )),
        ],
      ),
    );
  }
}

// Success Screen
class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) {
                      return;
                    }
                  },
                  child: Container()),
              Icon(Icons.check_circle,
                  color: Colors.lightGreenAccent, size: 100),
              SizedBox(height: 20),
              Text(
                'Password Changed Successful!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Your password has been successfully updated.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
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
