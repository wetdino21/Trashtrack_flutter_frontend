import 'package:flutter/material.dart';

// class C_AboutUs extends StatelessWidget {
//   const C_AboutUs({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('About Us'),
//       ),
//       body: Container(),
//     );
//   }
// }

class C_AboutUs extends StatefulWidget {
   final int? selectedIndex; // Optional selectedIndex parameter

  C_AboutUs({this.selectedIndex});
  @override
  _C_AboutUsState createState() => _C_AboutUsState();
}

class _C_AboutUsState extends State<C_AboutUs> {
  int _selectedIndex = 0;

  // Define pages here
  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    // If a selectedIndex is passed, use it to set the currentIndex
    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: C_CustomAppBar(
          title: _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
                  ? 'Notifications'
                  : 'Profile'), // Update title based on the page
      body: _pages[_selectedIndex], // Change the body based on selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// CustomAppBar that stays persistent
class C_CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  C_CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// Example HomePage
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Example NotificationsPage
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Notifications Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Profile Page',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
           
            },
            child: Text('Go to Home Page'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
               Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  C_AboutUs(selectedIndex: 1)));

              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context)=> C_AboutUs(selectedIndex: 1)),
              // );
            },
            child: Text('Go to Notifications Page'),
          ),
        ],
      ),
    );
  }
}
