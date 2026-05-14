import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyA136qxeH9CbFtmNDuQ6dQbA0YEeY15iUg',
      appId: '1:786561093977:web:aa048fa4e78ecd9d717c48',
      messagingSenderId: '786561093977',
      projectId: 'captureyourlife-4f28d',
      storageBucket: 'captureyourlife-4f28d.firebasestorage.app',
      // iosBundleId: 'com.example.captureYourLife',
      // androidPackageName: 'com.example.capture_your_life',
    );
  }
}
