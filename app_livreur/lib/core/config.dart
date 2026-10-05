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
          appId: '1:618853017640:ios:5caa09fde8630409182d1d',
          messagingSenderId: '618853017640',
          projectId: 'livro-gabon',
          storageBucket: 'livro-gabon.firebasestorage.app',
          iosBundleId: 'com.dadel.livro-livreur',
        ),
      _ => const FirebaseOptions(
          apiKey: 'AIzaSyA-KUi8am-HYvVtp4MRGH8smibz3hQnXyk',
          appId: '1:618853017640:android:5a1e9c40da046d86182d1d',
          messagingSenderId: '618853017640',
          projectId: 'livro-gabon',
          storageBucket: 'livro-gabon.firebasestorage.app',
        ),
    };
