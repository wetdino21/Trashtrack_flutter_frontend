import 'package:flutter/material.dart';
import 'package:trashtrack/styles.dart';

class PickUpSchedule extends StatefulWidget {
  @override
  _PickUpScheduleState createState() => _PickUpScheduleState();
}

class _PickUpScheduleState extends State<PickUpSchedule> {
  int selectedPage = 0; // 0 for All, 1 for Contractual, 2 for Non-Contractual
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Schedule'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Center(
            child: Text(
              'List Of Pickup Schedules',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Color(0xFF103510),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: () => onPageSelected(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedPage == 0 ? buttonColor : Color(0xFF001E00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color:
                            selectedPage == 0 ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onPageSelected(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedPage == 1 ? buttonColor : Color(0xFF001E00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Contractual',
                      style: TextStyle(
                        color:
                            selectedPage == 1 ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onPageSelected(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedPage == 2 ? buttonColor : Color(0xFF001E00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Non-Contractual',
                      style: TextStyle(
                        color:
                            selectedPage == 2 ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedPage = index;
                });
              },
              children: [
                // All Waste Collection Cards
                ListView(
                  children: [
                    WasteCollectionCard(
                      date: 'Mon Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Municipal Waste',
                    ),
                    WasteCollectionCard(
                      date: 'Wed Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Construction Waste',
                    ),
                    WasteCollectionCard(
                      date: 'Fri Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Food Waste',
                    ),
                    WasteCollectionCard(
                      date: 'Fri Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Construction Waste',
                    ),
                  ],
                ),
                // Contractual Waste Collection Cards
                ListView(
                  children: [
                    WasteCollectionCard(
                      date: 'Mon Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Municipal Waste',
                    ),
                    WasteCollectionCard(
                      date: 'Wed Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Construction Waste',
                    ),
                  ],
                ),
                // Non-Contractual Waste Collection Cards
                ListView(
                  children: [
                    WasteCollectionCard(
                      date: 'Fri Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Food Waste',
                    ),
                    WasteCollectionCard(
                      date: 'Fri Jun 20',
                      time: '8:30 AM',
                      wasteType: 'Construction Waste',
                    ),
                  ],
                ),
              ],
            ),
          ),
         
        ],
      ),
    );
  }
}

class WasteCollectionCard extends StatelessWidget {
  final String date;
  final String time;
  final String wasteType;

  WasteCollectionCard({
    required this.date,
    required this.time,
    required this.wasteType,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WasteColScheduleDetails()));
      },
      splashColor: Colors.green,
      highlightColor: Colors.green.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: boxColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF6AA920)),
                SizedBox(width: 10.0),
                Text(
                  date,
                  style: TextStyle(color: Colors.white70, fontSize: 16.0),
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
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class WasteColScheduleDetails extends StatelessWidget {
  const WasteColScheduleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details'),
      ),
      body: Container(),
    );
  }
}
