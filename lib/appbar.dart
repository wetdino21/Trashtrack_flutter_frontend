import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trashtrack/API/api_network.dart';

import 'package:trashtrack/data_model.dart';
import 'package:trashtrack/styles.dart';
import 'dart:typed_data'; 
import 'package:trashtrack/user_hive_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class C_CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  C_CustomAppBar({required this.title, Key? key}) : super(key: key);

  @override
  C_CustomAppBarState createState() => C_CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class C_CustomAppBarState extends State<C_CustomAppBar> {
  final AudioService _audioService = AudioService(); 
  String user = 'customer';
  Uint8List? imageBytes;
  UserModel? userModel;
  int totalNotif = 0;
  WebSocketChannel? channel;

  List<String> notifications = []; 

  @override
  void initState() {
    super.initState();
    loadProfileNotif();
    connectWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = Provider.of<UserModel>(context); 

    if (userModel!.notifCount != null) {
      totalNotif = userModel!.notifCount!;
    }

  }

  @override
  void dispose() {
    if (channel != null) channel!.sink.close();
    _audioService.dispose();
    //notificationService.closeConnection();
    super.dispose();
  }

  Future<void> _playSound() async {
    await _audioService.playNotifSound(); // Use the service to play sound
  }

  Future<void> connectWebSocket() async {
    String baseUrl = globalUrl();

    String ipAddress = extractIpAddress(baseUrl);
    //192.168.254.187
    final data = await userDataFromHive();
    if (!mounted) return;

    if (data.isEmpty) return;
    if (data['user'] != null) {
      setState(() {
        user = data['user'];
      });

      if (data['user'] == 'customer') {
        if (data['id'] != null) {
          channel = WebSocketChannel.connect(
            Uri.parse('ws://${ipAddress}:8080?userId=${data['id'].toString()}'),
          );
          channel!.stream.listen((message) {
            final notification = json.decode(message);
            if (notification.containsKey('unread_count')) {
              var unreadCount = notification['unread_count'];
              setState(() {
                //totalNotif = unreadCount; //same output
                totalNotif = int.tryParse(unreadCount) ?? 0;
                userModel!.setUserData(newNotifCount: totalNotif);
                _playSound();
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
    }
  }

  Future<void> loadProfileNotif() async {
    final data = await userDataFromHive();
    setState(() {
      imageBytes = data['profile'];
    });
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
        if (user == 'customer')
          Tooltip(
            message: 'Notification',
            child: Stack(
              children: [
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
                      boxShadow: shadowLowColor,
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
                            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(100)),
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
          ),
        Tooltip(
          message: 'Profile',
          child: InkWell(
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
                boxShadow: shadowLowColor,
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
