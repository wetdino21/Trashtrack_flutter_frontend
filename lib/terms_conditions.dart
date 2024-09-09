import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Container(),
    );
  }
}

// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   final String email;

//   HomePage({required this.email});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Page'),
//       ),
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: fetchUserData(email), // Fetch data using the provided email
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator()); // Show loading indicator
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}')); // Handle error
//           } else if (snapshot.hasData) {
//             final data = snapshot.data!;
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text('First Name: ${data['cus_fname'] ?? ''}'),
//                   // Display other data as needed
//                 ],
//               ),
//             );
//           } else {
//             return Center(child: Text('No data available')); // Handle no data
//           }
//         },
//       ),
//     );
//   }
// }
