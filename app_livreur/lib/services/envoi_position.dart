import 'package:flutter/foundation.dart';

/// Envoi de la position au serveur.
abstract class EnvoiPosition {
  Future<void> envoyer(double lat, double lng);
}

/// Mock : en attendant la connexion par SMS, la position n'est pas encore envoyée à Supabase.
/// À remplacer par l'appel de la fonction `mettre_a_jour_position` (livreur connecté).
class EnvoiPositionMock implements EnvoiPosition {
  const EnvoiPositionMock();

  @override
  Future<void> envoyer(double lat, double lng) async {
    debugPrint('Position envoyée (mock) : $lat, $lng');
  }
}
