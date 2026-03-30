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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBUzWteFj9qVkFsGOOJMfoCiRKMpOxYC-Y',
    appId: '1:158422290745:web:c516c76a5df1aa49a018e8',
    messagingSenderId: '158422290745',
    projectId: 'omni-service-hub',
    authDomain: 'omni-service-hub.firebaseapp.com',
    storageBucket: 'omni-service-hub.firebasestorage.app',
    measurementId: 'G-D0PXBNKNVG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3fOcT3doA1SuQqQyev5LRkpGmbY0rv8E',
    appId: '1:158422290745:android:23a7035123d8b5b5a018e8',
    messagingSenderId: '158422290745',
    projectId: 'omni-service-hub',
    storageBucket: 'omni-service-hub.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-CbL3iNKWjDnTyyc1S-CaOX3uAds_cCQ',
    appId: '1:158422290745:ios:340a2b02cad14f57a018e8',
    messagingSenderId: '158422290745',
    projectId: 'omni-service-hub',
    storageBucket: 'omni-service-hub.firebasestorage.app',
    iosBundleId: 'com.example.omniServiceHub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBUzWteFj9qVkFsGOOJMfoCiRKMpOxYC-Y',
    appId: '1:158422290745:web:02bd48ffbef5dc1fa018e8',
    messagingSenderId: '158422290745',
    projectId: 'omni-service-hub',
    authDomain: 'omni-service-hub.firebaseapp.com',
    storageBucket: 'omni-service-hub.firebasestorage.app',
    measurementId: 'G-1MFMNNPSLY',
  );

}