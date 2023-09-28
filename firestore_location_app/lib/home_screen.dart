import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'notifications.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String token = '';
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    // notificationServices.getDeviceToken().then((value) {
    //   print('device token' + value);
    //   setState(() {
    //     token = value;
    //   });
    // });
    // notificationServices.onTokenRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      child: const Text('Send Notification'),
      onPressed: () {
        notificationServices.getDeviceToken().then((value) async {
          var data = {
            'to': value.toString(),
            'priority': 'high',
            'notification': {'title': 'test', 'body': 'testing out'},
            'data': {
              'id': '23123', // Send current user ID here
            }
          };
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              body: jsonEncode(data),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'key=AAAASa_QOv4:APA91bE5z_2nIJYPi3vog-Ja958f0og68EBVmZ0z7EZWWtNsMMVDndo2z1ibeduEnE6YWAQrsh1QGPxl0LhKlZFeQXo0toFFJN7EOEOOeXZ6zJ4mf6vtaOs6LDEFj7JnpeYWGv5wFl6f',
              });
        });
      },
    )));
  }
}
