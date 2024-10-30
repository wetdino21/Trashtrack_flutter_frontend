import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trashtrack/main.dart';
import 'package:trashtrack/styles.dart';
import 'package:trashtrack/user_hive_data.dart';

class C_BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  C_BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  State<C_BottomNavBar> createState() => _C_BottomNavBarState();
}

class _C_BottomNavBarState extends State<C_BottomNavBar> {
  // User data
  Map<String, dynamic>? userData;
  String user = 'customer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await userDataFromHive();
    setState(() {
      userData = data;
      user = data['user'];
      print(user);
    });
  }

  void _onItemTapped(int index) {
    // switch (index) {
    //   case 0:
    //     if (ModalRoute.of(context)?.settings.name == 'c_map') {
    //       Navigator.of(context).pop();
    //     }
    //     break;
    //   case 1:
    //     break;
    //   case 2:
    //     if (ModalRoute.of(context)?.settings.name == 'c_map') {
    //       Navigator.of(context).pop();
    //     }
    //     break;
    //   case 3:
    //     if (ModalRoute.of(context)?.settings.name == 'c_map') {
    //       Navigator.of(context).pop();
    //     }
    //     break;
    // }
    widget.onTap(index); // Call the onTap callback with selected index
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 70,
      //color: const Color.fromARGB(255, 21, 8, 44),
      color: white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: width * .25,
            child: _buildIconButton(
              //icon: widget.currentIndex == 0 ? Icons.home : Icons.home_outlined,
              icon: Icons.home,
              label: 'Home',
              index: 0,
            ),
          ),
          Container(
            width: width * .25,
            child: _buildIconButton(
              //icon: widget.currentIndex == 1 ? Icons.map : Icons.map_outlined,
              icon: Icons.map_outlined,
              label: 'Map',
              index: 1,
            ),
          ),
          Container(
            width: width * .25,
            child: _buildIconButton(
              //icon: widget.currentIndex == 2 ? Icons.calendar_month : Icons.calendar_month_outlined,
              icon: Icons.calendar_month,
              label: 'Schedule',
              index: 2,
            ),
          ),
          Container(
            width: width * .25,
            child: _buildIconButton(
              // icon: widget.currentIndex == 3 && user == 'customer'
              //     ? (user == 'customer' ? Icons.payment : Icons.directions_car)
              //     : (user == 'customer' ? Icons.payment_outlined : Icons.directions_car_filled_outlined),
              icon: user == 'customer' ? Icons.payment : Icons.directions_car,
              label: user == 'customer' ? 'Payment' : 'Vehicle',
              index: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          index != widget.currentIndex
              ? Icon(
                  icon,
                  //color: widget.currentIndex == index ? Colors.green : Colors.white
                  color: black,
                )
              : SizedBox(height: 24),
          Text(
            label,
            style: TextStyle(
              //color: widget.currentIndex == index ? Colors.green : black,
              color: black,
              fontSize: 12,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}


// class C_BottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   C_BottomNavBar({required this.currentIndex, required this.onTap});

//   @override
//   State<C_BottomNavBar> createState() => _C_BottomNavBarState();
// }

// class _C_BottomNavBarState extends State<C_BottomNavBar> {
//   //user data
//   Map<String, dynamic>? userData;
//   String user = 'customer';

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() async {
//     final data = await userDataFromHive();
//     setState(() {
//       userData = data;
//       user = data['user'];
//       print(user);
//     });
//   }

//   void _onItemTapped(BuildContext context, int index) {
//     switch (index) {
//       case 0:
//         if (ModalRoute.of(context)?.settings.name == 'c_map') {
//           Navigator.of(context).pop(); // dispose if mapscreen
//         }
//         //if (currentIndex != 0) Navigator.pushNamed(context, 'c_home');
//         break;
//       case 1:
//         //if (currentIndex != 1) Navigator.pushNamed(context, 'c_map');
//         break;
//       case 2:
//         if (ModalRoute.of(context)?.settings.name == 'c_map') {
//           Navigator.of(context).pop(); // dispose if mapscreen
//         }
//         //if (currentIndex != 2) Navigator.pushNamed(context, 'c_schedule');
//         break;
//       case 3:
//         if (ModalRoute.of(context)?.settings.name == 'c_map') {
//           Navigator.of(context).pop(); // dispose if mapscreen
//         }
//         //if (currentIndex != 3) Navigator.pushNamed(context, 'c_payment');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         splashColor: Colors.transparent, // Disable splash effect
//         //highlightColor: Colors.transparent, // Disable highlight effect
//       ),
//       child: BottomNavigationBar(
//         backgroundColor: const Color.fromARGB(255, 21, 8, 44),
//         currentIndex: widget.currentIndex,
//         items: [
//           BottomNavigationBarItem(
//             icon: widget.currentIndex == 0
//                 ? Icon(Icons.home)
//                 : Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: widget.currentIndex == 1
//                 ? Icon(Icons.map)
//                 : Icon(Icons.map_outlined),
//             label: 'Map',
//           ),
//           BottomNavigationBarItem(
//             icon: widget.currentIndex == 2
//                 ? Icon(Icons.calendar_month)
//                 : Icon(Icons.calendar_month_outlined),
//             label: 'Schedule',
//           ),
//           BottomNavigationBarItem(
//             icon: widget.currentIndex == 3 && user == 'customer'
//                 ? Icon(
//                     user == 'customer' ? Icons.payment : Icons.directions_car)
//                 : Icon(user == 'customer'
//                     ? Icons.payment_outlined
//                     : Icons.directions_car_filled_outlined),
//             label: user == 'customer' ? 'Payment' : 'Vehicle',
//           ),
//         ],
//         // onTap: (index) => _onItemTapped(context, index),
//         onTap: widget.onTap, // Pass the selected index to the callback function
//         selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.white,
//         type: BottomNavigationBarType.fixed,
//         selectedLabelStyle: const TextStyle(fontSize: 12),
//         enableFeedback: true,
//       ),
//     );
//   }
// }
