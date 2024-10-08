import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_schedule_list.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';

class C_ScheduleScreen extends StatefulWidget {
  @override
  State<C_ScheduleScreen> createState() => _C_ScheduleScreenState();
}

class _C_ScheduleScreenState extends State<C_ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  bool isLoading = false;
  int selectedPage = 0;
  late PageController _pageController;
  bool containCurrent = false;
  bool containHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
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
    super.dispose();
  }

  // Fetch booking from the server
  Future<void> _fetchBookingData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchBookingData(context);
      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          bookingList = data['booking'];
          bookingWasteList = data['wasteTypes'];

          if (bookingList != null) {
            var filteredCurrent = bookingList!.where((booking) {
              return booking['bk_status'] == 'Pending' ||
                  booking['bk_status'] == 'Ongoing';
            }).toList();

            // Check if filteredList has any items
            if (filteredCurrent.isNotEmpty) {
              containCurrent = true;
            }
          }

          if (bookingList != null) {
            var filteredHistory = bookingList!.where((booking) {
              return booking['bk_status'] == 'Cancelled' ||
                  booking['bk_status'] == 'Collected';
            }).toList();

            // Check if filteredList has any items
            if (filteredHistory.isNotEmpty) {
              containHistory = true;
            }
          }
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

  void onPageSelected(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      // appBar: C_CustomAppBar(title: 'Schedule'), //Schedule
      // drawer: C_Drawer(),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: white,
              boxShadow: shadowMidColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Book now?',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(boxShadow: shadowColor),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestPickupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deepGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right_outlined,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: shadowMidColor,
                  borderRadius: BorderRadius.circular(5.0),
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
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            'Current',
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
                              borderRadius: BorderRadius.circular(5.0),
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
              SizedBox(height: 20.0),
              Container(
                height: MediaQuery.of(context).size.height * .58,
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
                          : bookingList == null || !containCurrent
                              ? ListView(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Text(
                                          'No Available Current Schedule .\n\n\n\n',
                                          style: TextStyle(
                                              color: white, fontSize: 20),
                                        ),
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
                                      : bookingList!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return SizedBox(height: 20.0);
                                    }

                                    // Safely retrieve the booking details from bookingList
                                    final booking = bookingList?[index - 1];

                                    if (booking == null) {
                                      return SizedBox.shrink();
                                    }

                                    if (booking['bk_status'] == 'Pending' ||
                                        booking['bk_status'] == 'Ongoing') {
                                      int book_Id = booking['bk_id'];
                                      DateTime dbdate = DateTime.parse(
                                              booking['bk_date'] ?? '')
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
                                        List<Map<String, dynamic>>
                                            filteredWasteList =
                                            bookingWasteList!.where((waste) {
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
                                      return C_ScheduleCardList(
                                        bookId: book_Id,
                                        date: date,
                                        dateCreated: dateCreated,
                                        wasteType: wasteTypes,
                                        status: status,
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                    ),

                    // History Schedule
                    RefreshIndicator(
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
                          : bookingList == null || !containHistory
                              ? ListView(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Text(
                                          'No available Scheduled History.\n\n\n\n',
                                          style: TextStyle(
                                              color: white, fontSize: 20),
                                        ),
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
                                      : bookingList!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return SizedBox(height: 20.0);
                                    }

                                    // Safely retrieve the booking details from bookingList
                                    final booking = bookingList?[index - 1];

                                    if (booking == null) {
                                      return SizedBox.shrink();
                                    }

                                    if (booking['bk_status'] == 'Cancelled' ||
                                        booking['bk_status'] == 'Collected') {
                                      int book_Id = booking['bk_id'];
                                      DateTime dbdate = DateTime.parse(
                                              booking['bk_date'] ?? '')
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
                                        List<Map<String, dynamic>>
                                            filteredWasteList =
                                            bookingWasteList!.where((waste) {
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
                                      return C_ScheduleCardList(
                                        bookId: book_Id,
                                        date: date,
                                        dateCreated: dateCreated,
                                        wasteType: wasteTypes,
                                        status: status,
                                      );
                                    }
                                    return Container();
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
      // bottomNavigationBar: C_BottomNavBar(
      //   currentIndex: 2,
      // ),
    );
  }
}
