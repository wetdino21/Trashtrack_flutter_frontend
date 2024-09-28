import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_appbar.dart';
import 'package:trashtrack/Customer/c_bottom_nav_bar.dart';
import 'package:trashtrack/Customer/c_drawer.dart';
import 'package:trashtrack/Customer/c_waste_history_schedule.dart';
import 'package:trashtrack/Customer/c_waste_pickup_schedule.dart';
import 'package:trashtrack/Customer/c_waste_request_pickup.dart';
import 'package:trashtrack/styles.dart';

class C_ScheduleScreen extends StatefulWidget {
  @override
  State<C_ScheduleScreen> createState() => _C_ScheduleScreenState();
}

class _C_ScheduleScreenState extends State<C_ScheduleScreen> {
  int selectedPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedPage);
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
                      )
                      //Text(
                      //   'Request Pickup Now',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 18.0,
                      //   ),
                      // ),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          // Divider(color: accentColor),
          // Center(
          //   child: Text(
          //     'Schedule',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.bold,
          //       fontSize: 30,
          //     ),
          //   ),
          // ),

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
                height: MediaQuery.of(context).size.height * .5,
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
                    ListView(
                      children: [
                        C_WasteCollectionCard(
                          date: 'Fri Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Pending',
                        ),
                        C_WasteCollectionCard(
                          date: 'Mon Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'Pending',
                        ),
                        C_WasteCollectionCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'Pending',
                        ),
                        C_WasteCollectionCard(
                          date: 'Fri Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Food Waste',
                          status: 'Pending',
                        ),
                      ],
                    ),
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
