import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _demarrerServices();
  runApp(const ProviderScope(child: LivroAdminApp()));
}

/// Démarre Firebase et Supabase. Un échec (réseau, configuration) ne bloque pas l'app :
/// elle s'ouvre, les fonctions concernées sont simplement indisponibles.
Future<void> _demarrerServices() async {
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    debugPrint('Firebase indisponible : $e');
  }
  try {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseClePublique);
  } catch (e) {
    debugPrint('Supabase indisponible : $e');
  }
}
