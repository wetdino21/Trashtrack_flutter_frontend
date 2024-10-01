import 'package:flutter/material.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/api_address.dart';
import 'dart:async';
import 'package:trashtrack/Customer/c_home.dart';

//google
import 'package:trashtrack/api_google.dart';

class CreateAcc extends StatefulWidget {
  @override
  _CreateAccState createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  int _currentStep = 1;

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _mnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvinceName;
  String? _selectedCityMunicipalityName;
  String? _selectedBarangayName;

  String? _selectedProvince;
  String? _selectedCityMunicipality;
  String? _selectedBarangay;

  bool _acceptTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String emailvalidator = '';
  String passvalidator = '';
  String confpassvalidator = '';
  String fnamevalidator = '';
  String mnamevalidator = '';
  String lnamevalidator = '';
  String contactvalidator = '';
  String provincevalidator = '';
  String cityvalidator = '';
  String brgyvalidator = '';
  String streetvalidator = '';
  String postalvalidator = '';
  bool emailChanged = false;
  bool isGoogle = false;
  GoogleAccountDetails? _accountDetails;

  final _formKey = GlobalKey<FormState>();

  //email verification
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  late int onResendCode;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _startTimer();
    _timer.cancel();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _mnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _repassController.dispose();
    _contactController.dispose();
    _streetController.dispose();
    _postalController.dispose();

    _timer.cancel();
    _codeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinces = provinces;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
    }
  }

  Future<void> _loadCitiesMunicipalities(String provinceCode) async {
    try {
      final citiesMunicipalities =
          await fetchCitiesMunicipalities(provinceCode);
      setState(() {
        _citiesMunicipalities = citiesMunicipalities;
        _barangays = []; // Clear barangays when a new city is selected
        _selectedCityMunicipalityName = null;
        _selectedBarangayName = null;
      });
    } catch (e) {
      print('Error fetching cities/municipalities: $e');
    }
  }

  Future<void> _loadBarangays(String cityMunicipalityCode) async {
    try {
      final barangays = await fetchBarangays(cityMunicipalityCode);
      setState(() {
        _barangays = barangays;
        _selectedBarangayName = null;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

//email
  void _startTimer() {
    //_timer.cancel();
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
    String? errorMessage = await sendEmailCodeCreateAcc(_emailController.text);
    if (errorMessage != null) {
      showErrorSnackBar(context, errorMessage);
    } else {
      showSuccessSnackBar(context, 'Successfully sent new code');
      // Reset timer seconds and start a new timer
      setState(() {
        _timer.cancel();
        _codeControllers.forEach((controller) => controller.clear());
        _startTimer();
        _timerSeconds = 300; // Reset to initial countdown value
        //_timer.cancel();
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
      body: Column(
        children: [
          Expanded(
            child: _currentStep == 1
                ? _buildFirstStep()
                : _currentStep == 2
                    ? _buildSecondStep()
                    : _buildThirdStep(),
          ),
          PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) {
                  return;
                }
                _backToSignIn();
              },
              child: Container()),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       if (_currentStep > 1)
          //         ElevatedButton(
          //           onPressed: () {
          //             setState(() {
          //               _currentStep--;
          //             });
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.green,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(10.0),
          //             ),
          //             padding: EdgeInsets.symmetric(horizontal: 16.0),
          //           ),
          //           child: Text(
          //             'Back',
          //             style: TextStyle(color: Colors.white, fontSize: 18.0),
          //           ),
          //         )
          //       else
          //         Container(),
          //       _currentStep > 1
          //           ? ElevatedButton(
          //               onPressed: () {},
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.green,
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(10.0),
          //                 ),
          //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
          //               ),
          //               child: Text(
          //                 _currentStep < 3 ? 'Next' : 'Submit',
          //                 style: TextStyle(color: Colors.white, fontSize: 18.0),
          //               ),
          //             )
          //           : SizedBox(),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 50,
          // )
        ],
      ),
    );
  }

  // Dot indicator below AppBar
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Row(
          children: [
            GestureDetector(
              onTap: () async {
                //page 1 to 2
                if ((_currentStep == 1) && (index + 1 == 2)) {
                  // Check if any validation error or email sending error exists
                  if ((_emailController.text.isEmpty ||
                          emailvalidator.isNotEmpty) ||
                      (_passController.text.isEmpty ||
                          passvalidator.isNotEmpty) ||
                      (_repassController.text.isEmpty ||
                          confpassvalidator.isNotEmpty)) {
                    setState(() {
                      emailvalidator = _validateEmail(_emailController.text);
                      passvalidator = _validatePassword(_passController.text);
                      confpassvalidator =
                          _validateConfirmPassword(_repassController.text);
                    });
                  } else if (_emailController.text.isNotEmpty) {
                    String? errorMessage =
                        await emailCheck(_emailController.text);
                    // Show any existing error message
                    if (errorMessage != null &&
                        _emailController.text.isNotEmpty) {
                      setState(() {
                        emailvalidator = errorMessage;
                      });
                    } else {
                      print(111);
                      // If no errors, proceed with incrementing the step
                      if (_currentStep < 3) {
                        setState(() {
                          _currentStep = 2;
                        });
                      }
                    }
                  }
                }

                //page 1 to 3
                if ((_currentStep == 1) && (index + 1 == 3)) {
                  // Check if any validation error or email sending error exists
                  if ((_emailController.text.isEmpty ||
                          emailvalidator.isNotEmpty) ||
                      (_passController.text.isEmpty ||
                          passvalidator.isNotEmpty) ||
                      (_repassController.text.isEmpty ||
                          confpassvalidator.isNotEmpty)) {
                    setState(() {
                      emailvalidator = _validateEmail(_emailController.text);
                      passvalidator = _validatePassword(_passController.text);
                      confpassvalidator =
                          _validateConfirmPassword(_repassController.text);
                    });
                  } else if (_emailController.text.isNotEmpty) {
                    String? errorMessage =
                        await emailCheck(_emailController.text);
                    // Show any existing error message
                    if (errorMessage != null &&
                        _emailController.text.isNotEmpty) {
                      setState(() {
                        emailvalidator = errorMessage;
                      });
                    } else {
                      if ((_fnameController.text.isEmpty ||
                              fnamevalidator.isNotEmpty) ||
                          (mnamevalidator.isNotEmpty) ||
                          (_lnameController.text.isEmpty ||
                              lnamevalidator.isNotEmpty) ||
                          (_contactController.text.isEmpty ||
                              contactvalidator.isNotEmpty) ||
                          (_selectedProvinceName == null ||
                              provincevalidator.isNotEmpty) ||
                          (_selectedCityMunicipalityName == null ||
                              cityvalidator.isNotEmpty) ||
                          (_selectedBarangayName == null ||
                              brgyvalidator.isNotEmpty) ||
                          (_streetController.text.isEmpty ||
                              streetvalidator.isNotEmpty) ||
                          (_postalController.text.isEmpty ||
                              postalvalidator.isNotEmpty)) {
                        setState(() {
                          fnamevalidator =
                              _validateFname(_fnameController.text);
                          mnamevalidator =
                              _validateMname(_mnameController.text);
                          lnamevalidator =
                              _validateLname(_lnameController.text);
                          contactvalidator =
                              _validateContact(_contactController.text);
                          provincevalidator =
                              _validateProvince(_selectedProvinceName);
                          cityvalidator =
                              _validateCity(_selectedCityMunicipalityName);
                          brgyvalidator = _validateBrgy(_selectedBarangayName);
                          streetvalidator =
                              _validateStreet(_streetController.text);
                          postalvalidator =
                              _validatePostalCode(_postalController.text);
                        });
                      } else {
                        // If no errors, proceed with incrementing the step
                        if (_currentStep < 3) {
                          if (_acceptTerms) {
                            setState(() {
                              _currentStep = index + 1;
                              if (emailChanged == true) {
                                emailChanged = false;
                                _resendCode();
                              }
                              // _startTimer();
                            });
                          } else {
                            showErrorSnackBar(context,
                                'You must accept the terms and conditions');
                          }
                        }
                      }
                    }
                  }
                }

                //page 2 to 1
                if (_currentStep == 2 && index + 1 == 1) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
                //page 2 to 3
                if ((_currentStep == 2) && (index + 1 == 3)) {
                  setState(() {
                    fnamevalidator = _validateFname(_fnameController.text);
                    mnamevalidator = _validateMname(_mnameController.text);
                    lnamevalidator = _validateLname(_lnameController.text);
                    contactvalidator =
                        _validateContact(_contactController.text);
                    provincevalidator =
                        _validateProvince(_selectedProvinceName);
                    cityvalidator =
                        _validateCity(_selectedCityMunicipalityName);
                    brgyvalidator = _validateBrgy(_selectedBarangayName);
                    streetvalidator = _validateStreet(_streetController.text);
                    postalvalidator =
                        _validatePostalCode(_postalController.text);
                  });

                  if ((_fnameController.text.isEmpty ||
                          fnamevalidator.isNotEmpty) ||
                      (mnamevalidator.isNotEmpty) ||
                      (_lnameController.text.isEmpty ||
                          lnamevalidator.isNotEmpty) ||
                      (_contactController.text.isEmpty ||
                          contactvalidator.isNotEmpty) ||
                      (_selectedProvinceName == null ||
                          provincevalidator.isNotEmpty) ||
                      (_selectedCityMunicipalityName == null ||
                          cityvalidator.isNotEmpty) ||
                      (_selectedBarangayName == null ||
                          brgyvalidator.isNotEmpty) ||
                      (_streetController.text.isEmpty ||
                          streetvalidator.isNotEmpty) ||
                      (_postalController.text.isEmpty ||
                          postalvalidator.isNotEmpty)) {
                  } else {
                    // If no errors, proceed with incrementing the step
                    if (_currentStep < 4) {
                      if (_acceptTerms) {
                        setState(() {
                          _currentStep = index + 1;
                          if (emailChanged == true) {
                            emailChanged = false;
                            _resendCode();
                          }
                          //_startTimer();
                        });
                      } else {
                        showErrorSnackBar(context,
                            'You must accept the terms and conditions');
                      }
                    }
                  }
                }

                //page 3 to 1
                if (_currentStep == 3 && index + 1 == 1) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
                //page 3 to 2
                if (_currentStep == 3 && index + 1 == 2) {
                  setState(() {
                    _currentStep = 2;
                  });
                }
              },
              child: Icon(
                Icons.circle,
                size: 30,
                color: _currentStep - 1 >= index ? Colors.green : Colors.grey,
              ),
            ),
            if (index != 2)
              Container(
                width: 70,
                height: 5,
                color: _currentStep - 1 > index ? Colors.green : Colors.grey,
              ),
          ],
        );
      }),
    );
  }

  // Validator All
  _validator(String showValidator) {
    return showValidator != ''
        ? Text(
            showValidator,
            style: TextStyle(color: Colors.redAccent[100]),
          )
        : SizedBox();
  }

  // Validator for email
  String _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return '';
  }

// Validator for password
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
    return '';
  }

  String _validateFname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain only letters';
    }
    return '';
  }

  String _validateMname(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Name must contain only letters';
    }
    return '';
  }

  String _validateLname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain only letters';
    }
    return '';
  }

  String _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your contact number';
    }
    final contactNumber = value.replaceFirst(RegExp(r'^0'), '');
    if (contactNumber.length != 10 || !contactNumber.startsWith('9')) {
      print(contactNumber);
      return 'Invalid Phone Number';
    }
    return '';
  }

  String _validateProvince(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your province';
    }
    return '';
  }

  String _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your city/municipality';
    }
    return '';
  }

  String _validateBrgy(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your barangay';
    }
    return '';
  }

  String _validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your street name, building, house No';
    }
    return '';
  }

  String _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your postal code';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Postal code must contain only numbers';
    }
    if (value.length != 4) {
      // Adjust according to postal code length
      return 'Postal code must be 4 digits long';
    }
    return '';
  }

// Validator for confirm password
  String _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passController.text) {
      return 'Passwords do not match';
    }
    return '';
  }

  ///1st page
  Widget _buildFirstStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        toolbarHeight: 100,
        title: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDotIndicator(),
              ],
            ),
            SizedBox(
              width: 0,
            ),
          ],
        ),
        //leadingWidth: 0,
        leading: SizedBox(),
        leadingWidth: 70,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Please enter your account details below!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your email';
                  //   }
                  //   final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  //   if (!emailRegex.hasMatch(value)) {
                  //     return 'Please enter a valid email';
                  //   }
                  //   return null;
                  // },
                  onChanged: (value) {
                    setState(() {
                      emailvalidator = _validateEmail(
                          value); // Trigger validation on text change
                      emailChanged = true;
                    });
                  },
                ),
                _validator(emailvalidator),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passController,
                  hintText: 'Password',
                  obscureText: !_passwordVisible,
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your password';
                  //   }
                  //   if (value.length < 8) {
                  //     return 'Password must be at least 8 characters long';
                  //   }
                  //   final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                  //   final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                  //   if (!hasLetter || !hasNumber) {
                  //     return 'Password must contain both letters and numbers';
                  //   }
                  //   // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  //   //   return 'Password must contain a special character';
                  //   // }
                  //   return null;
                  // },
                  onChanged: (value) {
                    setState(() {
                      passvalidator = _validatePassword(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(passvalidator),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _repassController,
                  hintText: 'Confirm Password',
                  obscureText: !_confirmPasswordVisible,
                  icon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please confirm your password';
                  //   }
                  //   if (value != _passController.text) {
                  //     return 'Passwords do not match';
                  //   }
                  //   return null;
                  // },
                  onChanged: (value) {
                    setState(() {
                      confpassvalidator = _validateConfirmPassword(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(confpassvalidator),
                // Checkbox terms
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Check if any validation error or email sending error exists
                      if ((_emailController.text.isEmpty ||
                              emailvalidator.isNotEmpty) ||
                          (_passController.text.isEmpty ||
                              passvalidator.isNotEmpty) ||
                          (_repassController.text.isEmpty ||
                              confpassvalidator.isNotEmpty)) {
                        setState(() {
                          emailvalidator =
                              _validateEmail(_emailController.text);
                          passvalidator =
                              _validatePassword(_passController.text);
                          confpassvalidator =
                              _validateConfirmPassword(_repassController.text);
                        });
                        // Show any existing error message
                      } else if (_emailController.text.isNotEmpty) {
                        String? errorMessage =
                            await emailCheck(_emailController.text);
                        // Show any existing error message
                        if (errorMessage != null &&
                            _emailController.text.isNotEmpty) {
                          setState(() {
                            emailvalidator = errorMessage;
                          });
                        } else {
                          // If no errors, proceed with incrementing the step
                          if (_currentStep < 3) {
                            setState(() {
                              _currentStep = 2;
                            });
                          }
                        }

                        // Navigate to the next screen if needed
                        // Uncomment if necessary
                        // if (_acceptTerms) {
                        //   showSuccessSnackBar(context, 'Loading . . .');
                        //   String? errorMessage = await sendEmailCodeCreateAcc(
                        //       _emailController.text);
                        //   if (errorMessage == null) {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 VerifyEmailCreateAccScreen(
                        //                     fname: _fnameController.text,
                        //                     lname: _lnameController.text,
                        //                     email: _emailController.text,
                        //                     password: _passController.text)));
                        //   } else {
                        //     showErrorSnackBar(context, errorMessage);
                        //   }
                        // } else {
                        //   showErrorSnackBar(context,
                        //       'You must accept the terms and conditions');
                        // }
                      }
                    },
                    child: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.white70, fontSize: 16.0),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          //handleGoogleSignUp(context);
                          GoogleAccountDetails? accountDetails =
                              await handleGoogleSignUp(context);
                          if (accountDetails != null) {
                            if (_emailController.text.isNotEmpty ||
                                _passController.text.isNotEmpty ||
                                _repassController.text.isNotEmpty ||
                                _fnameController.text.isNotEmpty ||
                                _mnameController.text.isNotEmpty ||
                                _lnameController.text.isNotEmpty ||
                                _fnameController.text.isNotEmpty ||
                                _contactController.text.isNotEmpty ||
                                _selectedProvinceName != null ||
                                _selectedCityMunicipalityName != null ||
                                _selectedBarangayName != null ||
                                _streetController.text.isNotEmpty ||
                                _postalController.text.isNotEmpty) {
                              _showGoogleSignInConfirmationDialog(
                                  context, accountDetails);
                            } else {
                              _currentStep++;
                              isGoogle = true;
                              setState(() {
                                _accountDetails =
                                    accountDetails; //to store the google acc details
                                handleSignOut();
                                print('isGoogle: {$isGoogle}');
                                _fnameController.text = _accountDetails!.fname;
                                _lnameController.text = _accountDetails!.lname;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: Colors.white54, width: 2.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 35.0),
                        ),
                        icon: Image.asset(
                          'assets/Brands.png',
                          height: 24.0,
                        ),
                        label: Text(
                          'Google',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          _backToSignIn();
                          // if (_emailController.text.isNotEmpty ||
                          //     _passController.text.isNotEmpty ||
                          //     _repassController.text.isNotEmpty ||
                          //     _fnameController.text.isNotEmpty ||
                          //     _mnameController.text.isNotEmpty ||
                          //     _lnameController.text.isNotEmpty ||
                          //     _fnameController.text.isNotEmpty ||
                          //     _contactController.text.isNotEmpty ||
                          //     _selectedProvinceName != null ||
                          //     _selectedCityMunicipalityName != null ||
                          //     _selectedBarangayName != null ||
                          //     _streetController.text.isNotEmpty ||
                          //     _postalController.text.isNotEmpty) {
                          //   _showSignInConfirmationDialog(context);
                          // } else {
                          //   Navigator.pushNamed(context, 'login');
                          // }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _backToSignIn() {
    if (_emailController.text.isNotEmpty ||
        _passController.text.isNotEmpty ||
        _repassController.text.isNotEmpty ||
        _fnameController.text.isNotEmpty ||
        _mnameController.text.isNotEmpty ||
        _lnameController.text.isNotEmpty ||
        _fnameController.text.isNotEmpty ||
        _contactController.text.isNotEmpty ||
        _selectedProvinceName != null ||
        _selectedCityMunicipalityName != null ||
        _selectedBarangayName != null ||
        _streetController.text.isNotEmpty ||
        _postalController.text.isNotEmpty) {
      _showSignInConfirmationDialog(context);
    } else {
      Navigator.pushNamed(context, 'login');
    }
  }

  void _showGoogleSignInConfirmationDialog(
      BuildContext context, GoogleAccountDetails accountDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Sign Up with Google',
              style: TextStyle(color: Colors.white)),
          content: Text('Certain data from this form will be remove!',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                await handleSignOut();
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _currentStep++;
                isGoogle = true;
                setState(() {
                  _accountDetails =
                      accountDetails; //to store the google acc details
                  handleSignOut();
                  Navigator.pop(context);
                  print('isGoogle: {$isGoogle}');
                  _fnameController.text = _accountDetails!.fname;
                  _lnameController.text = _accountDetails!.lname;
                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showBackToSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Cancel google Sign Up',
              style: TextStyle(color: Colors.white)),
          content: Text('Google Account will be remove from the form!',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _currentStep--;
                isGoogle = false;
                setState(() {
                  _accountDetails = null; //to store the google acc details
                  handleSignOut();
                  Navigator.pop(context);
                  print('isGoogle: {$isGoogle}');
                  _fnameController.text = '';
                  _lnameController.text = '';
                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  ///2nd page
  Widget _buildSecondStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        toolbarHeight: 100,
        title: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isGoogle == false ? _buildDotIndicator() : const SizedBox(),
              ],
            ),
            const SizedBox(
              width: 0,
            ),
          ],
        ),
        leading: IconButton(
            onPressed: () {
              isGoogle
                  ? _showBackToSignUpDialog(context)
                  : setState(() {
                      _currentStep--;
                    });
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            )),
        leadingWidth: 70,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isGoogle == true
                    ? Column(
                        children: [
                          Text(
                            'with Google Authentication',
                            style: TextStyle(color: Colors.grey),
                          ),
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
                                  _fnameController.text =
                                      _accountDetails!.fname;
                                  _lnameController.text =
                                      _accountDetails!.lname;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.deepPurpleAccent, // Background color
                                borderRadius: BorderRadius.circular(
                                    10.0), // Border radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
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
                                                child: Icon(Icons.person,
                                                    size: 40))))
                                    : SizedBox(),
                                title: _accountDetails != null
                                    ? Text(
                                        _accountDetails!.email,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text('No email available'),
                                trailing: Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),

                const SizedBox(height: 20),
                Center(
                    child: Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _fnameController,
                  hintText: 'First Name',
                  icon: Icons.person,
                  onChanged: (value) {
                    setState(() {
                      fnamevalidator = _validateFname(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(fnamevalidator),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _mnameController,
                  hintText: 'Middle Name (Optional)',
                  icon: Icons.person_outline,
                  onChanged: (value) {
                    setState(() {
                      mnamevalidator = _validateMname(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(mnamevalidator),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _lnameController,
                  hintText: 'Last Name',
                  icon: Icons.person,
                  onChanged: (value) {
                    setState(() {
                      lnamevalidator = _validateLname(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(lnamevalidator),
                const SizedBox(height: 5),
                _buildNumberField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                _validator(contactvalidator),
                const SizedBox(height: 20),
                Center(
                    child: Text(
                  'Complete Address',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )),
                const SizedBox(height: 20),
                // Dropdown for Province
                _buildDropdown(
                  selectedValue: _selectedProvince,
                  items: _provinces,
                  hintText: 'Select Province',
                  icon: Icons.location_city,
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = value;
                      provincevalidator = _validateProvince(value);
                      final selectedProvince = _provinces
                          .firstWhere((item) => item['code'] == value);
                      _selectedProvinceName = selectedProvince['name'];
                    });
                    _loadCitiesMunicipalities(value!);
                  },
                ),
                _validator(provincevalidator),
                SizedBox(height: 5),
                // Dropdown for City/Municipality
                _buildDropdown(
                  selectedValue: _selectedCityMunicipality,
                  items: _citiesMunicipalities,
                  hintText: 'Select City/Municipality',
                  icon: Icons.apartment,
                  onChanged: (value) {
                    setState(() {
                      _selectedCityMunicipality = value;
                      cityvalidator = _validateCity(value);
                      final selectedCity = _citiesMunicipalities
                          .firstWhere((item) => item['code'] == value);
                      _selectedCityMunicipalityName = selectedCity['name'];
                    });
                    _loadBarangays(value!);
                  },
                ),
                _validator(cityvalidator),
                SizedBox(height: 5),
                // Dropdown for Barangay
                _buildDropdown(
                  selectedValue: _selectedBarangay,
                  items: _barangays,
                  hintText: 'Select Barangay',
                  icon: Icons.maps_home_work,
                  onChanged: (value) {
                    setState(() {
                      _selectedBarangay = value;
                      brgyvalidator = _validateBrgy(value);
                      final selectedBarangay = _barangays
                          .firstWhere((item) => item['code'] == value);
                      _selectedBarangayName = selectedBarangay['name'];
                      print(_selectedBarangayName);
                    });
                  },
                ),
                _validator(brgyvalidator),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _streetController,
                  hintText: 'Street Name, Building, House No.',
                  icon: Icons.home,
                  onChanged: (value) {
                    setState(() {
                      streetvalidator = _validateStreet(
                          value); // Trigger validation on text change
                    });
                  },
                ),
                _validator(streetvalidator),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _postalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  hintText: 'Postal Code',
                  icon: Icons.pin_drop,
                  onChanged: (value) {
                    setState(() {
                      postalvalidator = _validatePostalCode(
                          value); // Trigger validation on text change
                      print(_postalController.text);
                    });
                  },
                ),
                _validator(postalvalidator),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor: Colors.green,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _acceptTerms = newValue ?? false;
                        });
                      },
                    ),
                    Text(
                      'I accept the ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'terms');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'terms and conditions.',
                        style: TextStyle(
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if ((_fnameController.text.isEmpty ||
                              fnamevalidator.isNotEmpty) ||
                          (mnamevalidator.isNotEmpty) ||
                          (_lnameController.text.isEmpty ||
                              lnamevalidator.isNotEmpty) ||
                          (_contactController.text.isEmpty ||
                              contactvalidator.isNotEmpty) ||
                          (_selectedProvinceName == null ||
                              provincevalidator.isNotEmpty) ||
                          (_selectedCityMunicipalityName == null ||
                              cityvalidator.isNotEmpty) ||
                          (_selectedBarangayName == null ||
                              brgyvalidator.isNotEmpty) ||
                          (_streetController.text.isEmpty ||
                              streetvalidator.isNotEmpty) ||
                          (_postalController.text.isEmpty ||
                              postalvalidator.isNotEmpty)) {
                        setState(() {
                          fnamevalidator =
                              _validateFname(_fnameController.text);
                          mnamevalidator =
                              _validateMname(_mnameController.text);
                          lnamevalidator =
                              _validateLname(_lnameController.text);
                          contactvalidator =
                              _validateContact(_contactController.text);
                          provincevalidator =
                              _validateProvince(_selectedProvinceName);
                          cityvalidator =
                              _validateCity(_selectedCityMunicipalityName);
                          brgyvalidator = _validateBrgy(_selectedBarangayName);
                          streetvalidator =
                              _validateStreet(_streetController.text);
                          postalvalidator =
                              _validatePostalCode(_postalController.text);
                        });
                      } else if (_contactController.text.isNotEmpty) {
                        String? dbContactMsg =
                            await contactCheck(_contactController.text);
                        // Show any existing error message
                        if (dbContactMsg != null) {
                          setState(() {
                            contactvalidator = dbContactMsg;
                          });
                        } else {
                          // If no errors, proceed with incrementing the step
                          if (_currentStep < 3) {
                            if (_acceptTerms) {
                              if (isGoogle) {
                                await createGoogleAccount(
                                    context,
                                    _accountDetails?.email ?? '',
                                    _accountDetails?.photoBytes != null
                                        ? _accountDetails!.photoBytes!
                                        : null,
                                    _fnameController.text,
                                    _mnameController.text,
                                    _lnameController.text,
                                    ('0' + _contactController.text),
                                    _selectedProvinceName!,
                                    _selectedCityMunicipalityName!,
                                    _selectedBarangayName!,
                                    _streetController.text,
                                    _postalController.text);
                              } else {
                                setState(() {
                                  _currentStep++;
                                  if (emailChanged == true) {
                                    emailChanged = false;
                                    _resendCode();
                                  }
                                });
                              }
                            } else {
                              showErrorSnackBar(context,
                                  'You must accept the terms and conditions');
                            }
                          }
                        }
                      }
                    },
                    child: Text(isGoogle ? 'Done' : 'Next'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

//3rd page
  Widget _buildThirdStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        toolbarHeight: 100,
        title: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDotIndicator(),
              ],
            ),
            SizedBox(
              width: 0,
            ),
          ],
        ),
        leading: IconButton(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            )),
        leadingWidth: 70,
      ),
      body: ListView(
        children: [
          Padding(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'We\'ve sent the code to',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
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
                    print(_emailController.text);
                    print(_passController.text);
                    print(_fnameController.text);
                    print(_mnameController.text);
                    print(_lnameController.text);
                    print(_contactController.text);
                    print(_selectedProvinceName);
                    print(_selectedCityMunicipalityName);
                    print(_selectedBarangayName);
                    print(_streetController.text);
                    print(_postalController.text);
                    String? error = _validateCode();
                    if (error == null) {
                      updateEnteredCode(); //to update stored enteredCode
                      String? errorMessage = await verifyEmailCode(
                          _emailController.text, enteredCode);
                      if (errorMessage != null) {
                        showErrorSnackBar(context, errorMessage);
                      } else {
                        // showSuccessSnackBar(
                        //     context, 'Successful Email Verification');
                        String? createMessage = await createCustomer(
                            context,
                            _emailController.text,
                            _passController.text,
                            _fnameController.text,
                            _mnameController.text,
                            _lnameController.text,
                            ('0' + _contactController.text),
                            _selectedProvinceName,
                            _selectedCityMunicipalityName,
                            _selectedBarangayName,
                            _streetController.text,
                            _postalController.text);
                        if (createMessage != null) {
                          showErrorSnackBar(context, createMessage);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuccessVerifyEmail(),
                            ),
                          );
                        }
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required IconData icon,
    //required FormFieldValidator<String> validator,
    required ValueChanged<String?> onChanged,
    Widget? suffixIcon,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
              color: const Color.fromARGB(
                  255, 255, 181, 176)), // Change error text color
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText:
              hintText, // This will move the hint text to the upper left when focused
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(color: Colors.grey),
          //hintText: hintText,
          //hintStyle: TextStyle(color: Colors.green),
          prefixIcon: Icon(icon, color: Colors.green),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: const BorderSide(color: Colors.grey, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: const BorderSide(color: Colors.green, width: 5.0),
          ),
        ),
        inputFormatters: inputFormatters,
        //validator: validator,
        onChanged: onChanged,
        // onChanged: (value) {
        //   // Trigger validation on text change
        //   setState(() {
        //     _formKey.currentState?.validate();
        //   });
        // },
      ),
    );
  }

  Widget _buildNumberField({
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
              color: const Color.fromARGB(
                  255, 255, 181, 176)), // Change error text color
        ),
      ),
      child: TextFormField(
        controller: _contactController,
        decoration: InputDecoration(
          //prefixText: '+63 ',
          prefixIcon: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Text('+63',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          //prefixIcon: Icon(Icons.abc),
          hintText: 'Contact Number',
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: const BorderSide(color: Colors.grey, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: const BorderSide(color: Colors.green, width: 5.0),
          ),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        // validator: (value) {
        //   if (value == null || value.isEmpty) {
        //     return 'Please enter your contact number';
        //   }
        //   final contactNumber = value.replaceFirst(RegExp(r'^0'), '');
        //   if (contactNumber.length != 10 || !contactNumber.startsWith('9')) {
        //     return 'Invalid Phone Number';
        //   }
        //   return null;
        // },
        onChanged: (value) {
          if (value.length > 10) {
            _contactController.text = value.substring(0, 10);
            _contactController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contactController.text.length));
          }
          setState(() {
            contactvalidator = _validateContact(value);
          });
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? selectedValue,
    required List<dynamic> items,
    required String hintText,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    //required FormFieldValidator<String> validator,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
              color: const Color.fromARGB(
                  255, 255, 181, 176)), // Change error text color
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        hint: Text(hintText, style: TextStyle(color: Colors.grey)),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 5.0),
          ),
        ),
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item['code'],
            child: Text(item['name']), // Use the appropriate field for display
          );
        }).toList(),
        onChanged: onChanged,
        //validator: validator,
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
                'Successful Account Registration!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Your email has been verified successfully.',
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

// Success Screen
class SuccessfulGoogleRegistration extends StatelessWidget {
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
                'Successful Account Registration !',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Thank You for signing up with TrashTrack.',
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

void _showSignInConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Text('Sign In', style: TextStyle(color: Colors.white)),
        content: Text(
            'Back to sign in now? Any data from this form will be removed!',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, 'login');
            },
            child: Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}





//1815