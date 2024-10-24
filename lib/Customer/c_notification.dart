import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/Customer/c_payment.dart';
import 'package:trashtrack/Customer/c_schedule_list.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/mainApp.dart';
import 'package:trashtrack/styles.dart';
import 'package:intl/intl.dart';

class C_NotificationScreen extends StatefulWidget {
  @override
  State<C_NotificationScreen> createState() => _C_NotificationScreenState();
}

class _C_NotificationScreenState extends State<C_NotificationScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? notifications;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
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
  Future<void> _fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchCusNotifications();
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          notifications = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: Text('Notification'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: isLoading
            ? Container(
                padding: EdgeInsets.all(10),
                child: loadingAnimation(_controller, _colorTween, _colorTween2),
              )
            : notifications == null
                ? ListView(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, color: whiteSoft, size: 100),
                              Text(
                                'No notification at this time\n\n\n\n',
                                style: TextStyle(color: whiteSoft, fontSize: 20),
                              ),
                            ],
                          )),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: notifications!.length,
                    itemBuilder: (context, index) {
                      final notification = notifications![index];
                      final bool status = notification['notif_read'] == true;
                      String showStatus = status ? 'Read' : 'Sent';

                      final Color statusColor = status ? greySoft : Colors.green;
                      final Color boxColor = status ? white : deepPurple;

                      return GestureDetector(
                        onTap: () async {
                          if (notification['notif_read'] == false) {
                            await readNotif(notification['notif_id']);
                            int newCount = userModel!.notifCount! - 1;
                            userModel!.setUserData(newNotifCount: newCount);
                          }

                          DateTime dbdateIssue = DateTime.parse(notification['notif_created_at'] ?? '').toLocal();
                          String formatdate = DateFormat('MMM dd, yyyy hh:mm a').format(dbdateIssue);

                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                                builder: (context) => NotificationDetails(
                                    bkId: notification['bk_id'],
                                    gbId: notification['gb_id'],
                                    isRead: notification['notif_read'],
                                    message: notification['notif_message'],
                                    date: formatdate)),
                          )
                              .then((value) {
                            if (value == true) {
                              _fetchNotifications();
                            }
                          });
                        },
                        child: NotificationCard(
                          notif_id: notification['notif_id'],
                          dateTime: formatDateTime(notification['notif_created_at']),
                          title: notification['notif_message'],
                          status: showStatus,
                          statusColor: statusColor,
                          notifBoxColor: boxColor,
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String formatDateTime(String? dateTime) {
    // Parse the date and format it as 'MMM dd, yyyy hh:mm a'
    final date = DateTime.parse(dateTime ?? '').toLocal();
    return DateFormat('MMM dd, yyyy hh:mma').format(date);
  }
}

class NotificationCard extends StatelessWidget {
  final int notif_id;
  final String dateTime;
  final String title;
  final String status;
  final Color statusColor;
  final Color notifBoxColor;

  NotificationCard({
    required this.notif_id,
    required this.dateTime,
    required this.title,
    this.status = '',
    this.statusColor = Colors.transparent,
    this.notifBoxColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration:
          BoxDecoration(color: notifBoxColor, borderRadius: BorderRadius.circular(8), boxShadow: shadowLowColor),
      child: Row(
        children: [
          Icon(Icons.circle, color: statusColor, size: 16),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$dateTime', style: TextStyle(color: greySoft)),
                Text(
                  title,
                  style: TextStyle(color: status == 'Read' ? blackSoft : white, fontSize: 16),
                  maxLines: 1,
                  softWrap: true,
                ),
                if (status.isNotEmpty)
                  Align(alignment: Alignment.bottomRight, child: Text('$status', style: TextStyle(color: greySoft))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationDetails extends StatefulWidget {
  final String? message;
  final bool? isRead;
  final String? date;
  final int? bkId;
  final int? gbId;

  NotificationDetails({this.message, this.isRead, this.date, this.bkId, this.gbId});

  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: deepGreen,
        appBar: AppBar(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          //title: Text(''),
        ),
        body: ListView(
          children: [
            PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) {
                    return;
                  }

                  if (widget.isRead == true) {
                    return Navigator.pop(context);
                  }
                  Navigator.pop(context, true);
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => C_NotificationScreen()),
                  //   ModalRoute.withName('/mainApp'), // Keeps the home route in the stack
                  // );
                },
                child: Container()),
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.send, color: white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        widget.date ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (widget.bkId != null)
                    ClipRRect(borderRadius: borderRadius15, child: Image.asset('assets/image/truck_arrival2.jpg')),
                  if (widget.gbId != null)
                    ClipRRect(borderRadius: borderRadius15, child: Image.asset('assets/image/bill_ready3.jpg')),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(widget.message ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (widget.bkId != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => C_ScheduleDetails(bookId: widget.bkId!)));
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: deepPurple, borderRadius: BorderRadius.circular(50), boxShadow: shadowLowColor),
                        child: Text('Check booking!',
                            style: TextStyle(color: white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (widget.gbId != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => PaymentDetails(gb_id: widget.gbId!)));
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: deepPurple, borderRadius: BorderRadius.circular(50), boxShadow: shadowLowColor),
                        child: Text('Check bill!',
                            style: TextStyle(color: white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ));
  }
}
