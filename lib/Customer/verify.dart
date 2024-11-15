import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:trashtrack/styles.dart';

class VerifyCustomer extends StatefulWidget {
  const VerifyCustomer({super.key});

  @override
  State<VerifyCustomer> createState() => _VerifyCustomerState();
}

class _VerifyCustomerState extends State<VerifyCustomer> {
  File? _selectedIDImage;
  File? _selectedSelfieImage;
  bool _faceDetected = false;

  // Create a face detector instance
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  Future<void> _pickImage(ImageSource source, bool isID) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File selectedFile = File(pickedFile.path);
      if (!isID) {
        bool isFace = await _detectFace(selectedFile);
        if (!isFace) {
          setState(() {
            _faceDetected = false;
            _selectedSelfieImage = null;
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
            _selectedSelfieImage = selectedFile;
          });
        }
      } else {
        setState(() {
          _selectedIDImage = selectedFile;
        });
      }
    }
  }

  // Detect face in the given image
  Future<bool> _detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty; // Return true if faces are detected
    } catch (e) {
      print("Error detecting face: $e");
      return false; // Return false if an error occurs or no face is detected
    }
  }

  @override
  void dispose() {
    _faceDetector.close(); // Don't forget to close the face detector when the widget is disposed.
    super.dispose();
  }

  Widget _imagePreview(BuildContext context, final XFile? imageFile, final Uint8List? imageBytes) {
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
                    : imageBytes != null
                        ? Image.memory(
                            imageBytes,
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
                  : imageBytes != null
                      ? Image.memory(imageBytes)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: white,
        title: const Text('Account Verification'),
      ),
      body: Padding(
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
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // ID Upload Section
            Text(
              'Upload Valid ID',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload a valid ID (e.g., passport, driver’s license, or national ID). '
              'Make sure the image is clear and the details are readable.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery, true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: blue, borderRadius: BorderRadius.circular(8), boxShadow: shadowLowColor),
                child: Text(
                  _selectedIDImage == null ? 'Upload ID Document' : 'Change ID Document',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedIDImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => _imagePreview(context, imageFile, imageBytes)),
                        // );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedIDImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Selfie Upload Section
            Text(
              'Upload Valid Selfie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload a selfie for identity verification. '
              'Ensure your face is clearly visible and well-lit.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera, false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: blue, borderRadius: BorderRadius.circular(8), boxShadow: shadowLowColor),
                child: Text(
                  _selectedSelfieImage == null ? 'Upload Selfie' : 'Change Selfie',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedSelfieImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedSelfieImage!,
                        fit: BoxFit.cover,
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
          ],
        ),
      ),
    );
  }
}
