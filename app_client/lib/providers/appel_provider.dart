import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/appel.dart';
import '../data/models/livreur.dart';

/// Appel lancé depuis Livro : au retour dans l'app, on demande si le livreur a répondu.
class AppelEnAttente {
  final Livreur livreur;
  final DateTime lanceLe;
  const AppelEnAttente(this.livreur, this.lanceLe);
}

final appelEnAttenteProvider = StateProvider<AppelEnAttente?>((ref) => null);

/// Non-réponses déclarées par le client. Mock : à envoyer au backend, qui repasse en
/// indisponible un livreur signalé injoignable par plusieurs clients dans la journée.
class NonReponsesNotifier extends StateNotifier<List<(String, DateTime)>> {
  NonReponsesNotifier() : super(const []);

  void signaler(Livreur livreur) => state = [...state, (livreur.id, DateTime.now())];
}

final nonReponsesProvider = StateNotifierProvider<NonReponsesNotifier, List<(String, DateTime)>>((ref) => NonReponsesNotifier());

/// Lance l'appel (normal ou WhatsApp) et le mémorise pour poser la question au retour.
Future<void> lancerAppel(BuildContext context, WidgetRef ref, Livreur livreur, {bool whatsapp = false}) async {
  ref.read(appelEnAttenteProvider.notifier).state = AppelEnAttente(livreur, DateTime.now());
  final ouvert = whatsapp ? await ouvrirWhatsApp(context, livreur.telephone) : await appeler(context, livreur.telephone);
  if (!ouvert) ref.read(appelEnAttenteProvider.notifier).state = null;
}
