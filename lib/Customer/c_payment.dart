import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/styles.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class C_PaymentScreen extends StatefulWidget {
  @override
  State<C_PaymentScreen> createState() => _C_PaymentScreenState();
}

class _C_PaymentScreenState extends State<C_PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  List<Map<String, dynamic>>? bookingListHistory;
  List<Map<String, dynamic>>? bookingWasteListHistory;

  bool isLoading = false;
  int selectedPage = 0;
  late PageController _pageController;
  List<Map<String, dynamic>>? billList;
  String debug = 'nulllllllllll';

  @override
  void initState() {
    super.initState();

    //_dbData();
    _fetchBillData();
    _pageController = PageController(initialPage: selectedPage);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // The animation will repeat back and forth

    // Define a color tween animation that transitions between two colors
    _colorTween = ColorTween(
      begin: Colors.grey[350],
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.grey[350],
    ).animate(_controller);
  }

  @override
  void dispose() {
    TickerCanceled;
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void onPageSelected(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  // Fetch bill
  // Fetch notifications from the server
  Future<void> _fetchBillData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchBill();
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          billList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print(e.toString());
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: ListView(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 80),
                    child: Container(
                      decoration: BoxDecoration(
                          color: white,
                          boxShadow: shadowTopColor,
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(15))),
                      height: MediaQuery.of(context).size.height * .75,
                      //height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selectedPage = index;
                          });
                        },
                        children: [
                          // Current Schedule

                          RefreshIndicator(
                              onRefresh: () async {
                                await _fetchBillData();
                              },
                              child: isLoading
                                  ? Container(
                                      padding: EdgeInsets.all(20),
                                      child: LoadingAnimation(_controller,
                                          _colorTween, _colorTween2),
                                    )
                                  : billList == null
                                      ? ListView(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  height: 100,
                                                ),
                                                Container(
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.wallet,
                                                            color: blackSoft,
                                                            size: 70),
                                                        Text(
                                                          'No pending payment\n\n\n\n',
                                                          style: TextStyle(
                                                              color: blackSoft,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    )),
                                                SizedBox(
                                                  height: 100,
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          itemCount: billList?.length ??
                                              0, // Simplified null check
                                          itemBuilder: (context, index) {
                                            final bill = billList?[index];

                                            if (bill == null) {
                                              return SizedBox
                                                  .shrink(); // Return an empty box if bill is null
                                            }

                                            // Extracting fields from the bill
                                            int? gb_id = bill['gb_id'];
                                            String status =
                                                bill['gb_status']?.toString() ??
                                                    '';
                                            // String date =
                                            //     bill['gb_date_issued'] ?? '';
                                            // String time = bill['gb_date_due'] ?? '';
                                            // String wasteType = 'Food Waste';
                                            // String paymentType =
                                            //     bill['gb_note'] ?? '';
                                            // String amount =
                                            //     bill['gb_total_sales']?.toString() ??
                                            //         '';

                                            return InkWell(
                                              onTap: () {
                                                if (gb_id != null) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              C_PaymentHistoryDetails(
                                                                  gb_id:
                                                                      gb_id))).then(
                                                      (value) {
                                                    if (value == true) {
                                                      _fetchBillData();
                                                    }
                                                  });

                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         C_PaymentHistoryDetails(
                                                  //             gb_id: gb_id),
                                                  //   ),
                                                  // );
                                                }
                                              },
                                              child: Column(
                                                children: [
                                                  if (index == 0)
                                                    SizedBox(height: 30),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    color: greySoft,
                                                    padding: EdgeInsets.all(20),
                                                    margin: EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(gb_id.toString()),
                                                        Text(status),
                                                      ],
                                                    ),
                                                  ),
                                                  if (billList!.length - 1 ==
                                                      index)
                                                    const SizedBox(height: 200)
                                                ],
                                              ),
                                            );
                                          },
                                        )),

                          // History Schedule
                          RefreshIndicator(
                            onRefresh: () async {
                              await _fetchBillData();
                            },
                            child: isLoading
                                ? Container(
                                    padding: const EdgeInsets.all(20),
                                    child: LoadingAnimation(
                                        _controller, _colorTween, _colorTween2),
                                  )
                                : (bookingList == null) &&
                                        bookingListHistory == null
                                    ? ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                height: 100,
                                              ),
                                              Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.history,
                                                          color: blackSoft,
                                                          size: 70),
                                                      Text(
                                                        'No payment history\n\n\n\n',
                                                        style: TextStyle(
                                                            color: blackSoft,
                                                            fontSize: 20),
                                                      ),
                                                    ],
                                                  )),
                                              const SizedBox(
                                                height: 100,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        itemCount:
                                            bookingListHistory?.length == null
                                                ? 0
                                                : bookingListHistory!.length,
                                        itemBuilder: (context, index) {
                                          // Safely retrieve the booking details from bookingList
                                          final booking =
                                              bookingListHistory?[index];

                                          if (booking == null) {
                                            return const SizedBox.shrink();
                                          }

                                          int book_Id = booking['bk_id'];
                                          DateTime dbdate = DateTime.parse(
                                                  booking['bk_date'] ?? '')
                                              .toLocal();
                                          final String date =
                                              DateFormat('MMM dd, yyyy (EEEE)')
                                                  .format(dbdate);

                                          DateTime dbdateCreated =
                                              DateTime.parse(booking[
                                                          'bk_created_at'] ??
                                                      '')
                                                  .toLocal();
                                          final String dateCreated =
                                              DateFormat('MMM dd, yyyy hh:mm a')
                                                  .format(dbdateCreated);

                                          // Filter waste types for the current booking's bk_id
                                          String wasteTypes = '';
                                          if (bookingWasteListHistory != null) {
                                            List<Map<String, dynamic>>
                                                filteredWasteList =
                                                bookingWasteListHistory!
                                                    .where((waste) {
                                              return waste['bk_id'] ==
                                                  booking['bk_id'];
                                            }).toList();

                                            // Build the waste types string
                                            int count = 0;
                                            for (var waste
                                                in filteredWasteList) {
                                              count++;
                                              wasteTypes +=
                                                  waste['bw_name'] + ', ';
                                              if (count == 2) break;
                                            }

                                            // Remove the trailing comma and space
                                            if (wasteTypes.isNotEmpty) {
                                              if (filteredWasteList.length >
                                                  2) {
                                                wasteTypes = '$wasteTypes. . .';
                                              } else {
                                                wasteTypes =
                                                    wasteTypes.substring(0,
                                                        wasteTypes.length - 2);
                                              }
                                            }
                                          }

                                          final String status =
                                              booking['bk_status'] ??
                                                  'No status';

                                          // Pass the extracted data to the C_CurrentScheduleCard widget
                                          return C_PaymentHistory(
                                            date: 'Fri Jun 20',
                                            time: '8:30 AM',
                                            wasteType: 'Food Waste',
                                            paymentType: 'Gcash',
                                            amount: '350.50',
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onPageSelected(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 0 ? white : deepPurple,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPage == 0 ? deepPurple : white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onPageSelected(1),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 1 ? white : deepPurple,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'History',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedPage == 1 ? blackSoft : white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class C_PaymentHistory extends StatelessWidget {
  final String date;
  final String time;
  final String wasteType;
  final String paymentType; // New field
  final String amount; // New field

  C_PaymentHistory({
    required this.date,
    required this.time,
    required this.wasteType,
    required this.paymentType, // New parameter
    required this.amount, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => C_PaymentHistoryDetails(gb_id: ,),
        //   ),
        // );
      },
      splashColor: Colors.green,
      highlightColor: Colors.green.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        color: boxColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon(Icons.history, color: Color(0xFF6AA920)),
                //SizedBox(width: 10.0),
                Text(
                  date,
                  style: TextStyle(color: Colors.white70, fontSize: 14.0),
                ),
                SizedBox(width: 10.0),
                Text(
                  time,
                  style: TextStyle(color: Colors.white38, fontSize: 14.0),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              wasteType,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment: ',
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                    Text(
                      '$paymentType',
                      style:
                          TextStyle(color: Colors.blueAccent, fontSize: 14.0),
                    ),
                  ],
                ),
                Text(
                  '₱$amount',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 14.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class C_PaymentHistoryDetails extends StatefulWidget {
  final int gb_id;

  const C_PaymentHistoryDetails({super.key, required this.gb_id});

  @override
  State<C_PaymentHistoryDetails> createState() =>
      _C_PaymentHistoryDetailsState();
}

class _C_PaymentHistoryDetailsState extends State<C_PaymentHistoryDetails>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  List<Map<String, dynamic>>? bookingListHistory;
  List<Map<String, dynamic>>? bookingWasteListHistory;

  bool isLoading = false;
  bool isBillLoading = false;
  int selectedPage = 0;
  late PageController _pageController;
  Map<String, dynamic>? billDetails;
  bool refreshStatus = false;

  @override
  void initState() {
    super.initState();

    //_dbData();
    _fetchBillDataDetails();
    _pageController = PageController(initialPage: selectedPage);

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

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    TickerCanceled;
    _controller.dispose();
    _pageController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (refreshStatus) {
      if (state == AppLifecycleState.resumed) {
        _fetchBillDataDetails();
        setState(() {
          refreshStatus = false;
        });
      }
    }
  }

  void onPageSelected(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  // Fetch bill
  // Fetch notifications from the server
  Future<void> _fetchBillDataDetails() async {
    setState(() {
      isBillLoading = true;
    });
    try {
      final data = await fetchBillDetails(widget.gb_id);
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          billDetails = data;
          isBillLoading = false;
        });
      } else {
        setState(() {
          isBillLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print(e.toString());
      showErrorSnackBar(context, 'errorMessage');
      setState(() {
        isBillLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text('Payment Details',
            style: TextStyle(
                color: white, fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(15),
            children: [
              PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) {
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: Container()),
              //
              Container(
                height: MediaQuery.of(context).size.height * .80,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchBillDataDetails();
                  },
                  child: isBillLoading
                      ? LoadingSingleAnimation(
                          _controller, _colorTween, _colorTween2)
                      : billDetails != null
                          ? ListView(
                              children: [
                                Column(
                                  children: [
                                    //if (billDetails!['gb_status'] != 'Paid')
                                    billDetails!['gb_status'] != 'Paid'
                                        ? Container(
                                            padding: EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        billDetails!['gb_id']
                                                                ?.toString() ??
                                                            '',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 16.0),
                                                      ),
                                                      Text(
                                                        billDetails![
                                                                    'gb_status']
                                                                ?.toString() ??
                                                            '',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 16.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Pay with',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      refreshStatus = true;
                                                      isLoading = true;
                                                    });
                                                    String? sessionId =
                                                        await launchPaymentLinkSession(
                                                      billDetails!['gb_id'],
                                                    );
                                                    // //
                                                    // if (sessionId != null) {
                                                    //   Navigator.push(
                                                    //       context,
                                                    //       MaterialPageRoute(
                                                    //           builder: (context) =>
                                                    //               PaymentBacktoApp(
                                                    //                   gb_id: widget
                                                    //                       .gb_id))).then(
                                                    //       (value) {
                                                    //     if (value == true) {
                                                    //       _fetchBillDataDetails();
                                                    //     }
                                                    //   });

                                                    // }
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Image.asset(
                                                        'assets/paymongo.png'),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    'Already Paid',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                    //downlaod
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          refreshStatus = false;
                                        });
                                        _downloadPdf(
                                            context, billDetails!['gb_id']);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                'Download Receipt',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16.0),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                Icons.download,
                                                size: 50,
                                                color: deepPurple,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                ),
              ),
            ],
          ),
          if (isLoading)
            Positioned.fill(
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 10,
                    strokeAlign: 2,
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// class PaymentBacktoApp extends StatefulWidget {
//   final int gb_id;
//   const PaymentBacktoApp({super.key, required this.gb_id});

//   @override
//   State<PaymentBacktoApp> createState() => _PaymentBacktoAppState();
// }

// class _PaymentBacktoAppState extends State<PaymentBacktoApp>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     // _dbData();
//   }

//   @override
//   void dispose() {
//     print('disposeeee payment');
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed) {
//       console('message1111111111111111111111111111111');
//     } else {
//       console('message222222222222222222222222222222222222');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: deepGreen,
//       appBar: AppBar(
//         backgroundColor: deepGreen,
//         foregroundColor: Colors.white,
//         // leading: SizedBox(width: 0),
//         // leadingWidth: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             PopScope(
//                 canPop: false,
//                 onPopInvokedWithResult: (didPop, result) async {
//                   if (didPop) {
//                     return;
//                   }
//                   Navigator.pop(context, true);
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //         builder: (context) =>
//                   //             C_PaymentHistoryDetails(gb_id: widget.gb_id)));
//                 },
//                 child: Container()),
//             Container(
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context, true);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Center(
//                             child: Text(
//                               'Go Back to App',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 16.0),
//                             ),
//                           ),
//                           Center(
//                             child: Text(
//                               'Okay',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 16.0),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

Future<void> _downloadPdf(BuildContext context, int bill_Id) async {
  String baseUrl = globalUrl();
  try {
    // Check permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var dio = Dio();

    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download/trash');

    // Check if the directory exists
    if (!await downloadsDirectory.exists()) {
      downloadsDirectory = await getExternalStorageDirectory();
    }

    String formattedDate =
        DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
    String savePath =
        "${downloadsDirectory!.path}/TrashTrack_Bill ($formattedDate).pdf";

    Map<String, String?> tokens = await getTokens();
    String? accessToken = tokens['access_token'];

    if (accessToken == null) {
      print('No access token available. User needs to log in.');
      await deleteTokens();
      return;
    }

    // Send a POST request to download the PDF file
    Response response = await dio.post(
      '$baseUrl/generate-pdf',
      options: Options(
        responseType: ResponseType.bytes, // Ensure you're getting bytes
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'billId': bill_Id, // Ensure you pass the correct billId
      },
    );

    if (response.statusCode == 200) {
      _showDownloadDialog(context);
      // Save the PDF bytes to the file
      await File(savePath).writeAsBytes(response.data);
      OpenFile.open(savePath);
      print(savePath);
    } else {
      // Handle specific HTTP response codes
      if (response.statusCode == 401) {
        // Access token might be expired, attempt to refresh it
        print('Access token expired. Attempting to refresh...');
        String? refreshMsg = await refreshAccessToken();
        if (refreshMsg == null) {
          return await _downloadPdf(context, bill_Id);
        } else {
          await deleteTokens(); // Logout user
          return;
        }
      } else if (response.statusCode == 403) {
        // Access token is invalid. Logout
        print('Access token invalid. Attempting to logout...');
        await deleteTokens(); // Logout user
      } else if (response.statusCode == 404) {
        showErrorSnackBar(context, 'PDF not found');
        return;
      }

      showErrorSnackBar(context, 'Unable to download');
    }
  } catch (e) {
    print(e.toString());
    showErrorSnackBar(context, 'Unable to download $e');
  }
}

// Future<void> _downloadPdf(BuildContext context) async {
//   String baseUrl = globalUrl();
//   try {
//     //check permission
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     } else {
//       //console('No permission');
//     }

//     var dio = Dio();

//     Directory? downloadsDirectory;
//     downloadsDirectory = Directory('/storage/emulated/0/Download');
//     //Check if the directory does not exists
//     if (!await downloadsDirectory.exists()) {
//       downloadsDirectory = await getExternalStorageDirectory();
//     } else {
//       //showErrorSnackBar(context, 'Unable to download');
//       //console('Download folder already exist');
//     }

//     String formattedDate =
//         DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
//     String savePath =
//         "${downloadsDirectory!.path}/TrashTrack_Bill ($formattedDate).pdf";

//     // Download the PDF file from the server
//     Response response = await dio.download(
//       '$baseUrl/generate-pdf', // Replace with your backend URL
//       savePath,
//     );

//     if (response.statusCode == 200) {
//       _showDownloadDialog(context);
//       // Open the PDF after downloading
//       OpenFile.open(savePath);

//       print(savePath);
//     } else {
//       showErrorSnackBar(context, 'Unable to download');
//     }
//   } catch (e) {
//     print(e.toString());
//     showErrorSnackBar(context, 'Unable to download $e');
//   }
// }

void _showDownloadDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool removedDialog = false;

      Timer(const Duration(seconds: 3), () {
        if (!removedDialog) {
          Navigator.of(context).pop(); // Close the dialog safely
        }
      });

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          removedDialog = true;
          Navigator.pop(context);
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            height: 150,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  'Bill downloaded successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your bill is ready for viewing.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
