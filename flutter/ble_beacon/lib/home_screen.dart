import 'dart:async';
// import 'dart:io';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart' as fb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String uuid = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const int majorId = 1;
  static const int minorId = 100;
  static const int transmissionPower = -59;
  static const String identifier = 'com.example.myDeviceRegion';
  static const AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  static const String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const int manufacturerId = 0x004C; // 0x0118 for alt beacon
  static const List<int> extraData = [100];

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  bool _isAdvertising = false;
  BeaconStatus? _isTransmissionSupported;
  StreamSubscription<bool>? _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Beacon Broadcast'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Is transmission supported?',
                    style: Theme.of(context).textTheme.headline5),
                Text('$_isTransmissionSupported',
                    style: Theme.of(context).textTheme.subtitle1),
                Container(height: 16.0),
                Text('Has beacon started?',
                    style: Theme.of(context).textTheme.headline5),
                Text('$_isAdvertising',
                    style: Theme.of(context).textTheme.subtitle1),
                Container(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      beaconBroadcast
                          .setUUID(uuid)
                          .setMajorId(majorId)
                          .setMinorId(minorId)
                          // .setTransmissionPower(transmissionPower)
                          // .setAdvertiseMode(advertiseMode)
                          .setIdentifier(identifier)
                          .setLayout(
                              'm:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
                          .setManufacturerId(manufacturerId)
                          // .setExtraData(extraData)
                          .start();
                    },
                    child: const Text('START'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      beaconBroadcast.stop();
                    },
                    child: Text('STOP'),
                  ),
                ),
                Text('Beacon Data',
                    style: Theme.of(context).textTheme.headline5),
                Text('UUID: $uuid'),
                Text('Major id: $majorId'),
                Text('Minor id: $minorId'),
                Text('Tx Power: $transmissionPower'),
                Text('Advertise Mode Value: $advertiseMode'),
                Text('Identifier: $identifier'),
                Text('Layout: $layout'),
                Text('Manufacturer Id: $manufacturerId'),
                Text('Extra data: $extraData'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isAdvertisingSubscription?.cancel();
    super.dispose();
  }
}
