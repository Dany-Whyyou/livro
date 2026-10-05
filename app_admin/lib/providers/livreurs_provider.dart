import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/livreur.dart';
import '../data/mock/mock_data.dart';

class LivreursNotifier extends StateNotifier<List<Livreur>> {
  LivreursNotifier() : super(mockLivreurs);

  int _prochainId = mockLivreurs.length + 1;

  /// Vrai si un autre livreur utilise déjà ce numéro.
  bool numeroDejaPris(String telephone, {String? saufId}) => state.any((l) => l.telephone == telephone && l.id != saufId);

  void ajouter({
    required String nom,
    required String telephone,
    required String vehicule,
    required String ville,
    required ModeDisponibilite mode,
    bool whatsapp = false,
    String? quartier,
  }) {
    final livreur = Livreur(
      id: '${_prochainId++}',
      nom: nom,
      telephone: telephone,
      vehicule: vehicule,
      ville: ville,
      mode: mode,
      whatsapp: whatsapp,
      quartier: quartier,
      origine: OrigineFiche.admin,
    );
    state = [livreur, ...state];
  }

  void modifier(Livreur livreur) {
    state = [for (final l in state) l.id == livreur.id ? livreur : l];
  }

  void renommerVille(String ancien, String nouveau) {
    state = [for (final l in state) l.ville == ancien ? l.copyWith(ville: nouveau) : l];
  }

  void supprimer(String id) {
    state = state.where((l) => l.id != id).toList();
  }
}

final livreursProvider = StateNotifierProvider<LivreursNotifier, List<Livreur>>((ref) => LivreursNotifier());

enum FiltreStatut { tous, aValider, photosAValider, injoignables, disponibles, indisponibles, suspendus, sansSmartphone }

final rechercheProvider = StateProvider<String>((ref) => '');
final filtreStatutProvider = StateProvider<FiltreStatut>((ref) => FiltreStatut.tous);

/// Livreurs correspondant à la recherche (nom ou numéro) et au filtre, par ordre alphabétique.
final livreursFiltresProvider = Provider<List<Livreur>>((ref) {
  final recherche = ref.watch(rechercheProvider).trim().toLowerCase();
  final chiffres = recherche.replaceAll(RegExp(r'\D'), '');
  final filtre = ref.watch(filtreStatutProvider);
  final maintenant = DateTime.now();

  bool correspond(Livreur l) {
    if (recherche.isNotEmpty) {
      final parNom = l.nom.toLowerCase().contains(recherche);
      final parNumero = chiffres.isNotEmpty && l.telephone.contains(chiffres);
      if (!parNom && !parNumero) return false;
    }
    switch (filtre) {
      case FiltreStatut.tous:
        return true;
      case FiltreStatut.aValider:
        return l.statut == StatutCompte.enAttente;
      case FiltreStatut.photosAValider:
        return l.photoAValider;
      case FiltreStatut.injoignables:
        return l.nonReponses7j > 0;
      case FiltreStatut.disponibles:
        return l.estDisponible(maintenant);
      case FiltreStatut.indisponibles:
        return l.statut == StatutCompte.valide && !l.suspendu && !l.estDisponible(maintenant);
      case FiltreStatut.suspendus:
        return l.suspendu;
      case FiltreStatut.sansSmartphone:
        return l.origine == OrigineFiche.admin;
    }
  }

  return ref.watch(livreursProvider).where(correspond).toList()..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
});
