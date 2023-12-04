import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEController extends GetxController {
  FlutterBlue bleScan = FlutterBlue.instance;

  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        bleScan.startScan(timeout: const Duration(seconds: 10));
        bleScan.stopScan();
      }
    }
  }

  Stream<List<ScanResult>> get scanResults => bleScan.scanResults;
}
