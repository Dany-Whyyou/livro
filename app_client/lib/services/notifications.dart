import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Messager de l'app : affiche les notifications reçues pendant que l'app est ouverte
/// (Firebase ne les affiche pas lui-même dans ce cas).
final messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Notifications push (Firebase Cloud Messaging).
/// Les messages envoyés à tous ou à un groupe passent par des sujets FCM ;
/// les messages personnels (livreurs) par le jeton enregistré dans Supabase.
class Notifications {
  static const _app = 'client';
  static const _sujets = ['tous', 'clients'];
  static bool _actives = false;
  static String? _jeton;

  /// Demande l'autorisation, s'abonne aux sujets et enregistre le téléphone.
  /// À appeler une fois l'écran principal affiché ; sans effet si déjà fait.
  static Future<void> activer() async {
    if (_actives || kIsWeb || Firebase.apps.isEmpty) return;
    _actives = true;
    try {
      final fcm = FirebaseMessaging.instance;
      final autorisation = await fcm.requestPermission();
      if (autorisation.authorizationStatus == AuthorizationStatus.denied) return;

      // Sur iPhone, Firebase a besoin du jeton Apple avant tout le reste
      if (defaultTargetPlatform == TargetPlatform.iOS && !await _attendreJetonApple(fcm)) {
        debugPrint('Notifications : pas de jeton Apple (clé APNs absente de Firebase ?)');
        _actives = false;
        return;
      }

      for (final sujet in _sujets) {
        await fcm.subscribeToTopic(sujet);
      }
      final jeton = await fcm.getToken();
      if (jeton != null) await _enregistrer(jeton);
      fcm.onTokenRefresh.listen(_enregistrer);
      FirebaseMessaging.onMessage.listen(_afficher);
    } catch (e) {
      debugPrint('Notifications indisponibles : $e');
      _actives = false;
    }
  }

  /// Rattache à nouveau le téléphone (après connexion, pour recevoir les messages personnels).
  static Future<void> reenregistrer() async {
    if (_jeton != null) await _enregistrer(_jeton!);
  }

  /// À la déconnexion : le téléphone ne reçoit plus les messages personnels.
  static Future<void> oublier() async {
    final jeton = _jeton;
    if (jeton == null) return;
    try {
      await Supabase.instance.client.rpc('oublier_appareil', params: {'p_token': jeton});
    } catch (e) {
      debugPrint('Notifications : oubli impossible : $e');
    }
  }

  static Future<bool> _attendreJetonApple(FirebaseMessaging fcm) async {
    for (var i = 0; i < 10; i++) {
      if (await fcm.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  static Future<void> _enregistrer(String jeton) async {
    _jeton = jeton;
    try {
      await Supabase.instance.client.rpc('enregistrer_appareil', params: {
        'p_token': jeton,
        'p_app': _app,
        'p_plateforme': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('Notifications : enregistrement impossible : $e');
    }
  }

  static void _afficher(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (n.title != null) Text(n.title!, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (n.body != null) Text(n.body!),
          ],
        ),
      ),
    );
  }
}
