import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

import 'notifications.dart';

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

// enum userQuery { name, latitude, longitude, speed, direction }

// extension on Query<User> {
//   Query<User> queryBy(userQuery query) {
//     switch (query) {
//       case userQuery.name:
//         return orderBy('name', descending: true);
//       case userQuery.latitude:
//         return orderBy('latitude', descending: true);
//       case userQuery.longitude:
//         return orderBy('longitude', descending: true);
//       case userQuery.speed:
//         return orderBy('speed', descending: true);
//       case userQuery.direction:
//         return orderBy('direction', descending: true);
//     }
//   }
// }

class MyHomePage extends StatefulWidget {
  final String userName;
  MyHomePage({super.key, this.userName = ''});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User curUser = User();
  double radius = 50;

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> collision;
  late StreamSubscription<LocationData> locationChange;

  Location _location = Location();
  NotificationServices notificationServices = NotificationServices();
  // userQuery query = userQuery.name;
  final fire_auth.FirebaseAuth auth = fire_auth.FirebaseAuth.instance;

  String id = '';
  String token = '';

  final usersRef = FirebaseFirestore.instance.collection('location');
  // .withConverter<User>(
  //       fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
  //       toFirestore: (user, _) => User().toJson(),
  //     );

  List<String> _proximity = List.empty();

  @override
  void dispose() {
    collision.cancel();
    locationChange.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _location.changeSettings(
      interval: 0,
    );

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);

    setup();
  }

  void setup() async {
    getDeviceToken();
    getCurrentUserId();

    final docRef = usersRef.where('id', isEqualTo: id).get();
    await docRef.then((value) {
      if (value.docs.isEmpty && widget.userName.isNotEmpty) {
        usersRef.doc(id).set(User(name: widget.userName, token: token).toJson(),
            SetOptions(merge: true));
        print('Added Doc with ID: ' + id + ' and name: ' + widget.userName);
      } else {
        usersRef.doc(id).update({'token': token});
        print('updated doc with ID: ' + id);
      }
    });

    beginLiveLocation();
    hearCollisions();
  }

  void beginLiveLocation() {
    print('ID before location update: ' + id);
    locationChange =
        _location.onLocationChanged.listen((LocationData curLocation) {
      usersRef.doc(id).set({
        'latitude': curLocation.latitude!,
        'longitude': curLocation.longitude!,
        'speed': curLocation.speed!,
        'direction': curLocation.heading!,
      }, SetOptions(merge: true));

      curUser = User(
          latitude: curLocation.latitude!,
          longitude: curLocation.longitude!,
          speed: curLocation.speed!,
          direction: curLocation.heading!,
          token: token);
    });
  }

  void getCurrentUserId() {
    final fire_auth.User? user = auth.currentUser;
    final uid = user!.uid;
    setState(() {
      id = uid;
    });
    print('ID function returns' + id);
  }

  void getDeviceToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value!;
      });
    });
    print('Token Function returns' + token);
  }

  void hearCollisions() {
    collision = usersRef.snapshots().listen((event) {
      List<String> prox = [];
      event.docs.forEach((element) {
        double dist = 1000 *
            1.609344 *
            3963.0 *
            acos((sin(curUser.latitude * pi / 180) *
                    sin(element['latitude'] * pi / 180)) +
                cos(curUser.latitude * pi / 180) *
                    cos(element['latitude'] * pi / 180) *
                    cos((element['longitude'] - curUser.longitude) * pi / 180));
        if (dist < radius && element.id != id) {
          prox.add(element.id);
          if (!_proximity.any((e) => e == element.id)) {
            NotificationServices().sendNotification(
                'Warning, Proximity Detected',
                'Tap to view More',
                element['token']);
          }
        }
      });
      setState(() {
        _proximity = prox;
      });
    });
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    AppBar appBar = AppBar(
      centerTitle: true,
      title: const Text(
        'Location Proximity Tracker',
      ),
      actions: [
        DropdownButton<String>(
            padding: const EdgeInsets.only(right: 10),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: const [
              DropdownMenuItem(
                value: '1',
                child: Text('Sign out'),
              )
            ],
            onChanged: (String? _) {
              signOut();
            })
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: Container(
        width: width,
        height: height - appBar.preferredSize.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border:
                      Border(right: BorderSide(color: Colors.black, width: 1))),
              width: width / 2,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: usersRef.snapshots(),
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
                              .any((element) => element == data.docs[index].id)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.docs[index]['name'].toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
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
                                        onPressed: () {},
                                        child: Text('Notify')),
                                    data.docs[index].id == id
                                        ? ElevatedButton(
                                            onPressed: () {},
                                            child: Text('Begin'))
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
            ),
            Container(
              width: width / 2,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: usersRef.snapshots(),
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
                              .any((element) => element == data.docs[index].id)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.docs[index]['name'].toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
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
            ),
          ],
        ),
      ),
    );
  }
}
