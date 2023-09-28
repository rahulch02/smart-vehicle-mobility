import 'dart:math';

import 'package:flutter/material.dart';

// import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final messaging = FirebaseMessaging.instance;

  // final settings =
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(const MyApp());
}

class User {
  User(
      {this.token = '',
      this.name = '',
      this.longitude = 0.0,
      this.latitude = 0.0,
      this.speed = 0.0,
      this.direction = 0.0});

  User.fromJson(Map<String, Object?> json)
      : this(
            token: json['token']! as String,
            name: json['name']! as String,
            latitude: json['latitude']! as double,
            longitude: json['longitude']! as double,
            direction: json['direction']! as double,
            speed: json['speed']! as double);

  late String token;
  late String name;
  late double longitude;
  late double latitude;
  late double speed;
  late double direction;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
      'speed': speed,
      'direction': direction,
      'token': token
    };
  }
}

enum userQuery { name, latitude, longitude, speed, direction }

extension on Query<User> {
  Query<User> queryBy(userQuery query) {
    switch (query) {
      case userQuery.name:
        return orderBy('name', descending: true);
      case userQuery.latitude:
        return orderBy('latitude', descending: true);
      case userQuery.longitude:
        return orderBy('longitude', descending: true);
      case userQuery.speed:
        return orderBy('speed', descending: true);
      case userQuery.direction:
        return orderBy('direction', descending: true);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User curUser = User();
  double radius = 50;

  Location _location = Location();
  userQuery query = userQuery.name;

  final String id = 'Rahul';
  String token = '';

  final usersRef =
      FirebaseFirestore.instance.collection('location').withConverter<User>(
            fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
            toFirestore: (user, _) => User().toJson(),
          );

  List<String> _proximity = List.empty();

  @override
  void initState() {
    super.initState();

    _location.changeSettings(
      interval: 1,
    );

    getDeviceToken();
    usersRef.doc(id).set(User(token: token));
    beginLiveLocation();
    hearCollisions();
  }

  void beginLiveLocation() {
    _location.onLocationChanged.listen((LocationData curLocation) {
      usersRef.doc(id).update(User(
              name: 'Rahul',
              latitude: curLocation.latitude!,
              longitude: curLocation.longitude!,
              speed: curLocation.speed!,
              direction: curLocation.heading!,
              token: token)
          .toJson());

      curUser = User(
          name: 'Rahul',
          latitude: curLocation.latitude!,
          longitude: curLocation.longitude!,
          speed: curLocation.speed!,
          direction: curLocation.heading!,
          token: token);
    });
  }

  void getDeviceToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value!;
      });
    });
  }

  void hearCollisions() {
    usersRef.queryBy(query).snapshots().listen((event) {
      List<String> prox = [];
      event.docs.forEach((element) {
        double dist = 1.609344 *
            3963.0 *
            acos((sin(curUser.latitude * pi / 180) *
                    sin(element['latitude'] * pi / 180)) +
                cos(curUser.latitude * pi / 180) *
                    cos(element['latitude'] * pi / 180) *
                    cos((element['longitude'] - curUser.longitude) * pi / 180));
        if (dist < radius && element['id'] != id) {
          prox.add(element['id']);
        }
      });
      setState(() {
        _proximity = prox;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<QuerySnapshot<User>>(
            stream: usersRef.queryBy(query).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;

              return ListView.builder(
                itemCount: data.size,
                itemBuilder: (context, index) {
                  return !_proximity
                          .any((element) => element == data.docs[index]['id'])
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.docs[index]['name'].toString()),
                            Text('Coordinates: ' +
                                data.docs[index]['latitude'].toString() +
                                ', ' +
                                data.docs[index]['longitude'].toString()),
                            Text('Speed: ' +
                                data.docs[index]['speed'].toString() +
                                '(m/s)' +
                                '; Direction: ' +
                                data.docs[index]['direction'].toString()),
                            Column(
                              children: [
                                ElevatedButton(
                                    onPressed: () {}, child: Text('Notify')),
                                data.docs[index]['id'] == id
                                    ? ElevatedButton(
                                        onPressed: () {}, child: Text('Begin'))
                                    : SizedBox(),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            )
                          ],
                        )
                      : SizedBox();
                },
              );
            },
          ),
          StreamBuilder<QuerySnapshot<User>>(
            stream: usersRef.queryBy(query).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;

              return ListView.builder(
                itemCount: data.size,
                itemBuilder: (context, index) {
                  return _proximity
                          .any((element) => element == data.docs[index]['id'])
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.docs[index]['name'].toString()),
                            Text('Coordinates: ' +
                                data.docs[index]['latitude'].toString() +
                                ', ' +
                                data.docs[index]['longitude'].toString()),
                            Text('Speed: ' +
                                data.docs[index]['speed'].toString() +
                                '(m/s)' +
                                '; Direction: ' +
                                data.docs[index]['direction'].toString()),
                            data.docs[index].id == id
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: Text('Notify')),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: Text('Begin')),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 30,
                            )
                          ],
                        )
                      : SizedBox();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
