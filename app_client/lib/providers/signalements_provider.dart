import 'package:flutter_riverpod/flutter_riverpod.dart';

class Signalement {
  final String telephoneLivreur;
  final String message;
  final DateTime creeLe;

  const Signalement({required this.telephoneLivreur, required this.message, required this.creeLe});
}

class SignalementsNotifier extends StateNotifier<List<Signalement>> {
  SignalementsNotifier() : super(const []);

  Future<void> envoyer({required String telephoneLivreur, required String message}) async {
    // mock : simule l'envoi au serveur (traité ensuite dans Livro Admin)
    await Future.delayed(const Duration(milliseconds: 800));
    state = [...state, Signalement(telephoneLivreur: telephoneLivreur, message: message, creeLe: DateTime.now())];
  }
}

final signalementsProvider = StateNotifierProvider<SignalementsNotifier, List<Signalement>>(
  (ref) => SignalementsNotifier(),
);
