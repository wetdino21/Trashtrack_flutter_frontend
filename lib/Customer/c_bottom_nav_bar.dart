// import 'package:flutter/material.dart';

// class C_BottomNavBar extends StatelessWidget {
//   final int currentIndex;

//   C_BottomNavBar({required this.currentIndex});

//   void _onItemTapped(BuildContext context, int index) {
//     switch (index) {
//       case 0:
//       if(currentIndex!=0)
//         Navigator.pushNamed(context, 'c_home');
//         break;
//       case 1:
//       if(currentIndex!=1)
//         Navigator.pushNamed(context, 'c_map');
//         break;
//       case 2:
//       if(currentIndex!=2)
//         Navigator.pushNamed(context, 'c_schedule');
//         break;
//       case 3:
//       if(currentIndex!=3)
//         Navigator.pushNamed(context, 'c_payment');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       backgroundColor: Colors.black,
//       currentIndex: currentIndex,
//        items: [
//         BottomNavigationBarItem(
//           icon: currentIndex == 0
//               ? Icon(Icons.home)
//               : Icon(Icons.home_outlined),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: currentIndex == 1
//               ? Icon(Icons.map)
//               : Icon(Icons.map_outlined),
//           label: 'Map',
//         ),
//         BottomNavigationBarItem(
//           icon: currentIndex == 2
//               ? Icon(Icons.calendar_month)
//               : Icon(Icons.calendar_month_outlined),
//           label: 'Schedule',
//         ),
//         BottomNavigationBarItem(
//           icon: currentIndex == 3
//               ? Icon(Icons.payment)
//               : Icon(Icons.payment_outlined),
//           label: 'Payment',
//         ),
//       ],
//       onTap: (index) => _onItemTapped(context, index),
//       selectedItemColor: Colors.green,
//       unselectedItemColor: Colors.white,
//       type: BottomNavigationBarType.fixed,
//       selectedLabelStyle: const TextStyle(fontSize: 12),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:trashtrack/Customer/c_Schedule.dart';
import 'package:trashtrack/Customer/c_home.dart';
import 'package:trashtrack/Customer/c_map.dart';
import 'package:trashtrack/Customer/c_payment.dart';

class C_BottomNavBar extends StatelessWidget {
  final int currentIndex;

  C_BottomNavBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          _navigateWithoutAnimation(context, 'c_home');
        }
        break;
      case 1:
        if (currentIndex != 1) {
          _navigateWithoutAnimation(context, 'c_map');
        }
        break;
      case 2:
        if (currentIndex != 2) {
          _navigateWithoutAnimation(context, 'c_schedule');
        }
        break;
      case 3:
        if (currentIndex != 3) {
          _navigateWithoutAnimation(context, 'c_payment');
        }
        break;
    }
  }

  void _navigateWithoutAnimation(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return _getPageFromRoute(routeName);
      },
      // transitionDuration: Duration.zero, // Remove the transition animation
      // reverseTransitionDuration: Duration.zero, // Remove reverse transition animation
      // transitionDuration: Duration(days: 1),
      // reverseTransitionDuration: Duration(days: 2),
    
    ));
  }

  Widget _getPageFromRoute(String routeName) {
    // Define how to get the page based on the routeName. Replace these with your actual pages.
    switch (routeName) {
      case 'c_home':
        return C_HomeScreen();
      case 'c_map':
        return C_MapScreen();
      case 'c_schedule':
        return C_ScheduleScreen();
      case 'c_payment':
        return C_PaymentScreen();
      default:
        return C_HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 1 ? Icon(Icons.map) : Icon(Icons.map_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? Icon(Icons.calendar_month)
              : Icon(Icons.calendar_month_outlined),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: currentIndex == 3
              ? Icon(Icons.payment)
              : Icon(Icons.payment_outlined),
          label: 'Payment',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 12),
    );
  }
}

