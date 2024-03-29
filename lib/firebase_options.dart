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
    apiKey: 'AIzaSyARI14Kbo4LEd_b2dkOVNlTqfd-Ob1yHWw',
    appId: '1:111451235080:web:de2afd958f68a291eb82bd',
    messagingSenderId: '111451235080',
    projectId: 'yulaf-app',
    authDomain: 'yulaf-app.firebaseapp.com',
    databaseURL: 'https://yulaf-app-default-rtdb.firebaseio.com',
    storageBucket: 'yulaf-app.appspot.com',
    measurementId: 'G-1H0MP06GCS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8fWCwlMmCEWdwRY_J39Oe2XIc38g8Uxc',
    appId: '1:111451235080:android:1b4737202fc2b612eb82bd',
    messagingSenderId: '111451235080',
    projectId: 'yulaf-app',
    databaseURL: 'https://yulaf-app-default-rtdb.firebaseio.com',
    storageBucket: 'yulaf-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFjyK5X1WMq7WbciRJgGtbAEg7MiW6XDc',
    appId: '1:111451235080:ios:807338ecd640dc21eb82bd',
    messagingSenderId: '111451235080',
    projectId: 'yulaf-app',
    databaseURL: 'https://yulaf-app-default-rtdb.firebaseio.com',
    storageBucket: 'yulaf-app.appspot.com',
    iosBundleId: 'com.example.socialWall',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFjyK5X1WMq7WbciRJgGtbAEg7MiW6XDc',
    appId: '1:111451235080:ios:807338ecd640dc21eb82bd',
    messagingSenderId: '111451235080',
    projectId: 'yulaf-app',
    databaseURL: 'https://yulaf-app-default-rtdb.firebaseio.com',
    storageBucket: 'yulaf-app.appspot.com',
    iosBundleId: 'com.example.socialWall',
  );
}
