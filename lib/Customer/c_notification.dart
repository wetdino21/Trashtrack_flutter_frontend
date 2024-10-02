import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_api_cus_data.dart';
import 'package:trashtrack/styles.dart';
import 'package:intl/intl.dart';

class C_NotificationScreen extends StatefulWidget {
  @override
  State<C_NotificationScreen> createState() => _C_NotificationScreenState();
}

class _C_NotificationScreenState extends State<C_NotificationScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? notifications;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;
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
      final data = await fetchCusNotifications(context);
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Notification'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: isLoading
            ? AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              borderRadius: BorderRadius.circular(10),
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
            : notifications == null
                ? Center(
                    child: Text(
                    'No available notification.\n\n\n\n',
                    style: TextStyle(color: accentColor, fontSize: 20),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: notifications!.length,
                    itemBuilder: (context, index) {
                      final notification = notifications![index];
                      final status = notification['notif_status'] ?? '';
                      final statusColor = status == 'Delivered'
                          ? Colors.green
                          : status == 'Seen'
                              ? Colors.white54
                              : Colors.transparent;
                      final boxColor = status == 'Delivered'
                          ? Colors.green.withOpacity(0.2)
                          : status == 'Seen'
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.green;

                      return NotificationCard(
                        dateTime:
                            formatDateTime(notification['notif_created_at']),
                        title: notification['notif_message'],
                        status: status,
                        statusColor: statusColor,
                        boxColor: boxColor,
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
  final String dateTime;
  final String title;
  final String status;
  final Color statusColor;
  final Color boxColor;

  NotificationCard({
    required this.dateTime,
    required this.title,
    this.status = '',
    this.statusColor = Colors.transparent,
    this.boxColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Notification"),
              content: Text("Would you like to proceed to the map?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(builder: (context) => C_MapScreen()),
                    // );
                  },
                  child: Text("Proceed"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: statusColor, size: 16),
            SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$dateTime', style: TextStyle(color: Colors.white60)),
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    softWrap: true,
                  ),
                  if (status.isNotEmpty)
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Text('$status',
                            style: TextStyle(color: Colors.white60))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
