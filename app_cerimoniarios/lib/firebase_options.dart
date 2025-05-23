// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyB3NosZxkEBa8_VWWbIwdPvWrBY_grZaoo',
    appId: '1:723236389926:web:d9ac245c9b8937713312e7',
    messagingSenderId: '723236389926',
    projectId: 'cerimoniarios',
    authDomain: 'cerimoniarios.firebaseapp.com',
    storageBucket: 'cerimoniarios.appspot.com', // ✅ CORRIGIDO
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZw-Tcpg6FSJVjqSGeQcivR6N98LgAP1Y',
    appId: '1:723236389926:android:f7969dd2387b9c483312e7',
    messagingSenderId: '723236389926',
    projectId: 'cerimoniarios',
    storageBucket: 'cerimoniarios.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBur6Jj4aPkt6Xuz_3wKgPlAlptUlTZ7wU',
    appId: '1:723236389926:ios:73d0cba309151bb33312e7',
    messagingSenderId: '723236389926',
    projectId: 'cerimoniarios',
    storageBucket: 'cerimoniarios.firebasestorage.app',
    iosBundleId: 'com.example.appCerimoniarios',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBur6Jj4aPkt6Xuz_3wKgPlAlptUlTZ7wU',
    appId: '1:723236389926:ios:73d0cba309151bb33312e7',
    messagingSenderId: '723236389926',
    projectId: 'cerimoniarios',
    storageBucket: 'cerimoniarios.firebasestorage.app',
    iosBundleId: 'com.example.appCerimoniarios',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3NosZxkEBa8_VWWbIwdPvWrBY_grZaoo',
    appId: '1:723236389926:web:8bf3594b2213f8d03312e7',
    messagingSenderId: '723236389926',
    projectId: 'cerimoniarios',
    authDomain: 'cerimoniarios.firebaseapp.com',
    storageBucket: 'cerimoniarios.firebasestorage.app',
  );
}
