import 'package:flutter/material.dart';

class CreateAcc extends StatefulWidget {
  const CreateAcc({super.key});

  @override
  State<CreateAcc> createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();
  bool _acceptTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _repassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 32, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 32, 1),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  'Welcome to \nTRASHTRACK',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Please enter your account details below!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'First Name',
                  icon: Icons.person,
                  validator: (value) {
                    // if (value == null || value.isEmpty) {
                    //   return 'Please enter your name';
                    // }
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
                    // if (value == null || value.isEmpty) {
                    //   return 'Please enter your email';
                    // }
                    // final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    // if (!emailRegex.hasMatch(value)) {
                    //   return 'Please enter a valid email';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passController,
                  hintText: 'Password',
                  obscureText: !_passwordVisible,
                  icon: Icons.lock,
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
                    // if (value == null || value.isEmpty) {
                    //   return 'Please enter your password';
                    // }
                    // if (value.length < 8) {
                    //   return 'Password must be at least 8 characters long';
                    // }
                    // final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                    // final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                    // if (!hasLetter || !hasNumber) {
                    //   return 'Password must contain both letters and numbers';
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
                    // if (value == null || value.isEmpty) {
                    //   return 'Please confirm your password';
                    // }
                    // if (value != _passController.text) {
                    //   return 'Passwords do not match';
                    // }
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushNamed(context, 'email_verify');
                        // if (_acceptTerms) {
                        //   // Handle account creation logic here
                        // } else {
                        //   // Show error if terms are not accepted
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text(
                        //           'You must accept the terms and conditions'),
                        //       backgroundColor: Colors.red,
                        //     ),
                        //   );
                        // }
                      }
                    },
                    child: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                        onPressed: () {},
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
                  255, 255, 181, 176)), // Change error text color here
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

    // return TextFormField(
    //   controller: controller,
    //   obscureText: obscureText,
    //   keyboardType: keyboardType,
    //   decoration: InputDecoration(
    //     hintText: hintText,
    //     hintStyle: TextStyle(color: Colors.grey),
    //     prefixIcon: Icon(icon, color: Colors.grey),
    //     suffixIcon: suffixIcon,
    //     filled: true,
    //     fillColor: Colors.white,
    //     border: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(30), // Rounded corners
    //     ),
    //     enabledBorder: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(30), // Rounded corners
    //       borderSide: const BorderSide(color: Colors.grey, width: 3.0),
    //     ),
    //     focusedBorder: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(30), // Rounded corners
    //       borderSide: const BorderSide(color: Colors.green, width: 5.0),
    //     ),
    //   ),
    //   validator: validator,
    //   onChanged: (value) {
    //     // Trigger validation on text change
    //     setState(() {
    //       _formKey.currentState?.validate();
    //     });
    //   },
    // );
  }
}
