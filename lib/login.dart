import 'package:flutter/material.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_google.dart';
import 'package:trashtrack/styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _passwordVisible = false;
  String emailvalidator = '';
  String passvalidator = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        // leading: IconButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, 'splash');
        //     },
        //     icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) async {
                      if (didPop) {
                        return;
                      }
                       Navigator.pushNamed(context, 'splash');
                    },
                    child: Container()),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: shadowBigColor),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'TRASHTRACK',
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Please enter your account details below!',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 50),
                      // _buildTextField(
                      //   controller: _emailController,
                      //   hintText: 'Email',
                      //   keyboardType: TextInputType.emailAddress,
                      //   icon: Icons.email,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your email';
                      //     }
                      //     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      //     if (!emailRegex.hasMatch(value)) {
                      //       return 'Please enter a valid email';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        onChanged: (value) {
                          setState(() {
                            emailvalidator = _validateEmail(value);
                          });
                        },
                      ),
                      _validator(emailvalidator),
                      const SizedBox(height: 30),
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
                            color: deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        onChanged: (value) {
                          setState(() {
                            passvalidator = _validatePassword(
                                value); // Trigger validation on text change
                          });
                        },
                      ),
                      _validator(passvalidator),
                      // _buildTextField(
                      //   controller: _passController,
                      //   hintText: 'Password',
                      //   obscureText: !_passwordVisible,
                      //   icon: Icons.lock,
                      //   suffixIcon: IconButton(
                      //     icon: Icon(
                      //       _passwordVisible
                      //           ? Icons.visibility
                      //           : Icons.visibility_off,
                      //       color: Colors.grey,
                      //     ),
                      //     onPressed: () {
                      //       setState(() {
                      //         _passwordVisible = !_passwordVisible;
                      //       });
                      //     },
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your password';
                      //     }
                      //     // if (value.length < 8) {
                      //     //   return 'Password must be at least 8 characters long';
                      //     // }
                      //     // final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                      //     // final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                      //     // if (!hasLetter || !hasNumber) {
                      //     //   return 'Password must contain both letters and numbers';
                      //     // }
                      //     return null;
                      //   },
                      // ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'forgot_pass');
                          },
                          child: Text(
                            'Forget password?',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 196, 52, 41),
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  const Color.fromARGB(255, 170, 40, 31),
                            ),
                          ),
                        ),
                      ),

                      //terms and conditions
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          Center(
                              child: Text(
                            'By Signing In, you agree to TrashTrack\'s ',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'terms');
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: Text('Terms and Conditions.',
                                    style: TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.green))),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            if ((_emailController.text.isEmpty ||
                                    emailvalidator.isNotEmpty) ||
                                (_passController.text.isEmpty ||
                                    passvalidator.isNotEmpty)) {
                              setState(() {
                                emailvalidator =
                                    _validateEmail(_emailController.text);
                                passvalidator =
                                    _validatePassword(_passController.text);
                              });
                              // Show any existing error message
                            } else {
                              String? dbMessage = await loginAccount(context,
                                  _emailController.text, _passController.text);

                              // If there's an error, show it in a SnackBar
                              if (dbMessage != null) {
                                if (dbMessage == 'customer') {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  Navigator.pushReplacementNamed(
                                      context, 'c_home');
                                } else if (dbMessage == 'hauler') {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  Navigator.pushReplacementNamed(
                                      context, 'home');
                                } else if (dbMessage == '202') {
                                  Navigator.pushNamed(context, 'deactivated');
                                } else if (dbMessage == '203') {
                                  Navigator.pushNamed(context, 'suspended');
                                } else {
                                  showErrorSnackBar(context, dbMessage);
                                }
                              } else {
                                // Navigator.pushNamed(context, 'c_home');
                              }
                            }

                            // if (_formKey.currentState?.validate() ?? false) {
                            //   String? dbMessage = await loginAccount(
                            //       _emailController.text, _passController.text);

                            //   // If there's an error, show it in a SnackBar
                            //   if (dbMessage != null) {
                            //     if (dbMessage == 'customer') {
                            //       Navigator.pushReplacementNamed(context, 'c_home');
                            //     } else if (dbMessage == 'hauler') {
                            //       Navigator.pushReplacementNamed(context, 'home');
                            //     } else if (dbMessage == '202') {
                            //       Navigator.pushNamed(context, 'deactivated');
                            //     } else if (dbMessage == '203') {
                            //       Navigator.pushNamed(context, 'suspended');
                            //     } else {
                            //       showErrorSnackBar(context, dbMessage);
                            //     }
                            //   } else {
                            //     // Navigator.pushNamed(context, 'c_home');
                            //   }
                            // }
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 70.0, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: shadowColor),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                          child: Text(
                        'Or Sign in with',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                //Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleSignInScreen()));
                                handleGoogleSignIn(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: BorderSide(
                                      color: Colors.white54, width: 2.0),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account yet?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'create_acc');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Sign up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validator All
  _validator(String showValidator) {
    return showValidator != ''
        ? Text(
            showValidator,
            style: TextStyle(color: Colors.red),
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
    // if (value.length < 8) {
    //   return 'Password must be at least 8 characters long';
    // }
    // final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    // final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    // if (!hasLetter || !hasNumber) {
    //   return 'Password must contain both letters and numbers';
    // }
    return '';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    //required FormFieldValidator<String> validator,
    required ValueChanged<String?> onChanged,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(boxShadow: shadowColor),
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
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(10), // Rounded corners
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(10), // Rounded corners
          //   borderSide: const BorderSide(color: Colors.grey, width: 3.0),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(10), // Rounded corners
          //   borderSide: const BorderSide(color: Colors.green, width: 5.0),
          // ),
        ),
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
}

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hintText,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//     required IconData icon,
//     required FormFieldValidator<String> validator,
//     Widget? suffixIcon,
//   }) {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         inputDecorationTheme: InputDecorationTheme(
//           errorStyle: TextStyle(
//               color: const Color.fromARGB(
//                   255, 255, 181, 176)), // Change error text color here
//         ),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey),
//           prefixIcon: Icon(icon, color: Colors.green[600]),
//           suffixIcon: suffixIcon,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10), // Rounded corners
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10), // Rounded corners
//             borderSide: const BorderSide(color: Colors.grey, width: 3.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10), // Rounded corners
//             borderSide: const BorderSide(color: Colors.green, width: 5.0),
//           ),
//         ),
//         validator: validator,
//         onChanged: (value) {
//           // Trigger validation on text change
//           setState(() {
//             _formKey.currentState?.validate();
//           });
//         },
//       ),
//     );
//   }
// }
