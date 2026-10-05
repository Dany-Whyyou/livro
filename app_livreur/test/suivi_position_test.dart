import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_livreur/providers/compte_provider.dart';
import 'package:app_livreur/providers/disponibilite_provider.dart';
import 'package:app_livreur/providers/localisation_provider.dart';
import 'package:app_livreur/services/envoi_position.dart';
import 'package:app_livreur/services/source_position.dart';

class FausseSource implements SourcePosition {
  AccesPosition acces = AccesPosition.accorde;
  StreamController<(double, double)>? flux;
  int ouvertures = 0;

  @override
  Future<AccesPosition> demanderAcces() async => acces;

  @override
  Stream<(double, double)> suivre() {
    ouvertures++;
    flux = StreamController<(double, double)>();
    return flux!.stream;
  }

  bool get ecoute => flux != null && flux!.hasListener;

  @override
  Future<void> ouvrirReglages() async {}
}

class FauxEnvoi implements EnvoiPosition {
  final envois = <(double, double)>[];
  @override
  Future<void> envoyer(double lat, double lng) async => envois.add((lat, lng));
}

void main() {
  late FausseSource source;
  late FauxEnvoi envoi;
  late ProviderContainer c;

  setUp(() {
    source = FausseSource();
    envoi = FauxEnvoi();
    c = ProviderContainer(overrides: [
      sourcePositionProvider.overrideWithValue(source),
      envoiPositionProvider.overrideWithValue(envoi),
      plageAutoProvider.overrideWithValue(true),
    ]);
    c.read(statutCompteProvider.notifier).state = StatutCompte.valide;
    c.read(modeDisponibiliteProvider.notifier).state = ModeDisponibilite.disponible;
  });
  tearDown(() => c.dispose());

  Future<void> laisserPasser() => Future<void>.delayed(Duration.zero);

  test('accès accordé : le GPS démarre, la première position est envoyée', () async {
    final suivi = c.read(suiviPositionProvider.notifier);
    expect(await suivi.activer(), isTrue);
    expect(c.read(suiviPositionProvider).statut, StatutSuivi.recherche);
    expect(source.ecoute, isTrue);
    source.flux!.add((0.3925, 9.4536));
    await laisserPasser();
    expect(envoi.envois.length, 1);
    expect(c.read(suiviPositionProvider).statut, StatutSuivi.actif);
  });

  test('envoi économe : rien sous 100 m, envoi au-delà', () async {
    await c.read(suiviPositionProvider.notifier).activer();
    source.flux!.add((0.3925, 9.4536));
    await laisserPasser();
    source.flux!.add((0.3929, 9.4536)); // ~45 m
    await laisserPasser();
    expect(envoi.envois.length, 1);
    source.flux!.add((0.3940, 9.4536)); // ~170 m du dernier envoi
    await laisserPasser();
    expect(envoi.envois.length, 2);
  });

  test('livreur indisponible : GPS en pause, reprise quand il redevient disponible', () async {
    await c.read(suiviPositionProvider.notifier).activer();
    c.read(modeDisponibiliteProvider.notifier).state = ModeDisponibilite.indisponible;
    await laisserPasser();
    expect(c.read(suiviPositionProvider).statut, StatutSuivi.enPause);
    expect(source.ecoute, isFalse);
    c.read(modeDisponibiliteProvider.notifier).state = ModeDisponibilite.disponible;
    await laisserPasser();
    expect(source.ecoute, isTrue);
    expect(source.ouvertures, 2);
  });

  test('compte pas encore validé : pas de GPS', () async {
    c.read(statutCompteProvider.notifier).state = StatutCompte.enAttente;
    await c.read(suiviPositionProvider.notifier).activer();
    expect(c.read(suiviPositionProvider).statut, StatutSuivi.enPause);
    expect(source.ecoute, isFalse);
  });

  test('accès refusé, bloqué ou GPS coupé : localisation non activée, cause indiquée', () async {
    for (final (acces, statut) in [
      (AccesPosition.refuse, StatutSuivi.permissionRefusee),
      (AccesPosition.bloque, StatutSuivi.permissionBloquee),
      (AccesPosition.gpsCoupe, StatutSuivi.gpsCoupe),
    ]) {
      source.acces = acces;
      expect(await c.read(suiviPositionProvider.notifier).activer(), isFalse);
      expect(c.read(localisationActiveProvider), isFalse);
      expect(c.read(suiviPositionProvider).statut, statut);
    }
  });

  test('désactivation : GPS arrêté', () async {
    await c.read(suiviPositionProvider.notifier).activer();
    c.read(suiviPositionProvider.notifier).desactiver();
    expect(source.ecoute, isFalse);
    expect(c.read(suiviPositionProvider).statut, StatutSuivi.arrete);
  });
}
