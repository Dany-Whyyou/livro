import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/ville.dart';
import 'livreurs_provider.dart';

class VillesNotifier extends StateNotifier<List<Ville>> {
  final Ref _ref;
  VillesNotifier(this._ref) : super(mockVilles);

  int _prochainId = mockVilles.length + 1;

  bool nomDejaPris(String nom, {String? saufId}) => state.any((v) => v.nom.toLowerCase() == nom.toLowerCase() && v.id != saufId);

  void ajouter({required String nom, required String province}) {
    state = [...state, Ville(id: '${_prochainId++}', nom: nom, province: province)];
  }

  /// Renommer une ville met aussi à jour les livreurs qui y sont rattachés.
  void modifier(Ville ville, {required String nom, required String province}) {
    if (nom != ville.nom) {
      _ref.read(livreursProvider.notifier).renommerVille(ville.nom, nom);
    }
    state = [for (final v in state) v.id == ville.id ? Ville(id: v.id, nom: nom, province: province) : v];
  }

  void supprimer(String id) {
    state = state.where((v) => v.id != id).toList();
  }
}

final villesProvider = StateNotifierProvider<VillesNotifier, List<Ville>>((ref) => VillesNotifier(ref));
