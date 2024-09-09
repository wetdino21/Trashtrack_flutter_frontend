import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/create_email_verify.dart';
import 'package:trashtrack/styles.dart';

//google
import 'package:trashtrack/api_google.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CreateAcc extends StatefulWidget {
  const CreateAcc({super.key});

  @override
  State<CreateAcc> createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  // google sign in
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Future<void> handleSignIn() async {
  //   try {
  //     GoogleSignInAccount? user = await _googleSignIn.signIn();
  //     if (user != null) {
  //       print('Signed in: ${user.displayName?.split(' ').first}}');
  //       print('Signed in: ${user.displayName?.split(' ').last}}');
  //       print('Signed in: ${user.email}');
  //       print('Signed in: ${user.photoUrl}');

  //       String? fullname = user.displayName;
  //       String fname = fullname != null ? fullname.split(' ').first : '';
  //       String lname = fullname != null ? fullname.split(' ').last : '';
  //       String email = user.email;
  //       String? photoUrl = user.photoUrl;

  //     // Fetch the photo as bytes
  //     Uint8List? photoBytes;
  //     if (photoUrl != null) {
  //       http.Response response = await http.get(Uri.parse(photoUrl));
  //       if (response.statusCode == 200) {
  //         photoBytes = response.bodyBytes;
  //       }
  //     }
  //       //_handleSignInData(user.displayName, user.email, user.photoUrl);

  //       //////check if existing email
  //       String? dbMessage = await emailCheck(user.email);
  //       if (dbMessage != null) {
  //         showErrorSnackBar(context, dbMessage);
  //       } else {
  //         //create account from google

  //         // String? createMessage =
  //         //     await createGoogleAccount(fname, lname, email, photoBytes);
  //         // if (createMessage != null) {
  //         //   showErrorSnackBar(context, createMessage);
  //         // } else {
  //         //   showSuccessSnackBar(context, 'Successfully Created Account');
  //         //  // Navigator.pushReplacementNamed(context, 'c_home');
  //         //   _handleSignOut();
  //         // }

  //         createGoogleAccount(context, fname, lname, email, photoBytes);
  //       }
  //     } else {
  //       print('Sign-in canceled');
  //     }
  //     _handleSignOut();
  //   } catch (error) {
  //     print('Sign-in failed: $error');
  //   }
  // }

  // void _handleSignInData(String? displayName, String? email, String? photoUrl) {
  //   // Handle the data here
  //   print('Display Name: $displayName');
  //   print('Email: $email');
  //   print('Photo URL: $photoUrl');
  // }
  
  // Future<void> _handleSignOut() async {
  //   await _googleSignIn.signOut();
  //   print('Signed out');
  // }

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();
  bool _acceptTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _repassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'splash');
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Please enter your account details below!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _fnameController,
                  hintText: 'First Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _lnameController,
                  hintText: 'Last Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
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
                  validator: (value) {
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
                  },
                ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                //const SizedBox(height: 20),

                // Checkbox terms
                Row(
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
                // const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_acceptTerms) {
                          showSuccessSnackBar(context, 'Loading . . .');
                          String? errorMessage = await sendEmailCodeCreateAcc(
                              _emailController.text);
                          if (errorMessage != null) {
                            showErrorSnackBar(context, errorMessage);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VerifyEmailCreateAccScreen(
                                            fname: _fnameController.text,
                                            lname: _lnameController.text,
                                            email: _emailController.text,
                                            password: _passController.text)));
                          }
                        } else {
                          showErrorSnackBar(context,
                              'You must accept the terms and conditions');
                        }
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
                          //handleSignIn(); //google sign in
                           handleGoogleSignUp(context);
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => C_HomeScreen()));
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
                          Navigator.pushNamed(context, 'login');
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    required FormFieldValidator<String> validator,
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
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
            borderSide: const BorderSide(color: Colors.grey, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
            borderSide: const BorderSide(color: Colors.green, width: 5.0),
          ),
        ),
        validator: validator,
        onChanged: (value) {
          // Trigger validation on text change
          setState(() {
            _formKey.currentState?.validate();
          });
        },
      ),
    );
  }
}
