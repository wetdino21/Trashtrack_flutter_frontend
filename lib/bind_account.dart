import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_google.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class BindWithGoogleScreen extends StatefulWidget {
  final String email; // Pass the user's current email

  BindWithGoogleScreen({required this.email});

  @override
  _BindWithGoogleScreenState createState() => _BindWithGoogleScreenState();
}

class _BindWithGoogleScreenState extends State<BindWithGoogleScreen> {
  bool _isObscured = true;
  bool _isObscured2 = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String passvalidator = '';
  String confirmpassvalidator = '';
  bool isLoading = false;
  bool _isLoading = false;
  int _currentStep = 1;

  bool emailChanged = false;
  bool isGoogle = false;
  GoogleAccountDetails? _accountDetails;

  bool _isGmailAccount = false;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
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

  void _bindWithGoogle() async {
    // Implement Google Sign-In
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account != null) {
      // Successfully signed in, bind account logic here
    }
  }

  void _changeEmail() {
    // Implement logic to change the user's email
  }

  void _bindAccount() {
    // Handle binding logic
    // Check if password matches and then bind account
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
                child: _currentStep == 1 ? _firstGoogleBind() : Container(),
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

  // 1st page
  Widget _firstGoogleBind() {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Text(
                'Bind Account',
                style: TextStyle(
                  fontSize: 28,
                  color: white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'with Google',
                style: TextStyle(
                  fontSize: 16,
                  color: white,
                ),
                textAlign: TextAlign.center,
              ),
              //gogole
              Column(
                children: [
                  InkWell(
                    onTap: () async {
                      //handleGoogleSignUp(context);
                      GoogleAccountDetails? accountDetails =
                          await handleGoogleSignUp(context);
                      if (accountDetails != null) {
                        setState(() {
                          _accountDetails =
                              accountDetails; //to store the google acc details
                          handleSignOut();
                          print('isGoogle: {$isGoogle}');
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: shadowBigColor),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green, // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Border radius
                            boxShadow: shadowColor),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(
                              8.0), // Padding inside the container
                          leading: _accountDetails != null
                              ? (_accountDetails!.photoBytes != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        _accountDetails!.photoBytes!,
                                      ),
                                    )
                                  : ClipOval(
                                      child: Container(
                                          padding: EdgeInsets.all(8),
                                          color: Colors.white,
                                          child: Icon(Icons.person, size: 40))))
                              : ClipOval(
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: deepPurple,
                                      ))),
                          title: _accountDetails != null
                              ? Text(
                                  _accountDetails!.email,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  'Select Google Account',
                                  style: TextStyle(color: Colors.white),
                                ),
                          trailing: Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: shadowBigColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To access TrashTrack using both Google and Email/Password, please choose a Google Account.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    if (_accountDetails != null)
                      Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Note: This will update your current email with the selected new email.',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              String? errorBinding = await binding_google(
                                  context, _accountDetails!.email);

                              // If there's an error, show it in a SnackBar
                              if (errorBinding == 'success') {
                                //showSuccessSnackBar(context, 'Saved Changes');
                                setState(() {
                                  isLoading = false;
                                });

                                userModel!.setBindGoogle('TRASHTRACK_GOOGLE',
                                    _accountDetails!.email);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BindWithNothing(),
                                  ),
                                );
                              } else {
                                showErrorSnackBar(context,
                                    'Something went wrong. Please try again later.');
                                setState(() {
                                  isLoading = false;
                                  //Navigator.pop(context);
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: shadowColor),
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // 2nd page
  // Widget _secondGoogleBind() {
  //   return Container();
  // }
}

// 2nd bind with trashtrack
class BindWithTrashTrackScreen extends StatefulWidget {
  final String email; // Pass the user's current email

  BindWithTrashTrackScreen({required this.email});

  @override
  _BindWithTrashTrackScreenState createState() =>
      _BindWithTrashTrackScreenState();
}

class _BindWithTrashTrackScreenState extends State<BindWithTrashTrackScreen> {
  bool _isObscured = true;
  bool _isObscured2 = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  late int onResendCode;

  bool isloading = false;

  String passvalidator = '';
  String confirmpassvalidator = '';
  bool isLoading = false;
  bool _isLoading = false;
  int _currentStep = 1;

  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _timer.cancel();
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
    String? errorMessage = await sendEmailCodeTrashtrackBind(widget.email);
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

  void _bindAccount() {
    // Handle binding logic
    // Check if password matches and then bind account
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
                child: _currentStep == 1
                    ? _firstTrashtrackPage()
                    : _secondTrashtrackPage(),
              ),
              // PopScope(
              //     canPop: false,
              //     onPopInvokedWithResult: (didPop, result) async {
              //       if (didPop) {
              //         return;
              //       }
              //       // _backToSignIn();
              //     },
              //     child: Container()),
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

  Widget _firstTrashtrackPage() {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            ListView(
              children: [
                Text(
                  'Bind Account',
                  style: TextStyle(
                    fontSize: 28,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'You are logged in with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: white,
                  ),
                  textAlign: TextAlign.center,
                ),
                userModel != null
                    ? Container(
                        margin: EdgeInsets.all(10.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: shadowBigColor),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: deepGreen, // Background color
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: shadowColor),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8.0),
                                leading: userModel!.profile != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(userModel!.profile!),
                                      )
                                    : ClipOval(
                                        child: Container(
                                            padding: EdgeInsets.all(8),
                                            color: Colors.white,
                                            child:
                                                Icon(Icons.person, size: 40))),
                                title: userModel!.email != null
                                    ? Text(
                                        userModel!.email ?? '',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text('No email available'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
                  decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: shadowBigColor),
                  child: Column(
                    children: [
                      Text(
                        'To access TrashTrack using both Google and Email/Password, please set a password.',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      Divider(),
                      SizedBox(height: 20),
                      Text(
                        'Create a Password',
                        style: TextStyle(
                          fontSize: 28,
                          color: deepGreen,
                          fontWeight: FontWeight.bold,
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
                            _resendCode();
                            setState(() {
                              _currentStep++;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 70.0, vertical: 10),
                          decoration: BoxDecoration(
                              color: deepGreen,
                              borderRadius: BorderRadius.circular(10.0),
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
      ),
    );
  }

  Widget _secondTrashtrackPage() {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: white,
        leading: IconButton(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
                        borderRadius: BorderRadius.circular(10.0),
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
                              widget.email,
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
                                decoration:
                                    BoxDecoration(boxShadow: shadowColor),
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
                            color:
                                _timerSeconds > 0 ? Colors.orange : Colors.red,
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
                                  widget.email, enteredCode);
                              if (errorMessage != null) {
                                showErrorSnackBar(context, errorMessage);
                              } else {
                                setState(() {
                                  isLoading = true;
                                });
                                String? errorBinding = await binding_trashtrack(
                                    context, _passwordController.text);

                                // If there's an error, show it in a SnackBar
                                if (errorBinding == 'success') {
                                  //showSuccessSnackBar(context, 'Saved Changes');
                                  setState(() {
                                    isLoading = false;
                                  });

                                  userModel!
                                      .setBindTrashtrack('TRASHTRACK_GOOGLE');

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BindWithNothing(),
                                    ),
                                  );
                                } else {
                                  showErrorSnackBar(context,
                                      'Something went wrong. Please try again later.');
                                  setState(() {
                                    isLoading = false;
                                    //Navigator.pop(context);
                                  });
                                }
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
      ),
    );
  }
}

class BindWithNothing extends StatelessWidget {
  const BindWithNothing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: Text('Bind Account'),
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: shadowBigColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'All Set',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: deepPurple,
              ),
            ),
            Text(
              'Account Bound',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: deepPurple,
              ),
            ),
            SizedBox(height: 20.0),
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60.0,
            ),
            SizedBox(height: 10.0),
            Text(
              'Your account is successfully bound with:',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: shadowColor,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email,
                        color: deepPurple,
                        size: 40.0,
                      ),
                      SizedBox(height: 5.0),
                      Text('Email/Password'),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: shadowColor,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: white,
                        child: Image.asset(
                          'assets/Brands.png',
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text('Google'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}
