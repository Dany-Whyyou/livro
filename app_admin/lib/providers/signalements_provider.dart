import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/signalement.dart';

class SignalementsNotifier extends StateNotifier<List<Signalement>> {
  SignalementsNotifier() : super(mockSignalements);

  void changerStatut(String id, StatutSignalement statut) {
    state = [for (final s in state) s.id == id ? s.copyWith(statut: statut) : s];
  }
}

final signalementsProvider = StateNotifierProvider<SignalementsNotifier, List<Signalement>>((ref) => SignalementsNotifier());

/// true = à traiter, false = déjà traités ou classés
final signalementsATraiterProvider = StateProvider<bool>((ref) => true);

/// Signalements de l'onglet choisi, du plus récent au plus ancien.
final signalementsFiltresProvider = Provider<List<Signalement>>((ref) {
  final aTraiter = ref.watch(signalementsATraiterProvider);
  return ref.watch(signalementsProvider).where((s) => s.aTraiter == aTraiter).toList()..sort((a, b) => b.creeLe.compareTo(a.creeLe));
});
