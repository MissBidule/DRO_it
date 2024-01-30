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
    apiKey: 'AIzaSyBz2sDTijQsDYjHsWhiDM1mVXPgzX33EYg',
    appId: '1:467709715979:web:072cc0741824adcf49c90e',
    messagingSenderId: '467709715979',
    projectId: 'droit-7920d',
    authDomain: 'droit-7920d.firebaseapp.com',
    databaseURL: 'https://droit-7920d-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'droit-7920d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_OTbXqRjUHLbfSsn4PLOUgNXCGPySHws',
    appId: '1:467709715979:android:a03417bb5870c6f849c90e',
    messagingSenderId: '467709715979',
    projectId: 'droit-7920d',
    databaseURL: 'https://droit-7920d-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'droit-7920d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-BUmMq1nFphexLeZgppm0l1CI8Udr_oQ',
    appId: '1:467709715979:ios:27d91cd32bd96fd649c90e',
    messagingSenderId: '467709715979',
    projectId: 'droit-7920d',
    databaseURL: 'https://droit-7920d-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'droit-7920d.appspot.com',
    iosBundleId: 'com.example.droitApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-BUmMq1nFphexLeZgppm0l1CI8Udr_oQ',
    appId: '1:467709715979:ios:bf9afddc4fcf5ab649c90e',
    messagingSenderId: '467709715979',
    projectId: 'droit-7920d',
    databaseURL: 'https://droit-7920d-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'droit-7920d.appspot.com',
    iosBundleId: 'com.example.droitApp.RunnerTests',
  );
}
