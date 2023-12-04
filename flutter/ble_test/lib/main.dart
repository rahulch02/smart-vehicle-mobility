import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

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
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    startAdvertising();
  }

  Future<void> startAdvertising() async {
    try {
      await flutterBlue.startAdvertise(
        data: [0x02, 0x01, 0x06], // Example data, customize as needed
        scanResponse: [
          0x02,
          0x15,
          0x11,
          0x22,
          0x33,
          0x44,
          0x55,
          0x66,
          0x77,
          0x88,
          0x99,
          0xAA,
          0xBB,
          0xCC,
          0xDD,
          0xEE,
          0xFF
        ],
      );
    } catch (e) {
      print("Error starting advertising: $e");
    }
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
    flutterBlue.stopAdvertise();
    super.dispose();
  }
}
