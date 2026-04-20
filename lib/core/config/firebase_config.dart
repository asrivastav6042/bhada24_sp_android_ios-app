import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  static FirebaseDatabase get database => FirebaseDatabase.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: 'AIzaSyBTtN4eYCdc1_IybkSi7EIU1br52rZy2To',
              authDomain: 'bhada24-96846.firebaseapp.com',
              projectId: 'bhada24-96846',
              storageBucket: 'bhada24-96846.firebasestorage.app',
              messagingSenderId: '200383906913',
              appId: '1:200383906913:web:48a06fb49870731f045620',
              measurementId: 'G-SW8DZ4PZT6',
              databaseURL:
                  'https://bhada24-96846-default-rtdb.asia-southeast1.firebasedatabase.app/',
            )
          : null,
    );
  }

  static const String vapidKey =
      'BD7Mlk_YLCb6W_IRi91Nsw5KWfOMp1z-ZKimK6scy1wdtQ-f0AhjPKC_9IU3y20t-0ysNCAVfhXvpX6TEWkiI58';
}
