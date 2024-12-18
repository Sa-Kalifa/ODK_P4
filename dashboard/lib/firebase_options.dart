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
    apiKey: 'AIzaSyDIvgAc1Y8OGEO0ErHvHYRkejBUbJ_irm8',
    appId: '1:376188796304:web:586b5608bfaa4a5efc8715',
    messagingSenderId: '376188796304',
    projectId: 'projetm-b6fae',
    authDomain: 'projetm-b6fae.firebaseapp.com',
    storageBucket: 'projetm-b6fae.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVuT0VXpgHLhFPaqii3vC4JYPq6k90iB0',
    appId: '1:376188796304:ios:69c2708bae1d91b0fc8715',
    messagingSenderId: '376188796304',
    projectId: 'projetm-b6fae',
    storageBucket: 'projetm-b6fae.appspot.com',
    iosBundleId: 'com.example.dashboard',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVuT0VXpgHLhFPaqii3vC4JYPq6k90iB0',
    appId: '1:376188796304:ios:69c2708bae1d91b0fc8715',
    messagingSenderId: '376188796304',
    projectId: 'projetm-b6fae',
    storageBucket: 'projetm-b6fae.appspot.com',
    iosBundleId: 'com.example.dashboard',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwbdXg255xetptB0-2GRsYc_Wg1xEjuMY',
    appId: '1:376188796304:android:c152b7c146ef7f3efc8715',
    messagingSenderId: '376188796304',
    projectId: 'projetm-b6fae',
    storageBucket: 'projetm-b6fae.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDIvgAc1Y8OGEO0ErHvHYRkejBUbJ_irm8',
    appId: '1:376188796304:web:4ffde7470e80e8f2fc8715',
    messagingSenderId: '376188796304',
    projectId: 'projetm-b6fae',
    authDomain: 'projetm-b6fae.firebaseapp.com',
    storageBucket: 'projetm-b6fae.appspot.com',
  );

}