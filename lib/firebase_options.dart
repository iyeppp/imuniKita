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
    apiKey: 'AIzaSyDevKeyForImuniKitaWebProject12345',
    appId: '1:1234567890:web:imunikita123456',
    messagingSenderId: '1234567890',
    projectId: 'imunikita-dev',
    authDomain: 'imunikita-dev.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDevKeyForImuniKitaAndroid12345',
    appId: '1:1234567890:android:imunikita123456',
    messagingSenderId: '1234567890',
    projectId: 'imunikita-dev',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDevKeyForImuniKitaIos1234567',
    appId: '1:1234567890:ios:imunikita123456',
    messagingSenderId: '1234567890',
    projectId: 'imunikita-dev',
    iosBundleId: 'com.imunikita.app',
  );
}
