import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        throw UnsupportedError('Linux not supported');
      default:
        throw UnsupportedError('Unknown platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHz4fSTfIbSHqouNQXCthfkTmxzlHsbtA',
    appId: '1:119403543251:web:31094c2914fef5abbef226',
    messagingSenderId: '119403543251',
    projectId: 'voto2-cf279',
    authDomain: 'voto2-cf279.firebaseapp.com',
    storageBucket: 'voto2-cf279.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJw5khuytVsUNSuk9TYlrUa9QcApJ-VRk',
    appId: '1:119403543251:android:7210398c60178a41bef226',
    messagingSenderId: '119403543251',
    projectId: 'voto2-cf279',
    storageBucket: 'voto2-cf279.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAcsXmwx8lNW-boFRFWb7IPASwwo2LZgGs',
    appId: '1:119403543251:ios:8c26390187fc1d32bef226',
    messagingSenderId: '119403543251',
    projectId: 'voto2-cf279',
    storageBucket: 'voto2-cf279.firebasestorage.app',
    iosClientId: '119403543251-jd9knk0k7q55647jdsif0j05amurl56u.apps.googleusercontent.com',
    iosBundleId: 'com.example.appVotar',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcsXmwx8lNW-boFRFWb7IPASwwo2LZgGs',
    appId: '1:119403543251:ios:8c26390187fc1d32bef226',
    messagingSenderId: '119403543251',
    projectId: 'voto2-cf279',
    storageBucket: 'voto2-cf279.firebasestorage.app',
    iosClientId: '119403543251-jd9knk0k7q55647jdsif0j05amurl56u.apps.googleusercontent.com',
    iosBundleId: 'com.example.appVotar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHz4fSTfIbSHqouNQXCthfkTmxzlHsbtA',
    appId: '1:119403543251:web:0386f614628f42bbbef226',
    messagingSenderId: '119403543251',
    projectId: 'voto2-cf279',
    authDomain: 'voto2-cf279.firebaseapp.com',
    storageBucket: 'voto2-cf279.firebasestorage.app',
  );

}