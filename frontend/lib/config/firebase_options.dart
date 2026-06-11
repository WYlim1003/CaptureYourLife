import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA136qxeH9CbFtmNDuQ6dQbA0YEeY15iUg',
    authDomain: 'captureyourlife-4f28d.firebaseapp.com',
    projectId: 'captureyourlife-4f28d',
    storageBucket: 'captureyourlife-4f28d.firebasestorage.app',
    messagingSenderId: '786561093977',
    appId: '1:786561093977:web:aa048fa4e78ecd9d717c48',
  );

  // Android configuration — from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKFsSnhw3l3mlkGbCMgltLAs0vz1MnipM',
    authDomain: 'captureyourlife-4f28d.firebaseapp.com',
    projectId: 'captureyourlife-4f28d',
    storageBucket: 'captureyourlife-4f28d.firebasestorage.app',
    messagingSenderId: '786561093977',
    appId: '1:786561093977:android:e7d623ac48186c5a717c48',
  );

  // iOS configuration (optional)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA136qxeH9CbFtmNDuQ6dQbA0YEeY15iUg',
    authDomain: 'captureyourlife-4f28d.firebaseapp.com',
    projectId: 'captureyourlife-4f28d',
    storageBucket: 'captureyourlife-4f28d.firebasestorage.app',
    messagingSenderId: '786561093977',
    appId: '1:786561093977:web:aa048fa4e78ecd9d717c48',
    iosBundleId: 'com.wanyee.captureyourlife',
  );
}
