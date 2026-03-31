// Firebase configuration for DriverAssist
// TODO: Replace ALL placeholder values with real ones from Firebase Console:
//   https://console.firebase.google.com/project/driverassist-c9077
//
// Android: Download google-services.json → android/app/google-services.json
// iOS:     Download GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist
// Then re-run: flutterfire configure --project=driverassist-c9077

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // Web config (replace with your DriverAssist Firebase web app config if needed)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD81TKoyxisbbV3Z1PMz_Z12NFghW4tUkQ',
    appId: '1:750709740386:web:24edd061629407e6c2d23b',
    messagingSenderId: '750709740386',
    projectId: 'finance-tracker-patrick',
    authDomain: 'finance-tracker-patrick.firebaseapp.com',
    storageBucket: 'finance-tracker-patrick.firebasestorage.app',
  );

  // TODO: Replace with values from your google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'driverassist-c9077',
    storageBucket: 'driverassist-c9077.appspot.com',
  );

  // TODO: Replace with values from your GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'driverassist-c9077',
    storageBucket: 'driverassist-c9077.appspot.com',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'com.driverassist.app',
  );
}
