import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '/core/config/environment_config.dart';

Future initFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: EnvironmentConfig.firebaseApiKey,
              authDomain: EnvironmentConfig.firebaseAuthDomain,
              projectId: EnvironmentConfig.firebaseProjectId,
              storageBucket: EnvironmentConfig.firebaseStorageBucket,
              messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId.isNotEmpty 
                  ? EnvironmentConfig.firebaseMessagingSenderId 
                  : "636984750551",
              appId: EnvironmentConfig.firebaseAppId.isNotEmpty
                  ? EnvironmentConfig.firebaseAppId
                  : "1:636984750551:web:4cf3216b87a29dc7691b92"));
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    print('Error type: ${e.runtimeType}');
    if (e is FirebaseException) {
      print('Firebase error code: ${e.code}');
      print('Firebase error message: ${e.message}');
    }
    rethrow;
  }
}