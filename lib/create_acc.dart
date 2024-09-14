import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';
import 'package:flutter/material.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/create_acc2.dart';
import 'package:trashtrack/create_email_verify.dart';
import 'package:trashtrack/styles.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/api_address.dart';

//google
import 'package:trashtrack/api_google.dart';

class CreateAcc extends StatefulWidget {
  @override
  _CreateAccState createState() => _CreateAccState();
}

class _CreateAccState extends State<CreateAcc> {
  int _currentStep = 0;

  // Controllers for the input fields
  String? _selectedWasteType;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _mnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvince;
  String? _selectedCityMunicipality;
  String? _selectedBarangay;

  bool _acceptTerms = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    // implement dispose
    super.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _fnameController.dispose();
    _mnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _repassController.dispose();
    _contactController.dispose();
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
        _selectedCityMunicipality = null;
        _selectedBarangay = null;
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
        _selectedBarangay = null;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

  // List of waste types
  final List<String> _wasteTypes = [
    'Municipal Waste',
    'Construction Waste',
    'Food Waste'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _currentStep == 0
                ? _buildFirstStep()
                : _currentStep == 1
                    ? _buildSecondStep()
                    : _currentStep == 2
                        ? _buildThirdStep()
                        : _buildFourthStep(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  )
                else
                  Container(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep++;
                      });
                    } else if (_currentStep == 3) {
                      Navigator.pushNamed(context, 'c_schedule');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: Text(
                    _currentStep < 3 ? 'Next' : 'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dot indicator below AppBar
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 20,
              color: _currentStep >= index ? Colors.green : Colors.grey,
            ),
            if (index != 3)
              Container(
                width: 30,
                height: 5,
                color: _currentStep > index ? Colors.green : Colors.grey,
              ),
          ],
        );
      }),
    );
  }

  ///1st page
  Widget _buildFirstStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text(
          'Registration',
          style: TextStyle(
            fontSize: 40,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildDotIndicator(),
                const SizedBox(height: 30),
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
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        Form.of(context).validate();
                      });
                    }
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
                  onChanged: (value) {
                    setState(() {
                      _formKey.currentState!.validate();
                    });
                    _formKey.currentState!.validate();
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
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _formKey.currentState?.validate();
                      });
                    }
                  },
                ),
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAcc2()));
                    },
                    child: Text('Create2')),
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

  ///2nd page
  Widget _buildSecondStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        leading: SizedBox(),
        title: const Text(
          'Registration',
          style: TextStyle(
            fontSize: 40,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildDotIndicator(),
                const SizedBox(height: 30),
                const Text(
                  'Please enter your account details below!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _fnameController,
                  hintText: 'First Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _formKey.currentState?.validate();
                      });
                    }
                  },
                ),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _mnameController,
                  hintText: 'Middle Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    return null;
                  },
                  onChanged: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _formKey.currentState?.validate();
                      });
                    }
                  },
                ),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: _lnameController,
                  hintText: 'Last Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _formKey.currentState?.validate();
                    });
                  },
                ),
                const SizedBox(height: 5),
                _buildContactNumberField(), //phone #
                const SizedBox(height: 5),
                _buildDropdown(
                  selectedValue: _selectedProvince,
                  items: _provinces,
                  hintText: 'Select Province',
                  icon: Icons.location_city,
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = value;
                    });
                    _loadCitiesMunicipalities(value!);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Province';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),
                _buildDropdown(
                  selectedValue: _selectedCityMunicipality,
                  items: _citiesMunicipalities,
                  hintText: 'Select City/Municipality',
                  icon: Icons.apartment,
                  onChanged: (value) {
                    setState(() {
                      _selectedCityMunicipality = value;
                    });
                    _loadBarangays(value!);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select City/Municipality';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),
                _buildDropdown(
                  selectedValue: _selectedBarangay,
                  items: _barangays,
                  hintText: 'Select Barangay',
                  icon: Icons.home,
                  onChanged: (value) {
                    setState(() {
                      _selectedBarangay = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Barangay';
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

  Widget _buildThirdStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Step 3/3',
            style: TextStyle(
                color: accentColor, fontSize: 25, fontWeight: FontWeight.bold)),
        leading: SizedBox(width: 0),
        leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text(
                  'Credit Card',
                ),
                value: 'Credit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text('Debit Card'),
                value: 'Debit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text('GCash'),
                value: 'GCash',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFourthStep() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Step 4/4',
            style: TextStyle(
                color: accentColor, fontSize: 25, fontWeight: FontWeight.bold)),
        leading: SizedBox(width: 0),
        leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text(
                  'Credit Card',
                ),
                value: 'Credit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text('Debit Card'),
                value: 'Debit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Color(0xFF86BF3E),
                title: Text('GCash'),
                value: 'GCash',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ],
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
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
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
        validator: validator,
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

  Widget _buildContactNumberField() {
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your contact number';
          }
          final contactNumber = value.replaceFirst(RegExp(r'^0'), '');
          if (contactNumber.length != 10 || !contactNumber.startsWith('9')) {
            return 'Invalid Phone Number';
          }
          return null;
        },
        onChanged: (value) {
          if (value.length > 10) {
            _contactController.text = value.substring(0, 10);
            _contactController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contactController.text.length));
          }
          setState(() {
            _formKey.currentState?.validate();
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
    required FormFieldValidator<String> validator,
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
            value: item['code'], // Use the appropriate field for value
            child: Text(item['name']), // Use the appropriate field for display
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDropDownList(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedWasteType,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              //labelText: 'Select Waste Type',
              labelStyle: TextStyle(color: accentColor),
              hintText: 'Select Waste Type',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            items: _wasteTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  //style: TextStyle(backgroundColor: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedWasteType = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextboxField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            //style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              filled: true,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String hint) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF86BF3E)),
                SizedBox(width: 10.0),
                Text(
                  _selectedDate == null
                      ? hint
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, // Circle color for the selected date
              onPrimary: Colors.white, // Text color inside the circle
              onSurface: Colors.green[900]!, // Text color for dates
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}




// import 'package:flutter/material.dart';
// import 'package:trashtrack/api_email_service.dart';
// import 'package:trashtrack/create_acc2.dart';
// import 'package:trashtrack/create_email_verify.dart';
// import 'package:trashtrack/styles.dart';

// //google
// import 'package:trashtrack/api_google.dart';

// class CreateAcc extends StatefulWidget {
//   const CreateAcc({super.key});

//   @override
//   State<CreateAcc> createState() => _CreateAccState();
// }

// class _CreateAccState extends State<CreateAcc> {

//   final TextEditingController _fnameController = TextEditingController();
//   final TextEditingController _lnameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passController = TextEditingController();
//   final TextEditingController _repassController = TextEditingController();
//   bool _acceptTerms = false;
//   bool _passwordVisible = false;
//   bool _confirmPasswordVisible = false;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _fnameController.dispose();
//     _lnameController.dispose();
//     _emailController.dispose();
//     _passController.dispose();
//     _repassController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         foregroundColor: Colors.white,
//         title: const Text(
//                   'Sign Up',
//                   style: TextStyle(
//                     fontSize: 40,
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pushNamed(context, 'splash');
//             },
//             icon: Icon(Icons.arrow_back)),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // const Text(
//                 //   'Sign Up',
//                 //   style: TextStyle(
//                 //     fontSize: 40,
//                 //     color: Colors.green,
//                 //     fontWeight: FontWeight.bold,
//                 //   ),
//                 // ),
//                 const Text(
//                   'Please enter your account details below!',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 30),
//                 _buildTextField(
//                   controller: _fnameController,
//                   hintText: 'First Name',
//                   icon: Icons.person_outline,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 _buildTextField(
//                   controller: _lnameController,
//                   hintText: 'Last Name',
//                   icon: Icons.person,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 _buildTextField(
//                   controller: _emailController,
//                   hintText: 'Email',
//                   keyboardType: TextInputType.emailAddress,
//                   icon: Icons.email,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 _buildTextField(
//                   controller: _passController,
//                   hintText: 'Password',
//                   obscureText: !_passwordVisible,
//                   icon: Icons.lock_outline,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _passwordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _passwordVisible = !_passwordVisible;
//                       });
//                     },
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 8) {
//                       return 'Password must be at least 8 characters long';
//                     }
//                     final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
//                     final hasNumber = RegExp(r'[0-9]').hasMatch(value);
//                     if (!hasLetter || !hasNumber) {
//                       return 'Password must contain both letters and numbers';
//                     }
//                     // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
//                     //   return 'Password must contain a special character';
//                     // }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 _buildTextField(
//                   controller: _repassController,
//                   hintText: 'Confirm Password',
//                   obscureText: !_confirmPasswordVisible,
//                   icon: Icons.lock,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _confirmPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _confirmPasswordVisible = !_confirmPasswordVisible;
//                       });
//                     },
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 //const SizedBox(height: 20),

//                 // Checkbox terms
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _acceptTerms,
//                       activeColor: Colors.green,
//                       onChanged: (bool? newValue) {
//                         setState(() {
//                           _acceptTerms = newValue ?? false;
//                         });
//                       },
//                     ),
//                     Text(
//                       'I accept the ',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, 'terms');
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.zero,
//                       ),
//                       child: Text(
//                         'terms and conditions.',
//                         style: TextStyle(
//                           color: Colors.green,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.green,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 // const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         if (_acceptTerms) {
//                           showSuccessSnackBar(context, 'Loading . . .');
//                           String? errorMessage = await sendEmailCodeCreateAcc(
//                               _emailController.text);
//                           if (errorMessage != null) {
//                             showErrorSnackBar(context, errorMessage);
//                           } else {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         VerifyEmailCreateAccScreen(
//                                             fname: _fnameController.text,
//                                             lname: _lnameController.text,
//                                             email: _emailController.text,
//                                             password: _passController.text)));
//                           }
//                         } else {
//                           showErrorSnackBar(context,
//                               'You must accept the terms and conditions');
//                         }
//                       }
//                     },
//                     child: const Text('Continue'),
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 100, vertical: 14),
//                         textStyle: const TextStyle(
//                             fontSize: 25, fontWeight: FontWeight.bold),
//                         foregroundColor: Colors.white),
//                   ),
//                 ),
//                 ElevatedButton(onPressed: (){
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAcc2()));
//                 }, child: Text('Create2')),
//                 Center(
//                   child: Column(
//                     children: [
//                       SizedBox(height: 10.0),
//                       Text(
//                         'Or continue with',
//                         style: TextStyle(color: Colors.white70, fontSize: 16.0),
//                       ),
//                       SizedBox(height: 10.0),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           //handleSignIn(); //google sign in
//                            handleGoogleSignUp(context);
//                           //Navigator.push(context, MaterialPageRoute(builder: (context) => C_HomeScreen()));
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30.0),
//                             side: BorderSide(color: Colors.white54, width: 2.0),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                               vertical: 10.0, horizontal: 35.0),
//                         ),
//                         icon: Image.asset(
//                           'assets/Brands.png',
//                           height: 24.0,
//                         ),
//                         label: Text(
//                           'Google',
//                           style:
//                               TextStyle(color: Colors.white70, fontSize: 18.0),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Already have an account?',
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, 'login');
//                         },
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                         ),
//                         child: const Text(
//                           'Sign in',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: 16,
//                             fontStyle: FontStyle.italic,
//                             decoration: TextDecoration.underline,
//                             decorationColor: Colors.green,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

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
//                   255, 255, 181, 176)), // Change error text color
//         ),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey),
//           prefixIcon: Icon(icon, color: Colors.grey),
//           suffixIcon: suffixIcon,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30), // Rounded corners
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30), // Rounded corners
//             borderSide: const BorderSide(color: Colors.grey, width: 3.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30), // Rounded corners
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

// import 'package:flutter/material.dart';

// class CreateAcc extends StatefulWidget {
//   @override
//   _CreateAccState createState() => _CreateAccState();
// }

// class _CreateAccState extends State<CreateAcc> {
//   PageController _pageController = PageController(initialPage: 0);

//   // Form Data
//   String? fname;
//   String? lname;
//   String? address;
//   String? contact;
//   String? email;
//   String? password;
//   String? confirmPassword;

//   int _currentPage = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Signup Flow"),
//       ),
//       body: Column(
//         children: [
//           _buildDotIndicator(),  // 3-dot Indicator
//           Expanded(
//             child: PageView(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPage = index;
//                 });
//               },
//               children: [
//                 _buildFirstPage(context),
//                 _buildSecondPage(context),
//                 _buildThirdPage(context),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Dot indicator below AppBar
//   Widget _buildDotIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(3, (index) {
//         return Row(
//           children: [
//             Icon(
//               Icons.circle,
//               size: 10,
//               color: _currentPage >= index ? Colors.green : Colors.grey,
//             ),
//             if (index != 2)
//               Container(
//                 width: 30,
//                 height: 2,
//                 color: _currentPage > index ? Colors.green : Colors.grey,
//               ),
//           ],
//         );
//       }),
//     );
//   }

//   // First Page (Personal Details)
//   Widget _buildFirstPage(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text("Personal Details", style: TextStyle(fontSize: 24)),
//           TextField(
//             decoration: InputDecoration(labelText: "First Name"),
//             onChanged: (value) => fname = value,
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: "Last Name"),
//             onChanged: (value) => lname = value,
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: "Address"),
//             onChanged: (value) => address = value,
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: "Contact Number"),
//             keyboardType: TextInputType.phone,
//             onChanged: (value) => contact = value,
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               _pageController.nextPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.ease,
//               );
//             },
//             child: Text("Next"),
//           ),
//           SizedBox(height: 20),
//           TextButton(
//             onPressed: () {
//               // Google Sign-In function
//             },
//             child: Text("Continue with Google"),
//           ),
//           TextButton(
//             onPressed: () {
//               // Navigate to Sign In
//             },
//             child: Text("Already have an account? Sign in"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Second Page (Account Details)
//   Widget _buildSecondPage(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text("Account Details", style: TextStyle(fontSize: 24)),
//           TextField(
//             decoration: InputDecoration(labelText: "Email"),
//             onChanged: (value) => email = value,
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: "Password"),
//             obscureText: true,
//             onChanged: (value) => password = value,
//           ),
//           TextField(
//             decoration: InputDecoration(labelText: "Confirm Password"),
//             obscureText: true,
//             onChanged: (value) => confirmPassword = value,
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               _pageController.nextPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.ease,
//               );
//             },
//             child: Text("Next"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Third Page (Email Verification)
//   Widget _buildThirdPage(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text("Verify Email", style: TextStyle(fontSize: 24)),
//           Text("We sent a code to your email."),
//           // Add your verification code input here
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Perform verification and move forward
//             },
//             child: Text("Verify"),
//           ),
//         ],
//       ),
//     );
//   }
// }
