import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  final String userId;
  late WebSocketChannel channel;
  final Function(String) onNotificationReceived;

  NotificationService(this.userId, this.onNotificationReceived) {
    // Establish WebSocket connection and pass userId as a query parameter
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.254.187:8080?userId=$userId'),
    );

    // Listen for notifications from the server
    channel.stream.listen((message) {
      final notification = json.decode(message);
      // Call the callback function to notify the UI
      onNotificationReceived(notification['notif_message']);
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  // Close WebSocket connection
  void closeConnection() {
    channel.sink.close();
  }
}



// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;

// class NotificationService {
//   final String userId;
//   late WebSocketChannel channel;

//   NotificationService(this.userId) {
//     // Establish WebSocket connection and pass userId as query parameter
//     channel = WebSocketChannel.connect(
//       Uri.parse('ws://192.168.254.187:8080?userId=$userId'),
//     );

//     // Listen for incoming notifications from the server
//     channel.stream.listen((message) {
//       // Handle the incoming notification message
//       print('Received notification: $message');
//     }, onError: (error) {
//       print('WebSocket error: $error');
//     }, onDone: () {
//       print('WebSocket connection closed');
//     });
//   }

//   // Send data to the WebSocket server if needed
//   void sendMessage(String message) {
//     channel.sink.add(message);
//   }

//   // Close the WebSocket connection
//   void closeConnection() {
//     channel.sink.close(status.goingAway);
//   }
// }
