import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/api_cus_data.dart';
import 'package:trashtrack/Customer/payment.dart';
import 'package:trashtrack/API/api_postgre_service.dart';
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

class _BillingListState extends State<BillingList> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? pdfBills;
  List<Uint8List>? pdf;
  bool isLoading = false;
  bool loadingAction = false;
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

    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download/trash');

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

    String formattedDate = DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
    String savePath = "${downloadsDirectory.path}/TrashTrack_Bill ($formattedDate).pdf";

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
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
        title: Text('BIlling List'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchBillPdfs,
            child: isLoading
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: loadingAnimation(_controller, _colorTween, _colorTween2),
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
                                  Icon(Icons.article_outlined, color: whiteSoft, size: 100),
                                  Text(
                                    'Generate the latest bill first.\n\n\n\n',
                                    style: TextStyle(color: whiteSoft, fontSize: 20),
                                  ),
                                ],
                              )),
                        ],
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(
                                'BILL# ${widget.billId.toString()}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text(
                                'Note: The pdf bill/s listed below might not be latest bill. Please click Latest Bill (from the previous page) to download it and will be added here if the accrual date reached.',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(5),
                              itemCount: pdfBills!.length,
                              itemBuilder: (context, index) {
                                final pdfBill = pdfBills![index];

                                final formattedAmount = NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱',
                                  decimalDigits: 2,
                                ).format(double.parse(pdfBill['bd_total_amnt'].toString()));
                                DateTime dbGeneratedDate = DateTime.parse(pdfBill['bd_created_at']).toLocal();
                                String generatedDate = DateFormat('MMM dd, yyyy hh:mm a').format(dbGeneratedDate);

                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          loadingAction = true;
                                        });
                                        Uint8List pdfBytes = pdfBill['bd_file'];
                                        //Uint8List pdfBytes = pdfBill;
                                        await _downloadPdf(pdfBytes);

                                        setState(() {
                                          loadingAction = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                            color: white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: shadowLowColor),
                                        child: ListTile(
                                          leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                                          title: Row(
                                            children: [
                                              Text(
                                                'Total Due: ',
                                                style: TextStyle(color: Colors.black, fontSize: 14),
                                              ),
                                              Text(
                                                formattedAmount,
                                                style: TextStyle(color: orange),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            'Generated: ${generatedDate}',
                                            style: TextStyle(color: grey, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //add space last
                                    if (pdfBills!.length - 1 == index) const SizedBox(height: 200)
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
          ),
          if (loadingAction) showLoadingAction(),
        ],
      ),
    );
  }
}
