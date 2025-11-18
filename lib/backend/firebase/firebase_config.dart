import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD7E6MTG-jNeMKJrsGgcyTd-ZDLMly7JzQ",
            authDomain: "bd-ruta-precio-4ead5.firebaseapp.com",
            projectId: "bd-ruta-precio-4ead5",
            storageBucket: "bd-ruta-precio-4ead5.firebasestorage.app",
            messagingSenderId: "636329565499",
            appId: "1:636329565499:web:7d85a178da80ad4abf6b1e",
            measurementId: "G-Z6KEBQGVCD"));
  } else {
    await Firebase.initializeApp();
  }
}
