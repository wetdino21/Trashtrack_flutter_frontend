import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/appbar.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/waste_history_schedule.dart';
import 'package:trashtrack/Hauler/waste_pickup_schedule.dart';
import 'package:trashtrack/styles.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
      backgroundColor: deepGreen,
      appBar: CustomAppBar(title: ''),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Text(
                  'Ready for another waste pickup schedule?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickUpSchedule(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30.0),
                    ),
                    child: Text(
                      'Pickup Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
           SizedBox(height: 20.0),
          // Divider(color: accentColor),
          Center(
            child: Text(
              'Schedule',
              style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30,
              ),
            ),
          ),
         
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
                              ? buttonColor
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
                              ? buttonColor
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
                        WasteCollectionCard(
                          date: 'Mon Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'pending',
                        ),
                        WasteCollectionCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'pending',
                        ),
                        WasteCollectionCard(
                          date: 'Fri Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Food Waste',
                          status: 'pending',
                        ),
                        WasteCollectionCard(
                          date: 'Fri Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'pending',
                        ),

                      ],
                    ),
                    // History Schedule
                    ListView(
                      children: [
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Municipal Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
                        ),
                        WasteCollectionHistoryCard(
                          date: 'Wed Jun 20',
                          time: '8:30 AM',
                          wasteType: 'Construction Waste',
                          status: 'complete',
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Set the current index to 2 for ScheduleScreen
      ),
    );
  }
}
