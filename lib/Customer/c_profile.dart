import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trashtrack/api_email_service.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:flutter/services.dart';
import 'package:trashtrack/api_address.dart';
import 'dart:async';
import 'package:trashtrack/user_hive_data.dart';
import 'package:image_picker/image_picker.dart';

class C_ProfileScreen extends StatefulWidget {
  @override
  State<C_ProfileScreen> createState() => _C_ProfileScreenState();
}

class _C_ProfileScreenState extends State<C_ProfileScreen> {
  //user data
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  Uint8List? imageBytes;
  bool _isEditing = false;

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _mnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? imageFile;
  late final PanelController _panelController;
  bool isPanelOpen = false;

  bool _showProvinceDropdown = false;
  bool _showCityMunicipalityDropdown = false;
  bool _showBarangayDropdown = false;

  List<dynamic> _provinces = [];
  List<dynamic> _citiesMunicipalities = [];
  List<dynamic> _barangays = [];

  String? _selectedProvinceName;
  String? _selectedCityMunicipalityName;
  String? _selectedBarangayName;

  // String? _selectedProvince;
  // String? _selectedCityMunicipality;
  // String? _selectedBarangay;

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

  int _currentStep = 1;

  UserModel? userModel;
  //email verification
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  int _timerSeconds = 300;
  late Timer _timer;
  late int onResendCode;

  @override
  void initState() {
    super.initState();
    // _loadProvinces();
    _panelController = PanelController();

    _dbData();
    _startTimer();
    _timer.cancel();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _mnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _streetController.dispose();
    _postalController.dispose();

    _timer.cancel();
    _codeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

// Fetch user data from the server
  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      setState(() {
        userData = data;
        isLoading = false;
        _resetData();
        // imageBytes = userData!['profile'];

        // _fnameController.text = userData!['fname'];
        // _mnameController.text = userData!['mname'];
        // _lnameController.text = userData!['lname'];
        // _emailController.text = userData!['email'];
        // _contactController.text = userData!['contact'].toString().substring(1);
        // _streetController.text = userData!['street'];
        // _postalController.text = userData!['postal'];

        // _selectedProvinceName = userData!['province'];
        // _selectedCityMunicipalityName = userData!['city'];
        // _selectedBarangayName = userData!['brgy'];
      });

      // final data = await fetchCusData(context);
      // userData = data;
      // isLoading = false;

      // setState(() {
      //   if (userData?['profileImage'] != null) {
      //     imageBytes = base64Decode(userData!['profileImage']);
      //   }
      // });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
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
    setState(() {
      isLoading = true;
    });
    // Call your function to resend the code
    String? errorMessage = await sendCodeEmailUpdate(_emailController.text);
    if (errorMessage != null) {
      showErrorSnackBar(context, errorMessage);
      setState(() {
        isLoading = false;
      });
    } else {
      // Reset timer seconds and start a new timer
      setState(() {
        _timer.cancel();
        _codeControllers.forEach((controller) => controller.clear());
        _startTimer();
        _timerSeconds = 300; // Reset to initial countdown value
        //_timer.cancel();
      });
      setState(() {
        isLoading = false;
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

  void _resetData() {
    setState(() {
      imageFile = null;
      imageBytes = userData!['profile'];

      _fnameController.text = userData!['fname'];
      _mnameController.text = userData!['mname'];
      _lnameController.text = userData!['lname'];
      _emailController.text = userData!['email'];
      _contactController.text = userData!['contact'].toString().substring(1);
      _streetController.text = userData!['street'];
      _postalController.text = userData!['postal'];

      _selectedProvinceName = userData!['province'];
      _selectedCityMunicipalityName = userData!['city'];
      _selectedBarangayName = userData!['brgy'];

      fnamevalidator = '';
      mnamevalidator = '';
      lnamevalidator = '';
      emailvalidator = '';
      contactvalidator = '';
      provincevalidator = '';
      cityvalidator = '';
      brgyvalidator = '';
      streetvalidator = '';
      postalvalidator = '';
    });
  }

  Future<void> _pickImageGallery() async {
    _panelController.close();
    setState(() {
      isPanelOpen = false;
    });
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // Set image quality (0-100)
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      //  print('Image selected: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  Future<void> _pickImageCamera() async {
    _panelController.close();
    setState(() {
      isPanelOpen = false;
    });
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // Set image quality (0-100)
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      // print('Image selected: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  // Widget to display the image with a colored box
  Widget _buildImageContainer() {
    return Container(
      height: 200,
      width: 200,
      color: Colors.deepPurple, // Set the desired color here
      child: imageFile != null
          ? Image.file(File(imageFile!.path)) // Display the selected image
          : Center(child: Text('No image selected')),
    );
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinces = provinces;
        _showProvinceDropdown = true;
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
        _showCityMunicipalityDropdown = true;
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
        _showBarangayDropdown = true;
      });
    } catch (e) {
      print('Error fetching barangays: $e');
    }
  }

  // Validator All
  _labelValidator(String showValidator) {
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
      //print(contactNumber);
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
    if (value.length < 3) {
      return 'Atleat 3 letters long';
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
    if (value[0] != '6') {
      // Adjust according to postal code length
      return 'Invalid Postal Code';
    }
    return '';
  }

  void _cancelEdit() {
    if (imageFile != null ||
        _fnameController.text != userData!['fname'] ||
        _mnameController.text != userData!['mname'] ||
        _lnameController.text != userData!['lname'] ||
        _emailController.text != userData!['email'] ||
        '0' + _contactController.text != userData!['contact'] ||
        _selectedProvinceName != userData!['province'] ||
        _selectedCityMunicipalityName != userData!['city'] ||
        _selectedBarangayName != userData!['brgy'] ||
        _streetController.text != userData!['street'] ||
        _postalController.text != userData!['postal']) {
      _showCancelConfirmDialog(context);
    } else {
      if (_isEditing) {
        setState(() {
          _isEditing = false;
        });
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  void _showCancelConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Unsave Changes', style: TextStyle(color: Colors.white)),
          content: Text('Any changes will be reset.',
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
                setState(() {
                  _isEditing = false;
                  _resetData();
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _checkChanges() async {
    bool goodData = false;
    bool goodEmail = false;
    bool goodContact = false;
    //check if anything changes
    if (imageFile != null ||
        _fnameController.text != userData!['fname'] ||
        _mnameController.text != userData!['mname'] ||
        _lnameController.text != userData!['lname'] ||
        _emailController.text != userData!['email'] ||
        '0' + _contactController.text != userData!['contact'] ||
        _selectedProvinceName != userData!['province'] ||
        _selectedCityMunicipalityName != userData!['city'] ||
        _selectedBarangayName != userData!['brgy'] ||
        _streetController.text != userData!['street'] ||
        _postalController.text != userData!['postal']) {
      //validate data changes
      if ((_emailController.text.isEmpty || emailvalidator.isNotEmpty) ||
          (_fnameController.text.isEmpty || fnamevalidator.isNotEmpty) ||
          (mnamevalidator.isNotEmpty) ||
          (_lnameController.text.isEmpty || lnamevalidator.isNotEmpty) ||
          (_contactController.text.isEmpty || contactvalidator.isNotEmpty) ||
          (_selectedProvinceName == null || provincevalidator.isNotEmpty) ||
          (_selectedCityMunicipalityName == null || cityvalidator.isNotEmpty) ||
          (_selectedBarangayName == null || brgyvalidator.isNotEmpty) ||
          (_streetController.text.isEmpty || streetvalidator.isNotEmpty) ||
          (_postalController.text.isEmpty || postalvalidator.isNotEmpty)) {
        //call validation
        setState(() {
          emailvalidator = _validateEmail(_emailController.text);
          fnamevalidator = _validateFname(_fnameController.text);
          mnamevalidator = _validateMname(_mnameController.text);
          lnamevalidator = _validateLname(_lnameController.text);
          contactvalidator = _validateContact(_contactController.text);
          provincevalidator = _validateProvince(_selectedProvinceName);
          cityvalidator = _validateCity(_selectedCityMunicipalityName);
          brgyvalidator = _validateBrgy(_selectedBarangayName);
          streetvalidator = _validateStreet(_streetController.text);
          postalvalidator = _validatePostalCode(_postalController.text);
        });
        debugPrint('bad data');
      } else {
        debugPrint('good data');
        goodData = true;
      }

      //check email
      if (_emailController.text != userData!['email']) {
        String? emailErrorMsg = await emailCheck(_emailController.text);
        // Show any existing error message
        if (emailErrorMsg != null && _emailController.text.isNotEmpty) {
          setState(() {
            emailvalidator = emailErrorMsg;
            debugPrint('bad email');
            goodEmail = false;
          });
        } else {
          debugPrint('good email');
          goodEmail = true;
        }
      } else {
        debugPrint('good email');
        goodEmail = true;
      }

      //check contact
      if ('0' + _contactController.text != userData!['contact']) {
        String? dbContactMsg = await contactCheck(_contactController.text);
        // Show any existing error message
        if (dbContactMsg != null) {
          setState(() {
            contactvalidator = dbContactMsg;
          });
          goodContact = false;
        } else {
          print('good contact');
          goodContact = true;
        }
      } else {
        print('good contact');
        goodContact = true;
      }

      //final check
      if (goodData && goodEmail && goodContact) {
        if (_emailController.text != userData!['email']) {
          _resendCode();
          setState(() {
            _currentStep = 2;
          });
        } else {
          _showConfirmChangeDialog(context);
        }
      }
    } else {
      if (_isEditing) {
        setState(() {
          _isEditing = false;
          _resetData();
        });
        showSuccessSnackBar(context, 'No changes Made');
      } else {
        Navigator.pop(context);
      }
    }
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
                child: _currentStep == 1 ? _firstPage() : _secondPage(),
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
          if (isPanelOpen)
            Positioned.fill(
              child: InkWell(
                onTap: () {
                  _panelController.close();
                  setState(() {
                    isPanelOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 0, // Start closed
            maxHeight: MediaQuery.of(context).size.height * 0.3,
            panel: _panelContent(),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            onPanelClosed: () {
              setState(() {
                isPanelOpen = false;
              });
            },
          ),
          //  if (_panelController.isPanelOpen)
          //   Positioned.fill(child: GestureDetector(onTap: () {
          //     _panelController.close();
          //   })),
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

  //1st page
  Widget _firstPage() {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          //await _loadProvinces();
          await _dbData();
        },
        child: userData != null
            ? ListView(
                children: [
                  Column(
                    children: [
                      PopScope(
                          canPop: false,
                          onPopInvokedWithResult: (didPop, result) async {
                            if (didPop) {
                              return;
                            }
                            _cancelEdit();
                          },
                          child: Container()),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            boxShadow: shadowBigColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                // if (imageBytes != null ||
                                //     _imageFile != null) {
                                //}
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => _imagePreview(
                                          context, imageFile, imageBytes)),
                                );
                              },
                              child: Stack(
                                children: [
                                  imageBytes != null || imageFile != null
                                      ? Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              boxShadow: shadowColor,
                                              color: Colors.deepPurple),
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage: imageFile != null
                                                ? FileImage(
                                                    File(imageFile!.path))
                                                : MemoryImage(imageBytes!),
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              boxShadow: shadowColor,
                                              color: Colors.deepPurple),
                                          child: Icon(
                                            Icons.person,
                                            size: 100,
                                            color: Colors.white,
                                          ),
                                        ),
                                  if (_isEditing)
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            //_pickImageCamera();
                                            // if (_isEditing)
                                            //   _pickImageGallery();

                                            if (_isEditing) {
                                              _panelController.open();
                                              setState(() {
                                                isPanelOpen = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.grey[200]),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.deepPurple),
                                              child: Icon(
                                                Icons.photo_camera,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ))
                                ],
                              ),
                            ),
                            if (!_isEditing)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      boxShadow: shadowColor,
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.deepPurple),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          right: 20,
                          left: 20,
                          bottom: 50,
                        ),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            boxShadow: shadowBigColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: _isEditing
                            ? Column(
                                children: [
                                  _buildTextField(
                                    controller: _fnameController,
                                    hintText: 'First Name',
                                    onChanged: (value) {
                                      setState(() {
                                        fnamevalidator = _validateFname(
                                            value); // Trigger validation on text change
                                      });
                                    },
                                  ),
                                  _labelValidator(fnamevalidator),
                                  const SizedBox(height: 5),
                                  _buildTextField(
                                    controller: _mnameController,
                                    hintText: 'Middle Name (Optional)',
                                    onChanged: (value) {
                                      setState(() {
                                        mnamevalidator = _validateMname(
                                            value); // Trigger validation on text change
                                      });
                                    },
                                  ),
                                  _labelValidator(mnamevalidator),
                                  const SizedBox(height: 5),
                                  _buildTextField(
                                    controller: _lnameController,
                                    hintText: 'Last Name',
                                    onChanged: (value) {
                                      setState(() {
                                        lnamevalidator = _validateLname(
                                            value); // Trigger validation on text change
                                      });
                                    },
                                  ),
                                  _labelValidator(lnamevalidator),
                                  const SizedBox(height: 5),
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    onChanged: (value) {
                                      setState(() {
                                        emailvalidator = _validateEmail(
                                            value); // Trigger validation on text change
                                      });
                                    },
                                  ),
                                  _labelValidator(emailvalidator),
                                  const SizedBox(height: 5),
                                  _buildNumberField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                  ),
                                  _labelValidator(contactvalidator),
                                  const SizedBox(height: 20),
                                  Center(
                                      child: Text(
                                    'Complete Address',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  )),
                                  const SizedBox(height: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '  Province/City or Municipality/Barangay',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: greytitleColor),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                  horizontal: 15),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  boxShadow: shadowColor),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Show selected values
                                                  Expanded(
                                                    child: Text(
                                                      _selectedProvinceName ==
                                                              null
                                                          ? 'Select Province'
                                                          : _selectedCityMunicipalityName ==
                                                                  null
                                                              ? '${_selectedProvinceName} / '
                                                              : _selectedBarangayName ==
                                                                      null
                                                                  ? '${_selectedProvinceName} / ${_selectedCityMunicipalityName} / '
                                                                  : '${_selectedProvinceName} / '
                                                                      '${_selectedCityMunicipalityName} / '
                                                                      '${_selectedBarangayName}',
                                                      style: TextStyle(
                                                          fontSize: 16.0),
                                                      overflow: TextOverflow
                                                          .visible, // Allow wrapping
                                                      softWrap:
                                                          true, // Enable soft wrapping
                                                    ),
                                                  ),
                                                  IconButton(
                                                      icon: Icon(
                                                        Icons.clear,
                                                        color:
                                                            Colors.deepPurple,
                                                      ),
                                                      onPressed: () {
                                                        //close
                                                        _loadProvinces();
                                                        setState(() {
                                                          _provinces = [];
                                                          _citiesMunicipalities =
                                                              [];
                                                          _barangays = [];

                                                          _showCityMunicipalityDropdown =
                                                              false;
                                                          _showBarangayDropdown =
                                                              false;

                                                          _selectedProvinceName =
                                                              null;
                                                          _selectedCityMunicipalityName =
                                                              null;
                                                          _selectedBarangayName =
                                                              null;
                                                        });
                                                      })
                                                ],
                                              ),
                                            ),
                                            if (_showProvinceDropdown)
                                              Container(
                                                height: 100,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.deepPurple
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            bottom:
                                                                Radius.circular(
                                                                    15)),
                                                    boxShadow: shadowColor),
                                                child: ListView.builder(
                                                  itemCount: _provinces.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final city =
                                                        _provinces[index];

                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _loadCitiesMunicipalities(
                                                              city[
                                                                  'code']); // Load barangays for the selected city

                                                          _selectedProvinceName =
                                                              city[
                                                                  'name']; // Set by name
                                                          _showProvinceDropdown =
                                                              false;
                                                          _showCityMunicipalityDropdown =
                                                              true;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10,
                                                                horizontal: 15),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300)),
                                                        ),
                                                        child: Text(
                                                          city[
                                                              'name'], // Display the name
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            if (_showCityMunicipalityDropdown)
                                              Container(
                                                height: 400,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.deepPurple
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            bottom:
                                                                Radius.circular(
                                                                    15)),
                                                    boxShadow: shadowColor),
                                                child: ListView.builder(
                                                  itemCount:
                                                      _citiesMunicipalities
                                                          .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final city =
                                                        _citiesMunicipalities[
                                                            index];

                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _loadBarangays(
                                                              city['code']);

                                                          _selectedCityMunicipalityName =
                                                              city['name'];
                                                          _showCityMunicipalityDropdown =
                                                              false;
                                                          _showBarangayDropdown =
                                                              true;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10,
                                                                horizontal: 15),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300)),
                                                        ),
                                                        child: Text(
                                                          city[
                                                              'name'], // Display the name
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                            //brgy ddl
                                            if (_showBarangayDropdown)
                                              Container(
                                                height: 400,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.deepPurple
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            bottom:
                                                                Radius.circular(
                                                                    15)),
                                                    boxShadow: shadowColor),
                                                child: ListView.builder(
                                                  itemCount: _barangays.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final city =
                                                        _barangays[index];

                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedBarangayName =
                                                              city['name'];
                                                          _showBarangayDropdown =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10,
                                                                horizontal: 15),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300)),
                                                        ),
                                                        child: Text(
                                                          city[
                                                              'name'], // Display the name
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_selectedProvinceName == null ||
                                      _selectedCityMunicipalityName == null ||
                                      _selectedBarangayName == null)
                                    Text(
                                      'Please select your adrress.',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  const SizedBox(height: 5),
                                  _buildTextField(
                                    controller: _streetController,
                                    hintText:
                                        'Street Name, Building, House No.',
                                    onChanged: (value) {
                                      setState(() {
                                        streetvalidator = _validateStreet(
                                            value); // Trigger validation on text change
                                      });
                                    },
                                  ),
                                  _labelValidator(streetvalidator),
                                  const SizedBox(height: 5),
                                  _buildTextField(
                                    controller: _postalController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    hintText: 'Postal Code',
                                    onChanged: (value) {
                                      setState(() {
                                        postalvalidator = _validatePostalCode(
                                            value); // Trigger validation on text change
                                        //print(_postalController.text);
                                      });
                                    },
                                  ),
                                  _labelValidator(postalvalidator),
                                  const SizedBox(height: 20),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _checkChanges();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 40.0, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.green[500],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: shadowColor),
                                          child: Text(
                                            'SAVE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      InkWell(
                                        onTap: () {
                                          _cancelEdit();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 30.0, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.blue[700],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: shadowColor),
                                          child: Text(
                                            'CANCEL',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _labelField(
                                      label: 'Full Name',
                                      value:
                                          '${userData?['fname'] ?? ''} ${userData?['mname'] ?? ''} ${userData?['lname'] ?? ''}'),
                                  _labelField(
                                      label: 'Email',
                                      value: userData?['email'] ?? ''),
                                  _labelField(
                                      label: 'Phone Number',
                                      value: userData?['contact'] ?? ''),
                                  _labelField(
                                      label: 'Address',
                                      value:
                                          '${userData?['street'] ?? ''}, ${userData?['brgy'] ?? ''}, ${userData?['city'] ?? ''}, ${userData?['province'] ?? ''}, ${userData?['postal'] ?? ''}'),
                                  _labelField(
                                      label: 'Status',
                                      value: userData?['status'] ?? ''),
                                  _labelField(
                                      label: 'Type',
                                      value: userData?['type'] ?? ''),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              )
            : Center(child: Text('Error: $errorMessage')),
      ),
    );
  }

  Widget _panelContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Center(
          child: Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'Change Profile Picture',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height * .2,
          child: Material(
            color: Colors.transparent,
            child: ListView(
              children: [
                ListTile(
                  onTap: _pickImageCamera,
                  leading: Icon(Icons.camera_alt, color: deepPurple),
                  title: Text(
                    "Take Photo",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  onTap: _pickImageGallery,
                  leading: Icon(Icons.photo_library, color: deepPurple),
                  title: Text(
                    "Choose from Gallery",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //2nd page
  Widget _secondPage() {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
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
        //leading: SizedBox(),
        leadingWidth: 70,
      ),
      body: ListView(
        children: [
          PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) {
                  return;
                }
                setState(() {
                  _currentStep--;
                });
              },
              child: Container()),
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
                        _emailController.text,
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
                            style: TextStyle(color: Colors.white, fontSize: 24),
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
                        String? errorMessage = await verifyEmailCode(
                            _emailController.text, enteredCode);
                        if (errorMessage != null) {
                          showErrorSnackBar(context, errorMessage);
                        } else {
                          //convert the pic
                          Uint8List? photoBytes;
                          if (imageFile != null) {
                            photoBytes = await imageFile!
                                .readAsBytes(); // Read bytes from the XFile
                          } else if (userData!['profile'] != null) {
                            photoBytes = userData!['profile'];
                          }

                          String? updateMsg = await userUpdate(
                              context,
                              userData!['id'],
                              _fnameController.text,
                              _mnameController.text,
                              _lnameController.text,
                              _emailController.text,
                              photoBytes,
                              '0' + _contactController.text,
                              _selectedProvinceName!,
                              _selectedCityMunicipalityName!,
                              _selectedBarangayName!,
                              _streetController.text,
                              _postalController.text);

                          if (updateMsg == 'success') {
                            setState(() {
                              isLoading = true;
                            });

                            if (!mounted) return;
                            await _dbData();
                            // Update the user data in the provider
                            userModel!.setUserData(
                                _fnameController.text,
                                userModel!.lname ??
                                    '', // Keep current last name
                                userModel!.email ?? '', 
                                userModel!.auth ?? '', 
                                photoBytes);

                            setState(() {
                              _resetData();
                              _isEditing = false;
                              isLoading = false;
                              //_currentStep--;
                            });

                            setState(() {
                              _currentStep--; // Separate this update
                            });
                          } else {
                            showErrorSnackBar(context,
                                'Something went wrong. Please try again later.');
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
    );
  }

  Widget _labelField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: shadowColor),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 18.0,
                //shadows: shadowColor
              ),
            ),
          ),
          SizedBox(height: 10)
          // Divider(
          //   color: Colors.deepPurple.withOpacity(0.5),
          // ),
        ],
      ),
    );
  }

  Widget _imagePreview(BuildContext context, final XFile? imageFile,
      final Uint8List? imageBytes) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: imageFile != null
            ? Image.file(File(imageFile.path))
            : imageBytes != null
                ? Image.memory(imageBytes)
                : Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: deepPurple,
                        borderRadius: BorderRadius.circular(100)),
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: white,
                    ),
                  ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String?> onChanged,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' ' + hintText,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          Container(
            decoration: BoxDecoration(boxShadow: shadowColor),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              inputFormatters: inputFormatters,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' Contact',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          Container(
            decoration: BoxDecoration(boxShadow: shadowColor),
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
                            color: Colors.deepPurple,
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
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: inputFormatters,
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
          ),
        ],
      ),
    );
  }

//ddl
  Widget _buildDropdown({
    required String? selectedValue,
    required List<dynamic> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' ${hintText}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          Container(
            decoration: BoxDecoration(boxShadow: shadowColor),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.deepPurple,
                size: 30,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              items: items.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['code'],
                  child: Text(
                      item['name']), // Use the appropriate field for display
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Confirm Changes', style: TextStyle(color: Colors.white)),
          content: Text('Save changes to your profile details?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });
                //convert the pic
                Uint8List? photoBytes;
                if (imageFile != null) {
                  photoBytes = await imageFile!
                      .readAsBytes(); // Read bytes from the XFile
                } else if (userData!['profile'] != null) {
                  photoBytes = userData!['profile'];
                }

                String? updateMsg = await userUpdate(
                    context,
                    userData!['id'],
                    _fnameController.text,
                    _mnameController.text,
                    _lnameController.text,
                    _emailController.text,
                    photoBytes,
                    '0' + _contactController.text,
                    _selectedProvinceName!,
                    _selectedCityMunicipalityName!,
                    _selectedBarangayName!,
                    _streetController.text,
                    _postalController.text);

                if (updateMsg == 'success') {
                  if (!mounted) return;
                  await _dbData();
                  setState(() {
                    // Update the user data in the provider
                    userModel!.setUserData(
                        _fnameController.text,
                        userModel!.lname ?? '', // Keep current last name
                        userModel!.email ?? '',
                        userModel!.auth ?? '', 
                        photoBytes);

                    _resetData();
                    _isEditing = false;
                    isLoading = false;

                    //Navigator.pop(context);
                  });
                } else {
                  showErrorSnackBar(
                      context, 'Something went wrong. Please try again later.');
                }

                //_showConfirmationDialog(context);
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}



// class EditProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Container(
//             padding: EdgeInsets.all(20.0),
//             margin: EdgeInsets.symmetric(horizontal: 20.0),
//             decoration: BoxDecoration(
//               color: Colors.green[900],
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: AssetImage('assets/anime.jpg'),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'customer Kim',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 Divider(color: Colors.white),
//                 EditProfileField(
//                   label: 'First Name',
//                   initialValue: 'customer',
//                 ),
//                 EditProfileField(
//                   label: 'Middle Name',
//                   initialValue: '',
//                 ),
//                 EditProfileField(
//                   label: 'Last Name',
//                   initialValue: 'Kim',
//                 ),
//                 EditProfileField(
//                   label: 'Email',
//                   initialValue: 'customer@gmail.com',
//                 ),
//                 EditProfileField(
//                   label: 'Phone Number',
//                   initialValue: '+639878899999',
//                 ),
//                 EditProfileField(
//                   label: 'Address',
//                   initialValue: '123 customer Street',
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     _showConfirmChangeDialog(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
//                   ),
//                   child: Text(
//                     'Save',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// void _showConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.green[900],
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0))),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle, color: Colors.green, size: 60),
//             SizedBox(height: 20),
//             Text(
//               'Profile Saved!',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Your information details has been successfully changed.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Continue updating details or other actions here
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
//               ),
//               child: Text(
//                 'Okay',
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
