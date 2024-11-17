import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
import 'package:trashtrack/mainApp.dart';
import 'dart:io';
import 'package:trashtrack/styles.dart';
import 'package:image/image.dart' as img;

class VerifyCustomer extends StatefulWidget {
  const VerifyCustomer({super.key});

  @override
  State<VerifyCustomer> createState() => _VerifyCustomerState();
}

class _VerifyCustomerState extends State<VerifyCustomer> {
  XFile? _selectedIDImage;
  XFile? _selectedSelfieImage;
  bool _faceDetected = false;
  late final PanelController _panelController;
  bool _isPanelOpen = false;
  bool isID = false;
  String? iDValidator;
  String? selfieValidator;
  bool _loadingAction = false;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  //face detector instance
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  Future<void> _pickImage(ImageSource source, bool isImageID) async {
    setState(() {
      _panelController.close();
      _isPanelOpen = false;
    });

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (!isImageID) {
        bool isFace = await _detectFace(pickedFile);
        if (!isFace) {
          setState(() {
            _faceDetected = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No face detected. Please upload a clear selfie.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        } else {
          setState(() {
            _faceDetected = true;
            _selectedSelfieImage = pickedFile;
            selfieValidator = null;
          });
        }
      } else {
        setState(() {
          _selectedIDImage = pickedFile;
          iDValidator = null;
        });
      }
    }
  }

  // Detect face in the given image
  Future<bool> _detectFace(XFile xfile) async {
    final imageFile = File(xfile.path);
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty; // Return true if faces are detected
    } catch (e) {
      print("Error detecting face: $e");
      return false; // Return false if an error occurs or no face is detected
    }
  }

  Widget _imagePreview(BuildContext context, XFile? imageFile) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred background
                imageFile != null
                    ? Image.file(
                        File(imageFile.path),
                        fit: BoxFit.cover,
                      )
                    : Container(),

                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(),
                ),
              ],
            ),
          ),
          // Center content with the image or icon
          Center(
            child: Container(
              child: imageFile != null
                  ? Image.file(File(imageFile.path))
                  : Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: deepPurple, borderRadius: BorderRadius.circular(100)),
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelContent(bool isImageID) {
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
                  onTap: () async {
                    _pickImage(ImageSource.camera, isImageID);
                  },
                  leading: Icon(Icons.camera_alt, color: deepPurple),
                  title: Text(
                    "Take Photo",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    _pickImage(ImageSource.gallery, isImageID);
                  },
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

  //compress image
  Uint8List? compressImage(Uint8List imageBytes, {int quality = 70}) {
    // Decode the image from the provided bytes
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      return null; // Return null if the image cannot be decoded
    }

    img.Image resizedImage = img.copyResize(image, width: 700);

    // Encode the image to JPEG format with a specified quality
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality));
  }

  Widget _validator(String? validatorText) {
    return validatorText != null
        ? Text(
            validatorText,
            style: TextStyle(color: redSoft),
          )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: const Text('Account Verification'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Process',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This process will take up to 3 days. '
                      'You will receive a notification once the process is complete.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              Divider(
                color: deepPurple,
                thickness: 7,
              ),

              // ID Upload Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Valid ID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please upload a clear image of the front side of a valid ID (such as a Driver's License, Passport, SSS ID, Unified Multi-Purpose ID (UMID), Philippine National ID, Voter's ID, Postal ID, PRC ID, or Alien Certificate of Registration (ACR) Card for foreigners). Ensure the image is legible and all details are visible.",
                      style: TextStyle(fontSize: 10, color: grey),
                    ),
                    const SizedBox(height: 10),
                    Button(
                      onPressed: () {
                        setState(() {
                          isID = true;
                          _isPanelOpen = true;
                          _panelController.open();
                        });
                      },
                      boxShadows: shadowButtonColor,
                      child: Text(
                        _selectedIDImage == null ? 'Upload ID Document' : 'Change ID Document',
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _validator(iDValidator),
                    const SizedBox(height: 10),
                    if (_selectedIDImage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => _imagePreview(context, _selectedIDImage)),
                              );
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedIDImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Divider(
                color: deepPurple,
                thickness: 7,
              ),
              // Selfie Upload Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Valid Selfie',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload a selfie for identity verification. '
                      'Ensure your face is clearly visible and well-lit.',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Button(
                      onPressed: () {
                        setState(() {
                          isID = false;
                          _panelController.open();
                          _isPanelOpen = true;
                        });
                      },
                      boxShadows: shadowButtonColor,
                      child: Text(
                        _selectedSelfieImage == null ? 'Upload Selfie' : 'Change Selfie',
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _validator(selfieValidator),
                    const SizedBox(height: 10),
                    if (_selectedSelfieImage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => _imagePreview(context, _selectedSelfieImage)),
                              );
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedSelfieImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if (_faceDetected)
                            const Text(
                              'Face detected successfully!',
                              style: TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 1, child: SizedBox(width: 10)),
                        Expanded(
                          flex: 1,
                          child: Button(
                            color: deepPurple,
                            boxShadows: shadowMidColor,
                            onPressed: () async {
                              setState(() {
                                _loadingAction = true;
                              });
                              Uint8List? imageID;
                              Uint8List? imageSelfie;
                              if (_selectedIDImage != null && _selectedSelfieImage != null) {
                                Uint8List originalIDBytes = await _selectedIDImage!.readAsBytes();
                                imageID = compressImage(originalIDBytes);
                                Uint8List originalSelfieBytes = await _selectedSelfieImage!.readAsBytes();
                                imageSelfie = compressImage(originalSelfieBytes);

                                String? result = await submitAccountVerification(imageID, imageSelfie);
                                if (result == 'success') {
                                  if (!mounted) return;
                                  showSuccessSnackBar(context, 'Submitted successfully');
                                  Navigator.pushReplacementNamed(context, '/mainApp');
                                } else {
                                  if (!mounted) return;
                                  showErrorSnackBar(context, 'Something went wrong please try again later.');
                                }
                              } else {
                                setState(() {
                                  if (_selectedIDImage == null) {
                                    iDValidator = 'Please upload your valid ID';
                                  }
                                  if (_selectedSelfieImage == null) {
                                    selfieValidator = 'Please upload your valid selfie';
                                  }
                                });
                              }

                              //
                              setState(() {
                                _loadingAction = false;
                              });
                            },
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
          if (_isPanelOpen)
            Positioned.fill(
              child: InkWell(
                onTap: () {
                  _panelController.close();
                  setState(() {
                    _isPanelOpen = false;
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
            panel: _panelContent(isID),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            onPanelClosed: () {
              setState(() {
                _isPanelOpen = false;
              });
            },
          ),
          if (_loadingAction) showLoadingAction(),
        ],
      ),
    );
  }
}
