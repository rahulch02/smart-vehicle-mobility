// import 'dart:async';
import 'dart:io';

// import 'package:beacon_scanner/beacon_scanner.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart' as fb;
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
      home: BluetoothScanner(),
    );
  }
}

class BluetoothScanner extends StatefulWidget {
  @override
  _BluetoothScannerState createState() => _BluetoothScannerState();
}

class _BluetoothScannerState extends State<BluetoothScanner> {
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  // final streamRanging = flutterBeacon;8
  final List<Region> regions = [];
  List<Beacon> beacons = [];

  @override
  void initState() {
    super.initState();
    startScanning();
    startMonitoring();
  }

  void startMonitoring() {
    flutterBeacon.monitoring(regions).listen((event) {
      setState(() {
        beacons.add(Beacon(
            proximityUUID: event.region.proximityUUID!,
            major: event.region.major!,
            minor: event.region.minor!,
            accuracy: 0.9));
      });
    });
  }

  void startScanning() {
    setState(() {
      if (Platform.isIOS) {
        // iOS platform, at least set identifier and proximityUUID for region scanning
        regions.add(Region(
          identifier: 'com.example.myDeviceRegion',
          proximityUUID: '39ED98FF-2900-441A-802F-9C398FC199D2',
          major: 1,
          minor: 100,
        ));
      } else {
        // Android platform, it can ranging out of beacon that filter all of Proximity UUID
        regions.add(Region(
          identifier: 'com.example.myDeviceRegion',
          proximityUUID: '39ED98FF-2900-441A-802F-9C398FC199D2',
          major: 1,
          minor: 100,
        ));
      }
    });

    // if (streamRanging != null) {
    //   if (streamRanging.isPaused) {
    //     streamRanging.resume();
    //     return;
    //   }
    // }

    // flutterBlue.startScan(timeout: const Duration(seconds: 20));

    // flutterBlue.scanResults.listen((List<ScanResult> results) {
    //   // Update the list of scan results
    //   setState(() {
    //     scanResults = results;
    //   });

    //   for (ScanResult result in results) {
    //     // Extract and process the advertising data
    //     Map<int, List<int>> data = result.advertisementData.manufacturerData;
    //     print(result.advertisementData);
    //     if (data.containsKey(0x02)) {
    //       // Example: Extracting data sent in the form of scanResponse
    //       List<int> scanResponseData = data[0x02]!;
    //       print("Scan Response Data: $scanResponseData");
    //     }

    //     // // Example: Extracting data sent in the form of data
    //     // List<int> rawData = result.advertisementData.manufacturerData.;
    //     // print("Raw Data: $rawData");
    //   }
    // });

    flutterBeacon.ranging(regions).listen((result) {
      setState(() {
        beacons = result.beacons;
      });
    });

    // beaconScanner.ranging(regions).listen((ScanResult result) {
    //   // result contains a list of beacons
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Container(
        height: height,
        child: ListView(children: <Widget>[
          ...beacons.map((element) {
            return ListTile(
              title: Text(
                element.proximityUUID.toString(),
                style: TextStyle(color: Colors.black),
              ),
              subtitle: Text(element.macAddress.toString()),
              onTap: () {
                // Handle tapping on a device, if needed
              },
            );
          }).toList()
        ]),
      ),
    );
  }

  @override
  void dispose() {
    flutterBeacon.close;
    super.dispose();
  }
}

// import 'dart:async';
// import 'dart:io' show Platform;
// import 'dart:math';
// import 'package:intl/intl.dart';
// import 'package:beacons_plugin/beacons_plugin.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await [
//     Permission.bluetoothScan,
//     Permission.bluetoothConnect,
//     Permission.bluetoothAdvertise,
//   ].request();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       new FlutterLocalNotificationsPlugin();

//   String _tag = "Beacons Plugin";
//   String _beaconResult = 'Not Scanned Yet.';
//   int _nrMessagesReceived = 0;
//   var isRunning = false;
//   List<String> _results = [];
//   bool _isInForeground = true;

//   final ScrollController _scrollController = ScrollController();

//   final StreamController<String> beaconEventsController =
//       StreamController<String>.broadcast();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     initPlatformState();

//     // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//     var initializationSettingsAndroid =
//         new AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettingsIOS =
//         DarwinInitializationSettings(onDidReceiveLocalNotification: null);
//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: null);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     _isInForeground = state == AppLifecycleState.resumed;
//   }

//   @override
//   void dispose() {
//     beaconEventsController.close();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     if (Platform.isAndroid) {
//       //Prominent disclosure
//       await BeaconsPlugin.setDisclosureDialogMessage(
//           title: "Background Locations",
//           message:
//               "[This app] collects location data to enable [feature], [feature], & [feature] even when the app is closed or not in use");

//       //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
//       //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
//     }

//     if (Platform.isAndroid) {
//       BeaconsPlugin.channel.setMethodCallHandler((call) async {
//         print("Method: ${call.method}");
//         if (call.method == 'scannerReady') {
//           _showNotification("Beacons monitoring started..");
//           await BeaconsPlugin.startMonitoring();
//           setState(() {
//             isRunning = true;
//           });
//         } else if (call.method == 'isPermissionDialogShown') {
//           _showNotification(
//               "Prominent disclosure message is shown to the user!");
//         }
//       });
//     } else if (Platform.isIOS) {
//       _showNotification("Beacons monitoring started..");
//       await BeaconsPlugin.startMonitoring();
//       setState(() {
//         isRunning = true;
//       });
//     }

//     BeaconsPlugin.listenToBeacons(beaconEventsController);

//     await BeaconsPlugin.addRegion(
//         "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
//     await BeaconsPlugin.addRegion(
//         "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

//     BeaconsPlugin.addBeaconLayoutForAndroid(
//         "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
//     BeaconsPlugin.addBeaconLayoutForAndroid(
//         "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");

//     BeaconsPlugin.setForegroundScanPeriodForAndroid(
//         foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

//     BeaconsPlugin.setBackgroundScanPeriodForAndroid(
//         backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

//     beaconEventsController.stream.listen(
//         (data) {
//           if (data.isNotEmpty && isRunning) {
//             setState(() {
//               _beaconResult = data;
//               _results.add(_beaconResult);
//               _nrMessagesReceived++;
//             });

//             if (!_isInForeground) {
//               _showNotification("Beacons DataReceived: " + data);
//             }

//             print("Beacons DataReceived: " + data);
//           }
//         },
//         onDone: () {},
//         onError: (error) {
//           print("Error: $error");
//         });

//     //Send 'true' to run in background
//     await BeaconsPlugin.runInBackground(true);

//     if (!mounted) return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Monitoring Beacons'),
//         ),
//         body: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Center(
//                   child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('Total Results: $_nrMessagesReceived',
//                     style: Theme.of(context).textTheme.headline4?.copyWith(
//                           fontSize: 14,
//                           color: const Color(0xFF22369C),
//                           fontWeight: FontWeight.bold,
//                         )),
//               )),
//               Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (isRunning) {
//                       await BeaconsPlugin.stopMonitoring();
//                     } else {
//                       initPlatformState();
//                       await BeaconsPlugin.startMonitoring();
//                     }
//                     setState(() {
//                       isRunning = !isRunning;
//                     });
//                   },
//                   child: Text(isRunning ? 'Stop Scanning' : 'Start Scanning',
//                       style: TextStyle(fontSize: 20)),
//                 ),
//               ),
//               Visibility(
//                 visible: _results.isNotEmpty,
//                 child: Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       setState(() {
//                         _nrMessagesReceived = 0;
//                         _results.clear();
//                       });
//                     },
//                     child:
//                         Text("Clear Results", style: TextStyle(fontSize: 20)),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 20.0,
//               ),
//               Expanded(child: _buildResultsList())
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showNotification(String subtitle) {
//     var rng = new Random();
//     Future.delayed(Duration(seconds: 5)).then((result) async {
//       var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//           'your channel id', 'your channel name',
//           importance: Importance.high,
//           priority: Priority.high,
//           ticker: 'ticker');
//       var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//       var platformChannelSpecifics = NotificationDetails(
//           android: androidPlatformChannelSpecifics,
//           iOS: iOSPlatformChannelSpecifics);
//       await flutterLocalNotificationsPlugin.show(
//           rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
//           payload: 'item x');
//     });
//   }

//   Widget _buildResultsList() {
//     return Scrollbar(
//       thumbVisibility: true,
//       controller: _scrollController,
//       child: ListView.separated(
//         shrinkWrap: true,
//         scrollDirection: Axis.vertical,
//         physics: ScrollPhysics(),
//         controller: _scrollController,
//         itemCount: _results.length,
//         separatorBuilder: (BuildContext context, int index) => Divider(
//           height: 1,
//           color: Colors.black,
//         ),
//         itemBuilder: (context, index) {
//           DateTime now = DateTime.now();
//           String formattedDate =
//               DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(now);
//           final item = ListTile(
//               title: Text(
//                 "Time: $formattedDate\n${_results[index]}",
//                 textAlign: TextAlign.justify,
//                 style: Theme.of(context).textTheme.headline4?.copyWith(
//                       fontSize: 14,
//                       color: const Color(0xFF1A1B26),
//                       fontWeight: FontWeight.normal,
//                     ),
//               ),
//               onTap: () {});
//           return item;
//         },
//       ),
//     );
//   }
// }
