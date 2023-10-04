import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fcm_app/message_screen.dart';
import 'package:http/http.dart' as http;

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void sendNotification(String title, String body, String token) async {
    var data = {
      'to': token.toString(),
      'priority': 'high',
      'notification': {'title': title, 'body': body},
      'data': {
        // 'id': id, // Send current user ID here
      }
    };
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAASa_QOv4:APA91bE5z_2nIJYPi3vog-Ja958f0og68EBVmZ0z7EZWWtNsMMVDndo2z1ibeduEnE6YWAQrsh1QGPxl0LhKlZFeQXo0toFFJN7EOEOOeXZ6zJ4mf6vtaOs6LDEFj7JnpeYWGv5wFl6f',
        });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        const AndroidNotificationChannel(
            '32132', 'High Importance Notifications',
            importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            androidNotificationChannel.id, androidNotificationChannel.name,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            channelDescription: 'Description of my channel');

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  void requestNotificationPermission() async {
    await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        sound: true,
        provisional: true);
  }

  void onTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      print(event.toString());
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MessageScreen()));
  }
}
