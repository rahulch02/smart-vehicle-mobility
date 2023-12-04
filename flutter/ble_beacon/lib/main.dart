import 'package:ble_beacon/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterBeacon.initializeScanning;

  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ].request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothAdvertiser(),
    );
  }
}

class BluetoothAdvertiser extends StatefulWidget {
  @override
  _BluetoothAdvertiserState createState() => _BluetoothAdvertiserState();
}

class _BluetoothAdvertiserState extends State<BluetoothAdvertiser> {
  static const String uuid = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const int majorId = 1;
  static const int minorId = 100;
  static const int transmissionPower = -59;
  static const String identifier = 'com.example.myDeviceRegion';
  // static const AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  // static const String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const int manufacturerId = 0x004C; // 0x0118 for alt beacon
  static const List<int> extraData = [100];
  // FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    startAdvertising();
  }

  startAdvertising() {
    // try {
    //   await flutterBlue.startAdvertise(
    //     data: [0x02, 0x01, 0x06], // Example data, customize as needed
    //     scanResponse: [
    //       0x02,
    //       0x15,
    //       0x11,
    //       0x22,
    //       0x33,
    //       0x44,
    //       0x55,
    //       0x66,
    //       0x77,
    //       0x88,
    //       0x99,
    //       0xAA,
    //       0xBB,
    //       0xCC,
    //       0xDD,
    //       0xEE,
    //       0xFF
    //     ],
    //   );
    // } catch (e) {
    //   print("Error starting advertising: $e");
    // }

    flutterBeacon.startBroadcast(BeaconBroadcast(
        proximityUUID: uuid,
        major: majorId,
        minor: minorId,
        identifier: identifier));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Advertiser'),
      ),
      body: Center(
        child: Text('Bluetooth advertising started.'),
      ),
    );
  }

  @override
  void dispose() {
    // flutterBlue.stopAdvertise();
    flutterBeacon.stopBroadcast();
    super.dispose();
  }
}
