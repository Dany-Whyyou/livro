import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un compte créé dans l'app doit être validé par un admin avant que le
/// livreur soit affiché aux clients.
enum StatutCompte { enAttente, valide, refuse }

final statutCompteProvider = StateProvider<StatutCompte>((ref) => StatutCompte.valide);
