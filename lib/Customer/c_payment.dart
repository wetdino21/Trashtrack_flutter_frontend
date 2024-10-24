import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_schedule_list.dart';
import 'package:trashtrack/api_network.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/api_token.dart';
import 'package:trashtrack/billing_list.dart';
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

class _C_PaymentScreenState extends State<C_PaymentScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  bool isLoading = false;
  int selectedPage = 0;
  late PageController _pageController;
  List<Map<String, dynamic>>? billList;
  List<Map<String, dynamic>>? paymentList;

  @override
  void initState() {
    super.initState();

    //_dbData();
    _fetchBillPaymentData();
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

  // Fetch data
  Future<void> _fetchBillPaymentData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchBill();
      final data2 = await fetchPayment();
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          billList = data;
          if (data2 != null) {
            paymentList = data2;
          }

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
              Container(
                padding: EdgeInsets.only(top: 80),
                child: Container(
                  decoration: BoxDecoration(
                      color: whiteLow,
                      boxShadow: shadowTopColor,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15))),
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
                            await _fetchBillPaymentData();
                          },
                          child: isLoading
                              ? Container(
                                  padding: EdgeInsets.all(20),
                                  child: loadingAnimation(_controller, _colorTween, _colorTween2),
                                )
                              : billList == null
                                  ? ListView(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              height: 100,
                                            ),
                                            Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.wallet, color: blackSoft, size: 70),
                                                    Text(
                                                      'No pending payment\n\n\n\n',
                                                      style: TextStyle(color: blackSoft, fontSize: 20),
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
                                      itemCount: billList?.length ?? 0, // Simplified null check
                                      itemBuilder: (context, index) {
                                        final bill = billList?[index];

                                        if (bill == null) {
                                          return SizedBox.shrink(); // Return an empty box if bill is null
                                        }

                                        // Extracting fields from the bill
                                        int? gb_id = bill['gb_id'];
                                        String bill_id = 'Bill# ${gb_id.toString()}';
                                        String booking_id = 'BOOKING# ${bill['bk_id']?.toString()}';
                                        String status = bill['gb_status']?.toString() ?? '';
                                        DateTime dbDueDate = DateTime.parse(bill['gb_date_due'] ?? '').toLocal();
                                        String formatdbDueDate = DateFormat('MMM dd, yyyy (EEEE)').format(dbDueDate);
                                        String dueDate = formatdbDueDate;
                                        DateTime dbdateIssue = DateTime.parse(bill['gb_date_issued'] ?? '').toLocal();
                                        String formatdateIssue = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateIssue);
                                        String dateIssued = 'Issued: $formatdateIssue';

                                        return Column(
                                          children: [
                                            if (index == 0) SizedBox(height: 30),
                                            InkWell(
                                              onTap: () {
                                                if (gb_id != null) {
                                                  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => PaymentDetails(gb_id: gb_id)))
                                                      .then((value) {
                                                    if (value == true) {
                                                      _fetchBillPaymentData();
                                                    }
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: shadowColor,
                                                    borderRadius: borderRadius10),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            bill_id,
                                                            style: TextStyle(
                                                                color: blackSoft,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            booking_id,
                                                            style: TextStyle(color: blackSoft, fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          color: deepPurple,
                                                          borderRadius: borderRadius5,
                                                          boxShadow: shadowColor),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Due Date',
                                                            style: TextStyle(
                                                                color: white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 14),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.calendar_month,
                                                                color: white,
                                                              ),
                                                              Text(
                                                                dueDate,
                                                                style: TextStyle(
                                                                    color: white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          dateIssued,
                                                          style: TextStyle(color: blackSoft, fontSize: 12),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Transform.rotate(
                                                              angle: -0.7854, // 45 degrees in radians
                                                              child: Icon(
                                                                Icons.push_pin,
                                                                color: Colors.red,
                                                                size: 20,
                                                                shadows: shadowColor,
                                                              ),
                                                            ),
                                                            Text(
                                                              status,
                                                              style: TextStyle(
                                                                color: redSoft,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 18,
                                                                //shadows: shadowLessColor
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (billList!.length - 1 == index) const SizedBox(height: 200)
                                          ],
                                        );
                                      },
                                    )),

                      // History Schedule
                      RefreshIndicator(
                        onRefresh: () async {
                          await _fetchBillPaymentData();
                        },
                        child: isLoading
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: loadingAnimation(_controller, _colorTween, _colorTween2),
                              )
                            : (paymentList == null)
                                ? ListView(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            height: 100,
                                          ),
                                          Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.history, color: blackSoft, size: 70),
                                                  Text(
                                                    'No payment history\n\n\n\n',
                                                    style: TextStyle(color: blackSoft, fontSize: 20),
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
                                    itemCount: paymentList?.length ?? 0, // Simplified null check
                                    itemBuilder: (context, index) {
                                      final payment = paymentList?[index];

                                      if (payment == null) {
                                        return SizedBox.shrink(); // Return an empty box if payment is null
                                      }

                                      // Extracting fields from the payment
                                      int? gb_id = payment['gb_id'];
                                      String bill_id = 'Bill# ${gb_id.toString()}';
                                      String booking_id = 'BOOKING# ${payment['bk_id']?.toString()}';
                                      String status = payment['p_status'].toString();
                                      if (status.isNotEmpty) {
                                        status = status.replaceRange(0, 1, status[0].toUpperCase());
                                      }

                                      //String amount = '₱ ${payment['p_amount'].toString()}';
                                      String dbAmountPaid = '${payment['p_amount']}';
                                      double amountPaidValue = double.parse(dbAmountPaid);
                                      String amount = '₱${NumberFormat('#,##0.00').format(amountPaidValue)}';
                                      String method = payment['p_method'].toString();
                                      DateTime dbdateIssue = DateTime.parse(payment['p_date_paid'] ?? '').toLocal();
                                      String formatdateIssue = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateIssue);
                                      String dateIssued = 'Paid at: $formatdateIssue';

                                      return Column(
                                        children: [
                                          if (index == 0) SizedBox(height: 30),
                                          InkWell(
                                            onTap: () {
                                              if (gb_id != null) {
                                                Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => PaymentDetails(gb_id: gb_id)))
                                                    .then((value) {
                                                  if (value == true) {
                                                    _fetchBillPaymentData();
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: white, boxShadow: shadowColor, borderRadius: borderRadius10),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.topLeft,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          bill_id,
                                                          style: TextStyle(
                                                              color: blackSoft,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(
                                                          booking_id,
                                                          style: TextStyle(color: blackSoft, fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: deepPurple,
                                                        borderRadius: borderRadius5,
                                                        boxShadow: shadowColor),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          method,
                                                          style: TextStyle(
                                                              color: white, fontWeight: FontWeight.bold, fontSize: 14),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              amount,
                                                              style: TextStyle(
                                                                  color: white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 20),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        dateIssued,
                                                        style: TextStyle(color: blackSoft, fontSize: 12),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: green,
                                                              shape: BoxShape.circle,
                                                              boxShadow: shadowColor,
                                                            ),
                                                            child: Icon(
                                                              Icons.check,
                                                              color: white,
                                                              size: 20,
                                                              weight: 20,
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            status,
                                                            style: TextStyle(
                                                              color: green,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                              //shadows: shadowLessColor
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (paymentList!.length - 1 == index) const SizedBox(height: 200)
                                        ],
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
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
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 0 ? whiteLow : deepPurple,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPage == 0 ? deepPurple : whiteLow,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onPageSelected(1),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          decoration: BoxDecoration(
                              color: selectedPage == 1 ? whiteLow : deepPurple,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              boxShadow: shadowTopColor),
                          child: Text(
                            'History',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: selectedPage == 1 ? deepPurple : whiteLow),
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

class PaymentDetails extends StatefulWidget {
  final int gb_id;

  const PaymentDetails({super.key, required this.gb_id});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  Map<String, dynamic>? paymentDetails;
  bool refreshStatus = false;
  String dateIssued = '';
  String dueDate = '';
  String datePaid = '';
  String amountPaid = '';
  String payMethod = '';
  String trans_Id = '';
  String checkout_Id = '';
  String amountDue = '';

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
      final data2 = await fetchPaymentDetails(widget.gb_id);
      if (!mounted) {
        return;
      }
      if (data != null) {
        //data2 can be null
        setState(() {
          billDetails = data;
          paymentDetails = data2;
          //console(billDetails);
          //
          DateTime dbIssuedDate = DateTime.parse(billDetails!['gb_date_issued'] ?? '').toLocal();
          String formatdbIssuedDate = DateFormat('MMM dd, yyyy (hh:mm a)').format(dbIssuedDate);
          dateIssued = formatdbIssuedDate;

          DateTime dbDueDate = DateTime.parse(billDetails!['gb_date_due'] ?? '').toLocal();
          String formatdbDueDate = DateFormat('MMM dd, yyyy').format(dbDueDate);
          dueDate = formatdbDueDate;

          amountDue = billDetails!['amount_due'] != null
              ? '₱${NumberFormat('#,##0.00').format(billDetails!['amount_due'])}'
              : 'Loading...';

          if (paymentDetails != null) {
            DateTime dbDatePaid = DateTime.parse(paymentDetails!['p_date_paid'] ?? '').toLocal();
            String formatdbDatePaid = DateFormat('MMM dd, yyyy (hh:mm a)').format(dbDatePaid);
            datePaid = formatdbDatePaid;

            //amountPaid = '₱${paymentDetails!['p_amount']}';
            String dbAmountPaid = '${paymentDetails!['p_amount']}';
            double amountPaidValue = double.parse(dbAmountPaid);
            amountPaid = '₱${NumberFormat('#,##0.00').format(amountPaidValue)}';
            payMethod = '${paymentDetails!['p_method']}';
            trans_Id = '${paymentDetails!['p_trans_id']}';
            checkout_Id = '${paymentDetails!['p_checkout_id']}';
          }

          //
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
      setState(() {
        isBillLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepPurple,
      appBar: AppBar(
        backgroundColor: deepPurple,
        foregroundColor: Colors.white,
        title: Text('Payment Details', style: TextStyle(color: white, fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
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
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .80,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _fetchBillDataDetails();
                    },
                    child: isBillLoading
                        ? ListView(
                            padding: EdgeInsets.all(20),
                            children: [
                              loadingSingleAnimation(_controller, _colorTween, _colorTween2),
                            ],
                          )
                        : billDetails != null
                            ? ListView(
                                padding: EdgeInsets.all(15),
                                children: [
                                  SizedBox(height: 50),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'BILL# ${billDetails!['gb_id'].toString()}',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          'BOOKING# ${billDetails!['bk_id'].toString()}',
                                          style:
                                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    C_ScheduleDetails(bookId: billDetails!['bk_id']))),
                                        child: Container(
                                          //decoration: BoxDecoration(boxShadow: shadowTextColor),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                color: greenSoft,
                                              ),
                                              Text(
                                                'View Booking',
                                                style: TextStyle(
                                                  color: greenSoft,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: greenSoft,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Column(
                                    children: [
                                      Container(
                                        decoration:
                                            BoxDecoration(borderRadius: borderRadius15, boxShadow: shadowMidColor),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                  color: billDetails!['gb_status'] == 'Paid' ? green : red,
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    billDetails!['gb_status'],
                                                    style: TextStyle(
                                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                                                  ),
                                                  if (billDetails!['gb_status'] == 'Paid')
                                                    Container(
                                                      height: 50,
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: CircleAvatar(
                                                        child: Icon(
                                                          Icons.check,
                                                          color: white,
                                                          size: 30,
                                                        ),
                                                        backgroundColor: deepBlue,
                                                      ),
                                                    ),
                                                  if (billDetails!['gb_status'] != 'Paid')
                                                    Container(
                                                      height: 50,
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: CircleAvatar(
                                                        child: Icon(
                                                          Icons.error,
                                                          color: white,
                                                          size: 30,
                                                        ),
                                                        backgroundColor: red,
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                  color: white,
                                                  borderRadius:
                                                      const BorderRadius.vertical(bottom: Radius.circular(10))),
                                              child: Column(
                                                children: [
                                                  if (paymentDetails != null && billDetails!['gb_status'] == 'Paid')
                                                    Column(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Text(
                                                              'Amount',
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              amountPaid,
                                                              style: TextStyle(
                                                                  color: orange,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 24),
                                                            ),
                                                            SizedBox(height: 20)
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Date Paid: ',
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              datePaid,
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SelectableText(
                                                              'Payment Method: $payMethod',
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SelectableText(
                                                              'Transaction# $trans_Id',
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SelectableText(
                                                              'Checkout# $checkout_Id',
                                                              style: TextStyle(
                                                                  color: grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                      ],
                                                    ),
                                                  if (billDetails!['gb_status'] != 'Paid')
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Amount',
                                                            style: TextStyle(
                                                                color: grey, fontWeight: FontWeight.bold, fontSize: 12),
                                                          ),
                                                          Text(
                                                            amountDue,
                                                            style: TextStyle(
                                                                color: orange,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 24),
                                                          ),
                                                          SizedBox(height: 20)
                                                        ],
                                                      ),
                                                    ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: List.generate(50, (index) {
                                                      return Container(
                                                        width: 3,
                                                        height: 1,
                                                        color: Colors.black,
                                                      );
                                                    }),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Due Date: ',
                                                        style: TextStyle(
                                                            color: grey, fontWeight: FontWeight.bold, fontSize: 14),
                                                      ),
                                                      Text(
                                                        dueDate,
                                                        style: TextStyle(
                                                            color: grey, fontWeight: FontWeight.bold, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Date Issued: ',
                                                        style: TextStyle(
                                                            color: grey, fontWeight: FontWeight.bold, fontSize: 12),
                                                      ),
                                                      Text(
                                                        dateIssued,
                                                        style: TextStyle(
                                                            color: grey, fontWeight: FontWeight.bold, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      //downlaod
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BillingList(billId: billDetails!['gb_id']),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              //decoration: BoxDecoration(boxShadow: shadowTextColor),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(2),
                                                    child: Icon(Icons.picture_as_pdf, color: greenSoft),
                                                  ),
                                                  Text(
                                                    'Bill Records',
                                                    style: TextStyle(
                                                      color: greenSoft,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: greenSoft,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      billDetails!['gb_status'] != 'Paid'
                                          ? Container(
                                              height: 80,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 8,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          refreshStatus = true;
                                                          isLoading = true;
                                                        });

                                                        await launchPaymentLinkSession(
                                                          billDetails!['gb_id'],
                                                        );
                                                        // String? sessionId =
                                                        //     await launchPaymentLinkSession(
                                                        //   billDetails!['gb_id'],
                                                        // );
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

                                                        Timer(Duration(seconds: 2), () {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        height: double.infinity,
                                                        padding: EdgeInsets.all(10.0),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                            boxShadow: shadowLowColor),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'Pay Now',
                                                              style: TextStyle(
                                                                color: deepGreen,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 24,
                                                              ),
                                                            ),
                                                            SizedBox(width: 5),
                                                            Icon(Icons.waving_hand, color: deepGreen)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 3,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          refreshStatus = false;
                                                          isLoading = true;
                                                        });

                                                        await _downloadPdf(context, billDetails!['gb_id']);

                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                            boxShadow: shadowLowColor),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Center(
                                                              child: Text(
                                                                'Latest Bill',
                                                                style: TextStyle(
                                                                    color: grey,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14.0),
                                                              ),
                                                            ),
                                                            Container(
                                                              child: Icon(
                                                                Icons.picture_as_pdf_rounded,
                                                                size: 40,
                                                                color: deepGreen,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  refreshStatus = false;
                                                  isLoading = true;
                                                });
                                                await _downloadPdf(context, billDetails!['gb_id']);

                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: shadowLowColor),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.picture_as_pdf_rounded,
                                                      size: 40,
                                                      color: deepGreen,
                                                    ),
                                                    title: Text(
                                                      'Latest Bill',
                                                      style: TextStyle(
                                                          color: grey, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                    ),
                                                  )),
                                            ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) showLoadingAction(),
        ],
      ),
    );
  }
}

//dont touch
Future<void> _uploadPdf(BuildContext context, int bill_Id, Uint8List pdfBytes) async {
  Map<String, String?> tokens = await getTokens();
  String? accessToken = tokens['access_token'];

  if (accessToken == null) {
    print('No access token available. User needs to log in.');
    await deleteTokens();
    return;
  }

  String baseUrl = globalUrl();
  var dio = Dio();

  try {
    // Send a POST request to upload the PDF to the database
    Response uploadResponse = await dio.post(
      '$baseUrl/upload_pdf',
      data: {
        'billId': bill_Id,
        'pdfData': pdfBytes, // Send PDF as binary directly
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (uploadResponse.statusCode == 200) {
      print('PDF uploaded successfully');
    } else {
      //showErrorSnackBar(context, 'Failed to upload PDF: ${uploadResponse.statusCode}');
    }
  } catch (e) {
    print(e.toString());
    //showErrorSnackBar(context, 'Error uploading PDF.');
  }
}

//
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

    String formattedDate = DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
    String savePath = "${downloadsDirectory!.path}/TrashTrack_Bill ($formattedDate).pdf";

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
      //  String? totalAmountStr = response.headers.value('totalAmount');
      //  print(totalAmountStr);
      await _uploadPdf(context, bill_Id, response.data);
      showDownloadDialog(context);
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

      showErrorSnackBar(context, 'Try again Later.');
    }
  } catch (e) {
    print(e.toString());
    showErrorSnackBar(context, 'Try again Later.');
  }
}

//
void showDownloadDialog(BuildContext context) {
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

// Future<void> _downloadPdf(BuildContext context, int bill_Id) async {
//   String baseUrl = globalUrl();
//   try {
//     // Check permission
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }

//     var dio = Dio();

//     Directory? downloadsDirectory =
//         Directory('/storage/emulated/0/Download/trash');

//     // Check if the directory exists
//     if (!await downloadsDirectory.exists()) {
//       downloadsDirectory = await getExternalStorageDirectory();
//     }

//     String formattedDate =
//         DateFormat('MMMM dd, yyyy HH-mm-ss').format(DateTime.now());
//     String savePath =
//         "${downloadsDirectory!.path}/TrashTrack_Bill ($formattedDate).pdf";

//     Map<String, String?> tokens = await getTokens();
//     String? accessToken = tokens['access_token'];

//     if (accessToken == null) {
//       print('No access token available. User needs to log in.');
//       await deleteTokens();
//       return;
//     }

//     // Send a POST request to download the PDF file
//     Response response = await dio.post(
//       '$baseUrl/generate-pdf',
//       options: Options(
//         responseType: ResponseType.bytes, // Ensure you're getting bytes
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//       ),
//       data: {
//         'billId': bill_Id, // Ensure you pass the correct billId
//       },
//     );

//     if (response.statusCode == 200) {
//       showDownloadDialog(context);
//       // Save the PDF bytes to the file
//       await File(savePath).writeAsBytes(response.data);
//       OpenFile.open(savePath);
//       print(savePath);
//     } else {
//       // Handle specific HTTP response codes
//       if (response.statusCode == 401) {
//         // Access token might be expired, attempt to refresh it
//         print('Access token expired. Attempting to refresh...');
//         String? refreshMsg = await refreshAccessToken();
//         if (refreshMsg == null) {
//           return await _downloadPdf(context, bill_Id);
//         } else {
//           await deleteTokens(); // Logout user
//           return;
//         }
//       } else if (response.statusCode == 403) {
//         // Access token is invalid. Logout
//         print('Access token invalid. Attempting to logout...');
//         await deleteTokens(); // Logout user
//       } else if (response.statusCode == 404) {
//         showErrorSnackBar(context, 'PDF not found');
//         return;
//       }

//       showErrorSnackBar(context, 'Try again Later.');
//     }
//   } catch (e) {
//     print(e.toString());
//     showErrorSnackBar(context, 'Try again Later.');
//   }
// }