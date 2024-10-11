import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_schedule_list.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class Booking_List extends StatefulWidget {
  @override
  State<Booking_List> createState() => _Booking_ListState();
}

class _Booking_ListState extends State<Booking_List>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  bool isLoading = false;

  String? user;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _dbData();

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

  Future<void> _dbData() async {
    try {
      final data = await userDataFromHive();
      setState(() {
        user = data['user'];
      });
    } catch (e) {}
  }

  // Fetch booking from the server
  Future<void> _fetchBookingData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchPendingBooking();
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          bookingList = data['booking'];
          bookingWasteList = data['wasteTypes'];

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
        foregroundColor: white,
        backgroundColor: deepGreen,
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: boxDecorationBig,
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: boxDecoration1,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Pickup',
                      style: TextStyle(
                          color: deepPurple,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      'List of Booking waiting for Pickup',
                      style: TextStyle(color: blackSoft, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
          Container(
            height: 30,
            child: Row(
              children: [
                Expanded(flex: 5, child: Container()),
                Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: white, boxShadow: shadowMidColor),)),
                Expanded(flex: 5, child: Container()),
                Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: white, boxShadow: shadowMidColor),)),
                Expanded(flex: 5, child: Container()),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .58,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchBookingData();
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
                      : bookingList == null
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
                                            Icon(Icons.calendar_month,
                                                color: whiteSoft, size: 70),
                                            Text(
                                              'No Available List for Pickup\n\n\n\n',
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
                              itemCount: bookingList?.length == null
                                  ? 0
                                  : bookingList!.length,
                              itemBuilder: (context, index) {
                                // if (index == 0) {
                                //   return SizedBox(height: 20.0);
                                // }

                                // Safely retrieve the booking details from bookingList
                                final booking = bookingList?[index];

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
                                if (bookingWasteList != null) {
                                  List<Map<String, dynamic>> filteredWasteList =
                                      bookingWasteList!.where((waste) {
                                    return waste['bk_id'] == booking['bk_id'];
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
                                return C_ScheduleCardList(
                                  bookId: book_Id,
                                  date: date,
                                  dateCreated: dateCreated,
                                  wasteType: wasteTypes,
                                  status: status,
                                );
                              },
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
