// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationScreen extends StatefulWidget {
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   Map payload = {};

//   @override
//   Widget build(BuildContext context) {
//     final data = ModalRoute.of(context)!.settings.arguments;
//     if (data is RemoteMessage) {
//       payload = data.data;
//     }
//     if (data is NotificationResponse) {
//       payload = jsonDecode(data.payload!);
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//       ),
//       body: SizedBox(
//         height: 48,
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundColor:
//                 Colors.blue, // You can set your notification icon here
//             child: Icon(
//               Icons.notifications,
//               color: Colors.white,
//             ),
//           ),
//           title: Text('Notification Title ${data.toString()}'),
//           subtitle: Text('Notification Description'),
//           onTap: () {},
//         ),
//       ),
//     );
//   }
// }
