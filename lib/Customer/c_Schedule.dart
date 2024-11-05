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

  List<Map<String, dynamic>>? currentBookingList;
  List<Map<String, dynamic>>? currentWasteList;
  List<Map<String, dynamic>>? historyBookingList;
  List<Map<String, dynamic>>? historyWasteList;

  bool isLoading = false;
  bool loadingAction = false;
  int selectedPage = 0;
  late PageController _pageController;

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

    //
    try {
      final userData = await userDataFromHive();
      setState(() {
        user = userData['user'];
      });

      Map<String, List<Map<String, dynamic>>>? data;
      if (user == 'customer') {
        data = await fetchCusBooking(context);
      } else if (user == 'hauler') {
        data = await fetchHaulerPickup();
      }

      if (!mounted) {
        return;
      }
      if (data != null) {
        setState(() {
          currentBookingList = data!['booking'];
          currentWasteList = data['wasteTypes'];
          historyBookingList = data['booking2'];
          historyWasteList = data['wasteTypes2'];
        });
      }

      //
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      console(e.toString());
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
                    InkWell(
                        onTap: () async {
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
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: deepGreen, borderRadius: BorderRadius.circular(15.0), boxShadow: shadowLowColor),
                          child: Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Colors.white,
                          ),
                        )),
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
                              : currentBookingList == null
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
                                  : ListView.builder(
                                      itemCount: currentBookingList?.length == null ? 0 : currentBookingList!.length,
                                      itemBuilder: (context, index) {
                                        // Safely retrieve the booking details from bookingList
                                        final booking = currentBookingList?[index];

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
                                        if (currentWasteList != null) {
                                          List<Map<String, dynamic>> filteredWasteList =
                                              currentWasteList!.where((waste) {
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
                                            if (currentBookingList!.length - 1 == index) SizedBox(height: 200),
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
                              : (currentBookingList == null) && historyBookingList == null
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
                                  : ListView.builder(
                                      itemCount: historyBookingList?.length == null ? 0 : historyBookingList!.length,
                                      itemBuilder: (context, index) {
                                        // Safely retrieve the booking details from bookingList
                                        final booking = historyBookingList?[index];

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
                                        if (historyWasteList != null) {
                                          List<Map<String, dynamic>> filteredWasteList =
                                              historyWasteList!.where((waste) {
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
                                            if (historyBookingList!.length - 1 == index) SizedBox(height: 200),
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
    );
  }
}
