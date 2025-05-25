import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY",
            authDomain: "versus-space-1lwwiw.firebaseapp.com",
            projectId: "versus-space-1lwwiw",
            storageBucket: "versus-space-1lwwiw.appspot.com",
            messagingSenderId: "636984750551",
            appId: "1:636984750551:web:4cf3216b87a29dc7691b92"));
  } else {
    await Firebase.initializeApp();
  }
}
