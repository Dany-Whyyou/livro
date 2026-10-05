import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/distance.dart';
import '../data/mock/mock_data.dart';
import '../services/source_position.dart';

final sourcePositionProvider = Provider<SourcePosition>((ref) => const SourcePositionGps());

enum StatutPosition { desactivee, recherche, active, refusee, bloquee, gpsCoupe, introuvable }

class PositionClient {
  final StatutPosition statut;
  final Coordonnees? coordonnees;

  /// Position simulée (centre de la ville), pour tester hors du Gabon en développement
  final bool simulee;

  const PositionClient(this.statut, {this.coordonnees, this.simulee = false});
}

class PositionClientNotifier extends StateNotifier<PositionClient> {
  final Ref _ref;
  PositionClientNotifier(this._ref) : super(const PositionClient(StatutPosition.desactivee));

  /// Demande l'accès puis lit la position du téléphone.
  Future<void> activer() async {
    state = const PositionClient(StatutPosition.recherche);
    final source = _ref.read(sourcePositionProvider);
    final acces = await source.demanderAcces();
    if (!mounted) return;
    switch (acces) {
      case AccesPosition.accorde:
        await actualiser();
      case AccesPosition.refuse:
        state = const PositionClient(StatutPosition.refusee);
      case AccesPosition.bloque:
        state = const PositionClient(StatutPosition.bloquee);
      case AccesPosition.gpsCoupe:
        state = const PositionClient(StatutPosition.gpsCoupe);
    }
  }

  /// Relit la position (au retour dans l'app, le client a pu se déplacer).
  Future<void> actualiser() async {
    if (state.simulee) return;
    try {
      final (lat, lng) = await _ref.read(sourcePositionProvider).positionActuelle();
      if (mounted) state = PositionClient(StatutPosition.active, coordonnees: Coordonnees(lat, lng));
    } catch (_) {
      if (mounted && state.coordonnees == null) state = const PositionClient(StatutPosition.introuvable);
    }
  }

  void simuler(String ville) {
    final centre = centresVilles[ville];
    if (centre != null) state = PositionClient(StatutPosition.active, coordonnees: centre, simulee: true);
  }

  void desactiver() => state = const PositionClient(StatutPosition.desactivee);

  Future<void> ouvrirReglages() => _ref.read(sourcePositionProvider).ouvrirReglages();
}

final positionProvider = StateNotifierProvider<PositionClientNotifier, PositionClient>((ref) => PositionClientNotifier(ref));
