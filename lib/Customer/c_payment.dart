import 'package:flutter/material.dart';
import 'package:trashtrack/api_paymongo.dart';
import 'package:trashtrack/styles.dart';

class C_PaymentScreen extends StatefulWidget {
  @override
  State<C_PaymentScreen> createState() => _C_PaymentScreenState();
}

class _C_PaymentScreenState extends State<C_PaymentScreen> {
  String? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: ListView(
        children: [
          SizedBox(height: 20.0),
          Column(
            children: [
              Text(
                '  Payment History',
                style: TextStyle(
                  color: white,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 5.0),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Gcash',
                amount: '350.50',
              ),
              C_PaymentHistory(
                date: 'mon Jun 20',
                time: '9:30 AM',
                wasteType: 'Municipal Waste',
                paymentType: 'Debit Card',
                amount: '930.00',
              ),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Credit Card',
                amount: '450.25',
              ),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Gcash',
                amount: '350.50',
              ),
              C_PaymentHistory(
                date: 'mon Jun 20',
                time: '9:30 AM',
                wasteType: 'Municipal Waste',
                paymentType: 'Debit Card',
                amount: '930.00',
              ),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Gcash',
                amount: '450.25',
              ),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Gcash',
                amount: '350.50',
              ),
              C_PaymentHistory(
                date: 'mon Jun 20',
                time: '9:30 AM',
                wasteType: 'Municipal Waste',
                paymentType: 'Debit Card',
                amount: '930.00',
              ),
              C_PaymentHistory(
                date: 'Fri Jun 20',
                time: '8:30 AM',
                wasteType: 'Food Waste',
                paymentType: 'Gcash',
                amount: '450.25',
              ),
            ],
          )
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => C_PaymentHistoryDetails(),
          ),
        );
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
  const C_PaymentHistoryDetails({super.key});

  @override
  State<C_PaymentHistoryDetails> createState() =>
      _C_PaymentHistoryDetailsState();
}

class _C_PaymentHistoryDetailsState extends State<C_PaymentHistoryDetails> {
  bool isLoading = false;
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
  // void _dbData() async {
  //   final data = await userDataFromHive();
  //   setState(() {
  //     user = data['user'];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text('Payment',
            style: TextStyle(
                color: accentColor, fontSize: 25, fontWeight: FontWeight.bold)),
        // leading: SizedBox(width: 0),
        // leadingWidth: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(15),
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Pay with',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            String? sessionId =
                                await launchPaymentLinkSession(context);
                            //
                            if (sessionId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentBacktoApp(sessionId: sessionId),
                                ),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: Container(
                            child: Image.asset('assets/paymongo.png'),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Pay with',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            //checkPaymentStatus('cs_VwiaJRvwZQrSYFqKu3rrXgPq');
                            // launchPaymentLink(context);
                          },
                          child: Container(
                            child: Image.asset('assets/truck.png'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
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

class PaymentBacktoApp extends StatefulWidget {
  final sessionId;
  const PaymentBacktoApp({super.key, required this.sessionId});

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
        leading: SizedBox(width: 0),
        leadingWidth: 0,
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
                  Navigator.pop(context);
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
                  Text(widget.sessionId),
                  InkWell(
                    onTap: () {
                      checkPaymentStatus(widget.sessionId);
                    },
                    child: Container(
                      child: Image.asset('assets/paymongo.png'),
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
