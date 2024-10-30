import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_schedule_list.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/booking_pending_list.dart';
import 'package:trashtrack/home.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class C_ScheduleScreen extends StatefulWidget {
  @override
  State<C_ScheduleScreen> createState() => _C_ScheduleScreenState();
}

class _C_ScheduleScreenState extends State<C_ScheduleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<Color?> _colorTween2;

  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  List<Map<String, dynamic>>? bookingListHistory;
  List<Map<String, dynamic>>? bookingWasteListHistory;

  bool isLoading = false;
  bool loadingAction = false;
  int selectedPage = 0;
  late PageController _pageController;
  bool containCurrent = false;
  bool containHistory = false;

  String? user;

  @override
  void initState() {
    super.initState();

    //_dbData();
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
    _pageController.dispose();
    super.dispose();
  }

  // Future<void> _dbData() async {
  //   try {
  //     final data = await userDataFromHive();
  //     setState(() {
  //       user = data['user'];
  //     });
  //   } catch (e) {
  //     // setState(() {
  //     //   errorMessage = e.toString();
  //     //   isLoading = false;
  //     // });
  //   }
  // }

  // Fetch booking from the server
  Future<void> _fetchBookingData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userData = await userDataFromHive();
      setState(() {
        user = userData['user'];
      });

      Map<String, List<Map<String, dynamic>>>? data;
      if (user == 'customer') {
        data = await fetchBookingData(context);
      } else if (user == 'hauler') {
        data = await fetchCurrentPickup();
      }

      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          bookingList = data!['booking'];
          bookingWasteList = data['wasteTypes'];
          bookingListHistory = data['booking2'];
          bookingWasteListHistory = data['wasteTypes2'];

          if (bookingList != null) {
            var filteredCurrent = bookingList!.where((booking) {
              return booking['bk_status'] == 'Pending' || booking['bk_status'] == 'Ongoing';
            }).toList();

            // Check if filteredList has any items
            if (filteredCurrent.isNotEmpty) {
              containCurrent = true;
            }
          }

          if (bookingList != null) {
            var filteredHistory = bookingList!.where((booking) {
              return booking['bk_status'] == 'Cancelled' || booking['bk_status'] == 'Collected';
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
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: shadowMidColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user != null)
                      Container(
                        padding: EdgeInsets.all(20.0),
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          user == 'customer'
                              ? 'Book now?'
                              : user == 'hauler'
                                  ? 'Pickup Waste?'
                                  : '',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), boxShadow: shadowLowColor),
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loadingAction = true;
                              });
                              //
                              if (user == 'customer') {
                                String? bklimit = await checkBookingLimit(context);
                                if (bklimit == 'max') {
                                  showBookLimitDialog(context);
                                } else if (bklimit == 'disabled') {
                                  showErrorSnackBar(context, 'We are not accepting booking right now!');
                                } else if (bklimit == 'no limit') {
                                  showErrorSnackBar(context, 'No booking limit found');
                                } else if (bklimit == 'success') {
                                  String? isUnpaidBIll = await checkUnpaidBIll(context);
                                  if (isUnpaidBIll == 'Unpaid') {
                                    showUnpaidBillDialog(context);
                                  } else if (isUnpaidBIll == 'success') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RequestPickupScreen(),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Booking_List(),
                                  ),
                                );
                              }
                              //
                              setState(() {
                                loadingAction = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: white,
                      boxShadow: shadowMidColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                                color: selectedPage == 0 ? deepPurple : white,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(50)),
                                boxShadow: shadowColor),
                            child: InkWell(
                              onTap: () => onPageSelected(0),
                              child: Center(
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedPage == 0 ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                                color: selectedPage == 1 ? deepPurple : white,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(50)),
                                boxShadow: shadowColor),
                            child: InkWell(
                              onTap: () => onPageSelected(1),
                              child: Center(
                                child: Text(
                                  'History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedPage == 1 ? Colors.white : Colors.black,
                                  ),
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
                              decoration: BoxDecoration(color: Colors.grey[300], boxShadow: shadowMidColor),
                            )),
                        Expanded(flex: 5, child: Container()),
                        Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.grey[300], boxShadow: shadowMidColor),
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
                            await _fetchBookingData();
                          },
                          child: isLoading
                              ? loadingAnimation(_controller, _colorTween, _colorTween2)
                              : bookingList == null || !containCurrent
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
                                                    Icon(Icons.calendar_month, color: whiteSoft, size: 70),
                                                    Text(
                                                      'No upcoming booking\n\n\n\n',
                                                      style: TextStyle(color: whiteSoft, fontSize: 20),
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
                                  : user == 'customer'
                                      ? ListView.builder(
                                          itemCount: bookingList?.length == null ? 0 : bookingList!.length,
                                          itemBuilder: (context, index) {
                                            // Safely retrieve the booking details from bookingList
                                            final booking = bookingList?[index];

                                            if (booking == null) {
                                              return SizedBox.shrink();
                                            }

                                            if (booking['bk_status'] == 'Pending' ||
                                                booking['bk_status'] == 'Ongoing') {
                                              int book_Id = booking['bk_id'];
                                              DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                              final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                              DateTime dbdateCreated =
                                                  DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                              final String dateCreated =
                                                  DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

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
                                                    wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                                  }
                                                }
                                              }

                                              final String status = booking['bk_status'] ?? 'No status';

                                              // Pass the extracted data to the C_CurrentScheduleCard widget
                                              return Column(
                                                children: [
                                                  C_ScheduleCardList(
                                                    bookId: book_Id,
                                                    date: date,
                                                    dateCreated: dateCreated,
                                                    wasteType: wasteTypes,
                                                    status: status,
                                                  ),
                                                  if (bookingList!.length - 1 == index) SizedBox(height: 200),
                                                ],
                                              );
                                            }
                                            if (bookingList!.length - 1 == index) return const SizedBox(height: 200);
                                            return Container();
                                          },
                                        )

                                      //hauler current pickup
                                      : ListView.builder(
                                          itemCount: bookingList?.length == null ? 0 : bookingList!.length,
                                          itemBuilder: (context, index) {
                                            // Safely retrieve the booking details from bookingList
                                            final booking = bookingList?[index];

                                            if (booking == null) {
                                              return SizedBox.shrink();
                                            }

                                            int book_Id = booking['bk_id'];
                                            DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                            final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                            DateTime dbdateCreated =
                                                DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                            final String dateCreated =
                                                DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

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
                                                  wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                                }
                                              }
                                            }

                                            final String status = booking['bk_status'] ?? 'No status';

                                            // Pass the extracted data to the C_CurrentScheduleCard widget
                                            return Column(
                                              children: [
                                                C_ScheduleCardList(
                                                  bookId: book_Id,
                                                  date: date,
                                                  dateCreated: dateCreated,
                                                  wasteType: wasteTypes,
                                                  status: status,
                                                ),
                                                if (bookingList!.length - 1 == index) SizedBox(height: 200),
                                              ],
                                            );
                                          },
                                        ),
                        ),

                        // History Schedule
                        RefreshIndicator(
                          onRefresh: () async {
                            //await _dbData();
                            await _fetchBookingData();
                          },
                          child: isLoading
                              ? loadingAnimation(_controller, _colorTween, _colorTween2)
                              : (bookingList == null || !containHistory) && bookingListHistory == null
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
                                                    Icon(Icons.history, color: whiteSoft, size: 70),
                                                    Text(
                                                      'No scheduled history\n\n\n\n',
                                                      style: TextStyle(color: whiteSoft, fontSize: 20),
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
                                  : user == 'customer'
                                      ? ListView.builder(
                                          itemCount: bookingList?.length == null ? 0 : bookingList!.length,
                                          itemBuilder: (context, index) {
                                            // Safely retrieve the booking details from bookingList
                                            final booking = bookingList?[index];

                                            if (booking == null) {
                                              return SizedBox.shrink();
                                            }

                                            if (booking['bk_status'] == 'Cancelled' ||
                                                booking['bk_status'] == 'Collected') {
                                              int book_Id = booking['bk_id'];
                                              DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                              final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                              DateTime dbdateCreated =
                                                  DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                              final String dateCreated =
                                                  DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

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
                                                    wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                                  }
                                                }
                                              }

                                              final String status = booking['bk_status'] ?? 'No status';

                                              // Pass the extracted data to the C_CurrentScheduleCard widget
                                              return Column(
                                                children: [
                                                  C_ScheduleCardList(
                                                    bookId: book_Id,
                                                    date: date,
                                                    dateCreated: dateCreated,
                                                    wasteType: wasteTypes,
                                                    status: status,
                                                  ),
                                                  if (bookingList!.length - 1 == index) SizedBox(height: 200),
                                                ],
                                              );
                                            }
                                            if (bookingList!.length - 1 == index) return SizedBox(height: 200);
                                            return Container();
                                          },
                                        )
                                      //hauler history
                                      : ListView.builder(
                                          itemCount:
                                              bookingListHistory?.length == null ? 0 : bookingListHistory!.length,
                                          itemBuilder: (context, index) {
                                            // Safely retrieve the booking details from bookingList
                                            final booking = bookingListHistory?[index];

                                            if (booking == null) {
                                              return SizedBox.shrink();
                                            }

                                            int book_Id = booking['bk_id'];
                                            DateTime dbdate = DateTime.parse(booking['bk_date'] ?? '').toLocal();
                                            final String date = DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                                            DateTime dbdateCreated =
                                                DateTime.parse(booking['bk_created_at'] ?? '').toLocal();
                                            final String dateCreated =
                                                DateFormat('MMM dd, yyyy hh:mm a').format(dbdateCreated);

                                            // Filter waste types for the current booking's bk_id
                                            String wasteTypes = '';
                                            if (bookingWasteListHistory != null) {
                                              List<Map<String, dynamic>> filteredWasteList =
                                                  bookingWasteListHistory!.where((waste) {
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
                                                  wasteTypes = wasteTypes.substring(0, wasteTypes.length - 2);
                                                }
                                              }
                                            }

                                            final String status = booking['bk_status'] ?? 'No status';

                                            // Pass the extracted data to the C_CurrentScheduleCard widget
                                            return Column(
                                              children: [
                                                C_ScheduleCardList(
                                                  bookId: book_Id,
                                                  date: date,
                                                  dateCreated: dateCreated,
                                                  wasteType: wasteTypes,
                                                  status: status,
                                                ),
                                                if (bookingList!.length - 1 == index) SizedBox(height: 200),
                                              ],
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
          if (loadingAction) showLoadingAction(),
        ],
      ),
      // bottomNavigationBar: C_BottomNavBar(
      //   currentIndex: 2,
      // ),
    );
  }
}
