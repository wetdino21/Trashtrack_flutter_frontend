import 'package:flutter/material.dart';
import 'package:trashtrack/bottom_nav_bar.dart';
import 'package:trashtrack/styles.dart';

class ServiceGuidelines extends StatelessWidget {
  const ServiceGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Guidelines'),
      ),
      body: Container(
        color: deepPurple,
      ),
      //bottomNavigationBar: Bottomnavbar2(),
    );
  }
}

// class Bottomnavbar2 extends StatefulWidget {
//   @override
//   _Bottomnavbar2State createState() => _Bottomnavbar2State();
// }

// class _Bottomnavbar2State extends State<Bottomnavbar2> {
//   int selectedIndex = 0;

//   // List of icons in the bottom navigation bar
//   final List<IconData> icons = [
//     Icons.home,
//     Icons.map,
//     Icons.calendar_month,
//     Icons.payment,
//   ];

//   // Toggle the selected index
//   void toggleSelectedIndex(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   // Get the FAB position based on selectedIndex
//   FloatingActionButtonLocation getFabLocation() {
//     return SlidingFabLocationSample(context, selectedIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Scaffold(
//             backgroundColor: black,
//             body: Container(
//               color: deepBlue,
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: 200,
//                 color: yellowSoft,
//               ),
//             ),
//             // bottomNavigationBar: C_BottomNavBar(
//             //   currentIndex: selectedIndex,
//             //   onTap: toggleSelectedIndex,
//             // ),
//             bottomNavigationBar: BottomNavigation(
//               selectedIndex: selectedIndex,
//               onIconTap: toggleSelectedIndex,
//               icons: icons,
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () {},
//               backgroundColor: Colors.green,
//               child: Icon(icons[selectedIndex], color: Colors.white),
//               shape: CircleBorder(),
//               elevation: 5,
//             ),
//             floatingActionButtonLocation: getFabLocation(), // Dynamic FAB location
//           )
//         ],
//       ),
//     );
//   }
// }

// class SlidingFabLocationSample extends FloatingActionButtonLocation {
//   BuildContext context;
//   final int index;

//   SlidingFabLocationSample(this.context, this.index);

//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     final double fabY = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.contentTop - 100.0;
//     double width = MediaQuery.of(context).size.width;
//     double start = 0.25;
//     double space = 0.125 / 2;
//     double fabX;
//     switch (index) {
//       case 0: // Home
//         fabX = width * space;
//         break;
//       case 1: // map
//         fabX = width * ((start * 1) + space);
//         //fabX = width * (start / 2);
//         break;
//       case 2: // schedule
//         fabX = width * ((start * 2) + space);
//         break;
//       case 3: // payment/vehicle

//         fabX = width * ((start * 3) + space);
//         break;
//       default:
//         fabX = scaffoldGeometry.scaffoldSize.width / 2;
//     }
//     return Offset(fabX, fabY);
//   }
// }

// class BottomNavigation extends StatelessWidget {
//   final int selectedIndex;
//   final ValueChanged<int> onIconTap;
//   final List<IconData> icons;

//   BottomNavigation({
//     required this.selectedIndex,
//     required this.onIconTap,
//     required this.icons,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return BottomAppBar(
//       shape: CircularNotchedRectangle(),
//       notchMargin: 8.0,
//       padding: EdgeInsets.zero,
//       color: Colors.white,
//       child: Row(
//         children: [
//           for (int i = 0; i < icons.length; i++) Container(width: width * .25, child: _buildIcon(i)),
//         ],
//       ),
//     );
//   }

//   Widget _buildIcon(int index) {
//     return GestureDetector(
//       onTap: () => onIconTap(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (index != selectedIndex)
//             Icon(
//               icons[index],
//               color: index == selectedIndex ? Colors.green : Colors.black,
//             ),
//           Text(
//             _getLabel(index),
//             style: TextStyle(color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getLabel(int index) {
//     switch (index) {
//       case 0:
//         return "Home";
//       case 1:
//         return "Map";
//       case 2:
//         return "Schedule";
//       case 3:
//         return "Payment";
//       default:
//         return "";
//     }
//   }
// }
