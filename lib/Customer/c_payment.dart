import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/api_postgre_service.dart';
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
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_controller);

    _colorTween2 = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
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
          SizedBox(height: 20.0),
          SizedBox(height: 10.0),
          Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: shadowMidColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: shadowColor),
                        child: ElevatedButton(
                          onPressed: () => onPageSelected(0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedPage == 0 ? Colors.deepPurple : white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(50)),
                            ),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              color: selectedPage == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: shadowColor),
                        child: ElevatedButton(
                          onPressed: () => onPageSelected(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedPage == 1 ? Colors.deepPurple : white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(50)),
                            ),
                          ),
                          child: Text(
                            'History',
                            style: TextStyle(
                              color: selectedPage == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                child: Row(
                  children: [
                    Expanded(flex: 5, child: Container()),
                    Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              boxShadow: shadowMidColor),
                        )),
                    Expanded(flex: 5, child: Container()),
                    Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              boxShadow: shadowMidColor),
                        )),
                    Expanded(flex: 5, child: Container()),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * .60,
                //height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
                //padding: EdgeInsets.symmetric(horizontal: 10),
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
                          //await _dbData();
                          // await _fetchBookingData();
                          await _fetchBillData();
                        },
                        child: isLoading
                            ? AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(5),
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            height: 30,
                                            width: 300,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              //color: Colors.white.withOpacity(.6),
                                              color: index % 2 == 0
                                                  ? _colorTween.value
                                                  : _colorTween2.value,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            height: 70,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: index % 2 == 0
                                                  ? _colorTween.value
                                                  : _colorTween2.value,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                })
                            : billList == null
                                ? ListView(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                          ),
                                          Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.wallet,
                                                      color: whiteSoft,
                                                      size: 70),
                                                  Text(
                                                    'No pending payment\n\n\n\n',
                                                    style: TextStyle(
                                                        color: whiteSoft,
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
                                          bill['gb_status']?.toString() ?? '';
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
                                                        gb_id: gb_id),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          color: white,
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(gb_id.toString()),
                                              Text(status),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),

                    // History Schedule
                    RefreshIndicator(
                      onRefresh: () async {
                        //await _dbData();
                        //await _fetchBookingData();
                      },
                      child: isLoading
                          ? AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          height: 30,
                                          width: 300,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            //color: Colors.white.withOpacity(.6),
                                            color: index % 2 == 0
                                                ? _colorTween.value
                                                : _colorTween2.value,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 70,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: index % 2 == 0
                                                ? _colorTween.value
                                                : _colorTween2.value,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              })
                          : (bookingList == null) && bookingListHistory == null
                              ? ListView(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.history,
                                                    color: whiteSoft, size: 70),
                                                Text(
                                                  'No payment history\n\n\n\n',
                                                  style: TextStyle(
                                                      color: whiteSoft,
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
                                  itemCount: bookingListHistory?.length == null
                                      ? 0
                                      : bookingListHistory!.length,
                                  itemBuilder: (context, index) {
                                    // Safely retrieve the booking details from bookingList
                                    final booking = bookingListHistory?[index];

                                    if (booking == null) {
                                      return SizedBox.shrink();
                                    }

                                    int book_Id = booking['bk_id'];
                                    DateTime dbdate =
                                        DateTime.parse(booking['bk_date'] ?? '')
                                            .toLocal();
                                    final String date =
                                        DateFormat('MMM dd, yyyy (EEEE)')
                                            .format(dbdate);

                                    DateTime dbdateCreated = DateTime.parse(
                                            booking['bk_created_at'] ?? '')
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
                                      for (var waste in filteredWasteList) {
                                        count++;
                                        wasteTypes += waste['bw_name'] + ', ';
                                        if (count == 2) break;
                                      }

                                      // Remove the trailing comma and space
                                      if (wasteTypes.isNotEmpty) {
                                        if (filteredWasteList.length > 2) {
                                          wasteTypes = wasteTypes + '. . .';
                                        } else {
                                          wasteTypes = wasteTypes.substring(
                                              0, wasteTypes.length - 2);
                                        }
                                      }
                                    }

                                    final String status =
                                        booking['bk_status'] ?? 'No status';

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
    with SingleTickerProviderStateMixin {
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
        title: Text('Payment',
            style: TextStyle(
                color: white, fontSize: 25, fontWeight: FontWeight.bold)),
        // leading: SizedBox(width: 0),
        // leadingWidth: 0,
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainApp(selectedIndex: 3)));
                  },
                  child: Container()),
              //
              isBillLoading
                  ? AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.white.withOpacity(.6),
                                color: _colorTween.value,
                              ),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            //color: Colors.white.withOpacity(.6),
                                            color: _colorTween2.value,
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 10,
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                      width: 100,
                                                      margin: EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        //color: Colors.white.withOpacity(.6),
                                                        color:
                                                            _colorTween2.value,
                                                      ),
                                                      child: Text(''))),
                                              Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                      width: 250,
                                                      margin: EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        //color: Colors.white.withOpacity(.6),
                                                        color:
                                                            _colorTween2.value,
                                                      ),
                                                      child: Text(''))),
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                      width: 150,
                                                      margin: EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        //color: Colors.white.withOpacity(.6),
                                                        color:
                                                            _colorTween2.value,
                                                      ),
                                                      child: Text(''))),
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 30,
                              width: 300,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.white.withOpacity(.6),
                                color: _colorTween2.value,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _colorTween2.value,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 30,
                              width: 300,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.white.withOpacity(.6),
                                color: _colorTween.value,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _colorTween.value,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 30,
                              width: 300,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.white.withOpacity(.6),
                                color: _colorTween2.value,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _colorTween2.value,
                              ),
                            ),
                          ],
                        );
                      })
                  : billDetails != null
                      ? Column(
                          children: [
                            //if (billDetails!['gb_status'] != 'Paid')
                            billDetails!['gb_status'] != 'Paid'
                                ? Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
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
                                                billDetails!['gb_status']
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
                                              isLoading = true;
                                            });
                                            String? sessionId =
                                                await launchPaymentLinkSession(
                                              billDetails!['gb_id'],
                                            );
                                            //
                                            if (sessionId != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentBacktoApp(
                                                          gb_id: widget.gb_id),
                                                ),
                                              );
                                            }
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
                                      borderRadius: BorderRadius.circular(10),
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
                                _downloadPdf();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Download Receipt',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16.0),
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
                        )
                      : Container(),
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

class PaymentBacktoApp extends StatefulWidget {
  final int gb_id;
  const PaymentBacktoApp({super.key, required this.gb_id});

  @override
  State<PaymentBacktoApp> createState() => _PaymentBacktoAppState();
}

class _PaymentBacktoAppState extends State<PaymentBacktoApp> {
  @override
  void initState() {
    super.initState();
    // _dbData();
  }

  @override
  void dispose() {
    print('disposeeee payment');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        // leading: SizedBox(width: 0),
        // leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) {
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          C_PaymentHistoryDetails(gb_id: widget.gb_id),
                    ),
                  );
                },
                child: Container()),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              C_PaymentHistoryDetails(gb_id: widget.gb_id),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Go Back to App',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Okay',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// class PaymentBacktoApp extends StatefulWidget {
//   final sessionId;
//   final int gb_id;
//   const PaymentBacktoApp(
//       {super.key, required this.sessionId, required this.gb_id});

//   @override
//   State<PaymentBacktoApp> createState() => _PaymentBacktoAppState();
// }

// class _PaymentBacktoAppState extends State<PaymentBacktoApp> {
//   @override
//   void initState() {
//     super.initState();
//     // _dbData();
//   }

//   @override
//   void dispose() {
//     print('disposeeee payment');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: deepGreen,
//       appBar: AppBar(
//         backgroundColor: deepGreen,
//         foregroundColor: Colors.white,
//         leading: SizedBox(width: 0),
//         leadingWidth: 0,
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
//                   Navigator.pop(context);
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
//                   Text(widget.sessionId),
//                   InkWell(
//                     onTap: () {
//                       checkPaymentStatus(widget.sessionId);
//                     },
//                     child: Container(
//                       child: Image.asset('assets/paymongo.png'),
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

Future<void> _downloadPdf() async {
  String baseUrl = globalUrl();
  try {
    var dio = Dio();

    // Get the Downloads directory
    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    String formattedDate =
        DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
    String savePath =
        "${downloadsDirectory.path}/TrashTrack_Bill ($formattedDate).pdf";

    //Directory? downloadsDirectory = await getExternalStorageDirectory();
    //String savePath ="${downloadsDirectory?.path}/sample.pdf"; // Ensure this points to the correct Downloads directory

    // Download the PDF file from the server
    Response response = await dio.download(
      '$baseUrl/generate-pdf', // Replace with your backend URL
      savePath,
    );

    if (response.statusCode == 200) {
      // Open the PDF after downloading
      OpenFile.open(savePath);

      print(savePath);
    }
  } catch (e) {
    print("Error downloading PDF: $e");
  }
}
