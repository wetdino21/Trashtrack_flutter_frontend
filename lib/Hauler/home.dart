import 'package:flutter/material.dart';
import 'package:trashtrack/Hauler/bottom_nav_bar.dart';
import 'package:trashtrack/Hauler/styles.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF001E00);
    final Color accentColor = Color(0xFF6AA920);
    final Color buttonColor = Color(0xFF86BF3E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text(
                  'Home',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/anime.jpg'),
            ),
          ),
        ],
        leading: SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF103510),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Taehyung!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Another waste collection day. Drive safe!',
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
                            builder: (context) => ScheduleScreen(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Waste Collection History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAllCollectionHistory()));
                  },
                  child: Text(
                    'View all',
                    style: TextStyle(color: accentColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            WasteCollectionCard(
              date: 'Wed Jun 20',
              time: '8:30 AM',
              wasteType: 'Municipal Waste',
            ),
            WasteCollectionCard(
              date: 'Wed Jun 20',
              time: '8:30 AM',
              wasteType: 'Construction Waste',
            ),
            WasteCollectionCard(
              date: 'Wed Jun 20',
              time: '8:30 AM',
              wasteType: 'Construction Waste',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Set the current index to 0 for HomeScreen
        onTap: (int index) {
          if (index == 0) {
            //Navigator.pushNamed(context, 'home');
            return;
          } else if (index == 1) {
            Navigator.pushNamed(context, 'map');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'notification');
          } else if (index == 3) {
            Navigator.pushNamed(context, 'profile');
          }
        },
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedPage = 0; // 0 for Contractual, 1 for Non-Contractual
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
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text('Schedule'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/anime.jpg'),
            ),
          ),
        ],
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
                Expanded(
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
                      'Contractual',
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
                      'Non-Contractual',
                      style: TextStyle(
                        color:
                            selectedPage == 1 ? Colors.white : Colors.white70,
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
              onPageChanged: onPageSelected,
              children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF86BF3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF86BF3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
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

      },
      splashColor: Colors.green,
      highlightColor: Colors.green.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        color: Color(0xFF103510),
       
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

class ViewAllCollectionHistory extends StatelessWidget {
  const ViewAllCollectionHistory({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text('Your Collection History'),
      ),
      body: Container(),
    );
  }
}
