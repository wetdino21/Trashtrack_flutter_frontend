import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class BillingList extends StatefulWidget {
  final int billId;
  const BillingList({super.key, required this.billId});

  @override
  State<BillingList> createState() => _BillingListState();
}

class _BillingListState extends State<BillingList>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? pdfBills;
  List<Uint8List>? pdf;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _fetchBillPdfs();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
  }

  @override
  void dispose() {
    TickerCanceled;
    _controller.dispose();
    super.dispose();
  }

  // Fetch notifications from the server
  Future<void> _fetchBillPdfs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchAllPdfBills(widget.billId);
      //final data = await fetchPdf(widget.billId);

      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          //pdf = data;
          pdfBills = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<void> _downloadPdf(Uint8List pdfBytes) async {
    // Check permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    print('PDF size: ${pdfBytes.length}');

// // Basic check to ensure it starts with %PDF-
//     if (String.fromCharCodes(pdfBytes.take(4)) != '%PDF') {
//       throw Exception('Invalid PDF data');
//     }

    Directory? downloadsDirectory =
        Directory('/storage/emulated/0/Download/trash');

    // Check if the directory exists
    if (!await downloadsDirectory.exists()) {
      downloadsDirectory = await getExternalStorageDirectory();
    }

    // Ensure the directory exists
    if (downloadsDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access storage')),
      );
      return;
    }

    String formattedDate =
        DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
    String savePath =
        "${downloadsDirectory.path}/TrashTrack_Bill ($formattedDate).pdf";

    try {
      showDownloadDialog(context);
      // Save the PDF bytes to the file
      File file = File(savePath);
      await file.writeAsBytes(pdfBytes);

      // Verify that the file was written successfully
      if (await file.exists()) {
        await OpenFile.open(savePath);
        print('PDF saved to: $savePath');
      } else {
        throw Exception('File was not saved successfully.');
      }
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text('BIlling List'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBillPdfs,
        child: isLoading
            ? Container(
                padding: EdgeInsets.all(10),
                child: LoadingAnimation(_controller, _colorTween, _colorTween2),
              )
            : pdfBills == null
                ? ListView(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off,
                                  color: whiteSoft, size: 100),
                              Text(
                                'No Bills at this time\n\n\n\n',
                                style:
                                    TextStyle(color: whiteSoft, fontSize: 20),
                              ),
                            ],
                          )),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: pdfBills!.length,
                    itemBuilder: (context, index) {
                      final pdfBill = pdfBills![index];

                      return GestureDetector(
                        onTap: () async {
                          Uint8List pdfBytes = pdfBill['bd_file'];
                          //Uint8List pdfBytes = pdfBill;
                          await _downloadPdf(pdfBytes);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '',
                            //'Total Amount: ${pdfBill['bd_total_amnt']}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
