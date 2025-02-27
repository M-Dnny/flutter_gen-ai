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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA7Sz5xZWtmgYH5E56wVJUDEmhCLrODab0',
    appId: '1:1046184094159:web:3600b6a36f45d327b28aba',
    messagingSenderId: '1046184094159',
    projectId: 'flutter-genai-demo',
    authDomain: 'flutter-genai-demo.firebaseapp.com',
    storageBucket: 'flutter-genai-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGqYm6JNlw7m-ifBIdD5aEebb3GiWN9wk',
    appId: '1:1046184094159:android:789e332c56e6f666b28aba',
    messagingSenderId: '1046184094159',
    projectId: 'flutter-genai-demo',
    storageBucket: 'flutter-genai-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAh8kjlx0YDnvtZ5L_Oyed4i4330zZKhuM',
    appId: '1:1046184094159:ios:d2359120941b0564b28aba',
    messagingSenderId: '1046184094159',
    projectId: 'flutter-genai-demo',
    storageBucket: 'flutter-genai-demo.appspot.com',
    iosBundleId: 'com.example.geminiDemo',
  );
}
