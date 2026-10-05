import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Valeurs publiques (faites pour être dans l'app) : les droits réels sont contrôlés
// par les règles de la base Supabase et par Firebase.

const supabaseUrl = 'https://ukaklgcrmdcaysdzxudf.supabase.co';
const supabaseClePublique = 'sb_publishable_63tTd0KdR61Tj65P1al3NA_wKJVN8TS';

/// Configuration Firebase (projet livro-gabon), sans fichier google-services.json ni plist.
FirebaseOptions get firebaseOptions => switch (defaultTargetPlatform) {
  TargetPlatform.iOS => const FirebaseOptions(
    apiKey: 'AIzaSyAWNbVhNJpcQo-dxpH6naIaLHEavI1j8r0',
    appId: '1:618853017640:ios:30a9400164e6ed33182d1d',
    messagingSenderId: '618853017640',
    projectId: 'livro-gabon',
    storageBucket: 'livro-gabon.firebasestorage.app',
    iosBundleId: 'com.dadel.livro-admin',
  ),
  _ => const FirebaseOptions(
    apiKey: 'AIzaSyA-KUi8am-HYvVtp4MRGH8smibz3hQnXyk',
    appId: '1:618853017640:android:3baed2acaac564d5182d1d',
    messagingSenderId: '618853017640',
    projectId: 'livro-gabon',
    storageBucket: 'livro-gabon.firebasestorage.app',
  ),
};
