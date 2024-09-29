import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/Customer/c_drawer.dart';
import 'package:trashtrack/Customer/c_schedule_history.dart';
import 'package:trashtrack/Customer/c_schedule_current.dart';
import 'package:trashtrack/Customer/c_booking.dart';
import 'package:trashtrack/api_postgre_service.dart';
import 'package:trashtrack/styles.dart';

class C_ScheduleScreen extends StatefulWidget {
  @override
  State<C_ScheduleScreen> createState() => _C_ScheduleScreenState();
}

class _C_ScheduleScreenState extends State<C_ScheduleScreen> {
  List<Map<String, dynamic>>? bookingList;
  List<Map<String, dynamic>>? bookingWasteList;
  bool isLoading = false;
  int selectedPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _pageController = PageController(initialPage: selectedPage);
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
      backgroundColor: backgroundColor,
      appBar: C_CustomAppBar(title: 'Schedule'), //Schedule
      drawer: C_Drawer(),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF103510),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Book now?',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
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
                        backgroundColor: buttonColor,
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
              ],
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(height: 10.0),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFF103510),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onPageSelected(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPage == 0
                              ? Colors.deepPurple
                              : Color(0xFF001E00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            color: selectedPage == 0
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onPageSelected(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPage == 1
                              ? Colors.deepPurple
                              : Color(0xFF001E00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'History',
                          style: TextStyle(
                            color: selectedPage == 1
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                height: MediaQuery.of(context).size.height * .6,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedPage = index;
                    });
                  },
                  children: [
                    // Current Schedule

                    //isLoading?
                    ListView.builder(
                      itemCount: bookingList?.length ?? 0,
                      itemBuilder: (context, index) {
                        // Safely retrieve the booking details from bookingList
                        final booking = bookingList?[index];

                        if (booking == null) {
                          return SizedBox.shrink();
                        }

                        int book_Id = booking['bk_id'];
                        DateTime dbdate =
                            DateTime.parse(booking['bk_date'] ?? '').toLocal();
                        final String date =
                            DateFormat('MMM dd, yyyy (EEEE)').format(dbdate);

                        DateTime dbdateCreated =
                            DateTime.parse(booking['bk_created_at'] ?? '')
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
                        return C_CurrentScheduleCard(
                          bookId: book_Id,
                          date: date,
                          dateCreated: dateCreated,
                          wasteType: wasteTypes,
                          status: status,
                        );
                      },
                    ),
                    // : Container(
                    //   alignment: Alignment.center,
                    //   child: Text('No Current Booking Available.', style: TextStyle(color: Colors.white, fontSize: 18)),
                    // ),

                    // History Schedule
                    ListView(
                      children: [
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                        C_WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Complete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: C_BottomNavBar(
        currentIndex: 2,
      ),
    );
  }
}
