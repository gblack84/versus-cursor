import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '/core/config/environment_config.dart';

Future initFirebase() async {
  try {
    if (kIsWeb) {
      // Validate Web-specific Firebase configuration
      if (EnvironmentConfig.firebaseMessagingSenderId.isEmpty ||
          EnvironmentConfig.firebaseAppId.isEmpty) {
        throw Exception(
          '❌ Firebase Web Configuration Missing!\n'
          '\n'
          'Required environment variables not set in .env file:\n'
          '  ${EnvironmentConfig.firebaseMessagingSenderId.isEmpty ? "- FIREBASE_MESSAGING_SENDER_ID\n" : ""}'
          '  ${EnvironmentConfig.firebaseAppId.isEmpty ? "- FIREBASE_APP_ID\n" : ""}'
          '\n'
          'Please add these values to your .env file.\n'
          'See .env.example for template.',
        );
      }

      await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: EnvironmentConfig.firebaseApiKey,
              authDomain: EnvironmentConfig.firebaseAuthDomain,
              projectId: EnvironmentConfig.firebaseProjectId,
              storageBucket: EnvironmentConfig.firebaseStorageBucket,
              messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
              appId: EnvironmentConfig.firebaseAppId));
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Firebase initialization error - will be visible in crash logs via rethrow
    // DevTools will show full error details and stack trace
    rethrow;
  }
}
