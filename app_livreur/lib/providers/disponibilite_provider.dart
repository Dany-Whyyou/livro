import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'compte_provider.dart';

enum ModeDisponibilite { disponible, auto, indisponible }

// Plage du mode auto : disponible de 8h à 20h
const heureDebutAuto = 8;
const heureFinAuto = 20;

final modeDisponibiliteProvider = StateProvider<ModeDisponibilite>((ref) => ModeDisponibilite.indisponible);

/// Vrai entre 8h et 20h. Se recalcule tout seul au prochain changement (8h ou 20h).
final plageAutoProvider = Provider<bool>((ref) {
  final now = DateTime.now();
  final dansPlage = now.hour >= heureDebutAuto && now.hour < heureFinAuto;

  final prochaineHeure = dansPlage ? heureFinAuto : heureDebutAuto;
  var bascule = DateTime(now.year, now.month, now.day, prochaineHeure);
  if (!bascule.isAfter(now)) bascule = DateTime(now.year, now.month, now.day + 1, prochaineHeure);

  final timer = Timer(bascule.difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return dansPlage;
});

/// Disponibilité effective du livreur, selon le mode choisi (jamais disponible tant que le compte n'est pas validé).
final disponibleProvider = Provider<bool>((ref) {
  if (ref.watch(statutCompteProvider) != StatutCompte.valide) return false;
  switch (ref.watch(modeDisponibiliteProvider)) {
    case ModeDisponibilite.disponible:
      return true;
    case ModeDisponibilite.indisponible:
      return false;
    case ModeDisponibilite.auto:
      return ref.watch(plageAutoProvider);
  }
});
