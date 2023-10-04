// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAoU2sJUhgrFYAiQrD4K-hQ1Qktj_qtRIQ',
    appId: '1:316482271998:web:0b33ae04f34e8852dd43af',
    messagingSenderId: '316482271998',
    projectId: 'cp-302',
    authDomain: 'cp-302.firebaseapp.com',
    databaseURL: 'https://cp-302-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp-302.appspot.com',
    measurementId: 'G-05SCC7KD1E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEe2N6vITUkIymdvusQgwbZQg3bWbSW4Y',
    appId: '1:316482271998:android:e0ce9ac6abc31601dd43af',
    messagingSenderId: '316482271998',
    projectId: 'cp-302',
    databaseURL: 'https://cp-302-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp-302.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCR7dt80_Pvr68flYDLCzU3TkZ0Xh-ueX4',
    appId: '1:316482271998:ios:f467a30c40d4e88cdd43af',
    messagingSenderId: '316482271998',
    projectId: 'cp-302',
    databaseURL: 'https://cp-302-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp-302.appspot.com',
    iosBundleId: 'com.example.testApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCR7dt80_Pvr68flYDLCzU3TkZ0Xh-ueX4',
    appId: '1:316482271998:ios:598558b2222fd8d9dd43af',
    messagingSenderId: '316482271998',
    projectId: 'cp-302',
    databaseURL: 'https://cp-302-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cp-302.appspot.com',
    iosBundleId: 'com.example.testApp.RunnerTests',
  );
}