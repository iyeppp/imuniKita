// Generated for imunikita-dev project configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyCSm-qHBxG_bU45CTAFRw4-a5V76eKVc',
    appId: '1:219754293644:web:3bcc668cc1574760f8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    authDomain: 'imunikita-dev-f.firebaseapp.com',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRZ7cbVNp0V2TObjXlkvhZRQCa3vafnsk',
    appId: '1:219754293644:android:092c762cf358018cf8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFPggMoZ-IiXLe8VwXg3OYGPdXgSPSZ98',
    appId: '1:219754293644:ios:b8d6b4087ece42def8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
    iosBundleId: 'com.imunikita.app',
  );
}
