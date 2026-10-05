import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/envoi_position.dart';
import '../services/source_position.dart';
import 'disponibilite_provider.dart';

/// Le livreur partage sa position : les clients proches le voient en premier.
final localisationActiveProvider = StateProvider<bool>((ref) => false);

final sourcePositionProvider = Provider<SourcePosition>((ref) => const SourcePositionGps());
final envoiPositionProvider = Provider<EnvoiPosition>((ref) => const EnvoiPositionMock());

// Règles d'envoi : assez souvent pour que la position reste « en direct » côté serveur
// (périmée au bout de 15 minutes), sans vider la batterie ni le forfait.
const distanceMinEnvoiMetres = 100.0;
const delaiMaxSansEnvoi = Duration(minutes: 10);
const intervalleVerification = Duration(minutes: 2);

enum StatutSuivi {
  /// Localisation désactivée par le livreur
  arrete,

  /// Activée, mais le livreur n'est pas disponible : on n'utilise pas le GPS
  enPause,

  /// En attente de la première position
  recherche,
  actif,
  permissionRefusee,
  permissionBloquee,
  gpsCoupe,
}

class SuiviPosition {
  final StatutSuivi statut;
  final DateTime? dernierEnvoi;
  const SuiviPosition(this.statut, {this.dernierEnvoi});
}

/// Suit le GPS quand la localisation est activée ET que le livreur est disponible,
/// et n'envoie au serveur que si la position a changé de 100 m ou si le dernier envoi a 10 minutes.
class SuiviPositionNotifier extends StateNotifier<SuiviPosition> {
  final Ref _ref;
  StreamSubscription<(double, double)>? _abonnement;
  Timer? _verification;
  (double, double)? _derniere;
  (double, double)? _derniereEnvoyee;
  DateTime? _dateEnvoi;

  SuiviPositionNotifier(this._ref) : super(const SuiviPosition(StatutSuivi.arrete)) {
    _ref.listen<bool>(localisationActiveProvider, (_, __) => _reevaluer());
    _ref.listen<bool>(disponibleProvider, (_, __) => _reevaluer());
    _reevaluer();
  }

  /// Demande l'accès au GPS puis active la localisation. Renvoie false si l'accès est refusé.
  Future<bool> activer() async {
    final acces = await _ref.read(sourcePositionProvider).demanderAcces();
    if (!mounted) return false;
    switch (acces) {
      case AccesPosition.accorde:
        _ref.read(localisationActiveProvider.notifier).state = true;
        return true;
      case AccesPosition.refuse:
        state = const SuiviPosition(StatutSuivi.permissionRefusee);
      case AccesPosition.bloque:
        state = const SuiviPosition(StatutSuivi.permissionBloquee);
      case AccesPosition.gpsCoupe:
        state = const SuiviPosition(StatutSuivi.gpsCoupe);
    }
    return false;
  }

  void desactiver() {
    _ref.read(localisationActiveProvider.notifier).state = false;
    _arreterGps();
    state = const SuiviPosition(StatutSuivi.arrete);
  }

  Future<void> ouvrirReglages() => _ref.read(sourcePositionProvider).ouvrirReglages();

  void _reevaluer() {
    final active = _ref.read(localisationActiveProvider);
    final disponible = _ref.read(disponibleProvider);
    if (!active) {
      _arreterGps();
      // On garde l'explication d'un refus tant que le livreur n'a pas réessayé
      if (state.statut == StatutSuivi.actif || state.statut == StatutSuivi.enPause || state.statut == StatutSuivi.recherche) {
        state = const SuiviPosition(StatutSuivi.arrete);
      }
      return;
    }
    if (!disponible) {
      _arreterGps();
      state = SuiviPosition(StatutSuivi.enPause, dernierEnvoi: _dateEnvoi);
      return;
    }
    if (_abonnement == null) _demarrerGps();
  }

  void _demarrerGps() {
    state = SuiviPosition(StatutSuivi.recherche, dernierEnvoi: _dateEnvoi);
    _abonnement = _ref.read(sourcePositionProvider).suivre().listen(
      _recevoir,
      onError: (_) {
        _arreterGps();
        if (mounted) state = const SuiviPosition(StatutSuivi.gpsCoupe);
      },
    );
    // Rafraîchit la position côté serveur même si le livreur ne bouge pas
    _verification = Timer.periodic(intervalleVerification, (_) => _envoyerSiNecessaire());
  }

  void _arreterGps() {
    _abonnement?.cancel();
    _abonnement = null;
    _verification?.cancel();
    _verification = null;
  }

  void _recevoir((double, double) position) {
    _derniere = position;
    _envoyerSiNecessaire();
  }

  Future<void> _envoyerSiNecessaire() async {
    final position = _derniere;
    if (position == null) return;
    final maintenant = DateTime.now();
    final aBouge = _derniereEnvoyee == null || _distanceMetres(_derniereEnvoyee!, position) >= distanceMinEnvoiMetres;
    final tropAncien = _dateEnvoi == null || maintenant.difference(_dateEnvoi!) >= delaiMaxSansEnvoi;
    if (!aBouge && !tropAncien) {
      if (state.statut == StatutSuivi.recherche) state = SuiviPosition(StatutSuivi.actif, dernierEnvoi: _dateEnvoi);
      return;
    }
    try {
      await _ref.read(envoiPositionProvider).envoyer(position.$1, position.$2);
      _derniereEnvoyee = position;
      _dateEnvoi = maintenant;
      if (mounted && _abonnement != null) state = SuiviPosition(StatutSuivi.actif, dernierEnvoi: _dateEnvoi);
    } catch (_) {
      // Pas de réseau : on réessaiera à la prochaine position ou vérification
    }
  }

  static double _distanceMetres((double, double) a, (double, double) b) {
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(b.$1 - a.$1), dLng = rad(b.$2 - a.$2);
    final h = math.pow(math.sin(dLat / 2), 2) + math.cos(rad(a.$1)) * math.cos(rad(b.$1)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * 6371000 * math.asin(math.sqrt(h));
  }

  @override
  void dispose() {
    _arreterGps();
    super.dispose();
  }
}

final suiviPositionProvider = StateNotifierProvider<SuiviPositionNotifier, SuiviPosition>((ref) => SuiviPositionNotifier(ref));
