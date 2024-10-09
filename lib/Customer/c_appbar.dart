import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/api_network.dart';

import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'dart:typed_data'; // for Uint8List
import 'package:trashtrack/user_hive_data.dart';
// import 'package:trashtrack/websocket.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

//String baseUrl = globalUrl();
//String? baseUrl = globalUrl().getBaseUrl();

class C_CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  //C_CustomAppBar({required this.title});
  C_CustomAppBar({required this.title, Key? key}) : super(key: key);

  @override
  C_CustomAppBarState createState() => C_CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class C_CustomAppBarState extends State<C_CustomAppBar> {
  Uint8List? imageBytes;
  UserModel? userModel;
  int totalNotif = 0;
  late WebSocketChannel channel;

  //live notif
  //late NotificationService notificationService;
  List<String> notifications = []; // List to hold received notifications
  // WebSocketChannel channel = WebSocketChannel.connect(
  //   Uri.parse('ws://192.168.254.187:8080'),
  // );

  @override
  void initState() {
    super.initState();
    loadProfileNotif();
     connectWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); // Access provider here
    // connectWebSocket();
  }

  @override
  void dispose() {
    channel.sink.close();
    //notificationService.closeConnection();
    super.dispose();
  }
  // @override
  // void dispose() {
  //   // channel.sink.close();

  //   print('notiff disposeeee');
  //   super.dispose();
  // }

  Future<void> connectWebSocket() async {
    String baseUrl = globalUrl();
    //String? baseUrl = globalUrl().getBaseUrl();

    String ipAddress = extractIpAddress(baseUrl);
    //192.168.254.187
    final data = await userDataFromHive();
    if (data['id'] != null) {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://${ipAddress}:8080?userId=${data['id'].toString()}'),
        //Uri.parse('ws://192.168.254.187:8080?userId=${data['id'].toString()}'),
      );
      channel.stream.listen((message) {
        final notification = json.decode(message);
        if (notification.containsKey('unread_count')) {
          var unreadCount = notification['unread_count'];
          setState(() {
            //totalNotif = unreadCount; //same output
            totalNotif = int.tryParse(unreadCount) ?? 0;
          });
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } else {
      print('Failed to retrieve user ID for WebSocket connection');
    }
  }

  Future<void> loadProfileNotif() async {
    final data = await userDataFromHive();
    setState(() {
      imageBytes = data['profile'];
    });

    final box = await Hive.openBox('mybox');
    if (box.get('notif_count') == null) {
      showErrorSnackBar(context, '1111111111 ');
    } else {
      setState(() {
        totalNotif = box.get('notif_count');
      });
      //showErrorSnackBar(context, totalNotif.toString());
    }

    //  String? base64Image = await fetchProfile(context);
    //   if (base64Image != null) {
    //     setState(() {
    //       imageBytes = base64Decode(base64Image);
    //     });
    //   }

    // await box.close();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: deepGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.title,
        style: TextStyle(
          color: white,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Stack(
          children: [
            // ListView.builder(
            //   itemCount: notifications.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       title: Text(notifications[index]),
            //     );
            //   },
            // ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'c_notification');
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                margin: EdgeInsets.all(5),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            //notif counts
            if (totalNotif > 0)
              Positioned(
                  right: 0,
                  child: Container(
                      height: 20,
                      width: 20,
                      child: Container(
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(100)),
                        child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              totalNotif >= 99 ? '99+' : '${totalNotif}',
                              style: TextStyle(
                                  color: white,
                                  fontSize: totalNotif <= 9
                                      ? 12
                                      : totalNotif <= 99
                                          ? 10
                                          : 8),
                            )),
                      )))
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'c_profile');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => C_ProfileScreen()),
            // ).then((value) {
            //   if (value == true) {
            //     loadProfileImage();
            //   }
            // });
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: deepPurple,
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: deepPurple),
            ),
            //child: imageBytes != null
            child: userModel!.profile != null
                ? CircleAvatar(
                    backgroundImage: MemoryImage(userModel!.profile!),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                  ),
          ),
        ),
        SizedBox(
          width: 15,
        )
      ],
      // leading: SizedBox.shrink(),
      // leadingWidth: 0,
    );
  }
}
